
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/app_colors.dart';
import '../models/cart_item.dart';
import '../services/cart_store.dart';
import '../services/order_session_store.dart';
import 'home_screen.dart';

class PaymentSimulationScreen extends StatefulWidget {
  final String paymentMethod;
  final String customerName;
  final String orderType;
  final String tableNumber;
  final int totalPayment;
  final List<CartItem> orderItems;

  // Menentukan apakah produk berasal dari
  // checkout keranjang atau Beli Sekarang.
  final bool isCartCheckout;

  const PaymentSimulationScreen({
    super.key,
    required this.paymentMethod,
    required this.customerName,
    required this.orderType,
    required this.tableNumber,
    required this.totalPayment,
    required this.orderItems,
    this.isCartCheckout = false,
  });

  @override
  State<PaymentSimulationScreen> createState() =>
      _PaymentSimulationScreenState();
}

class _PaymentSimulationScreenState
    extends State<PaymentSimulationScreen> {
  bool paymentSuccessful = false;
  bool isProcessing = false;

  late final String orderNumber;
  late final DateTime createdAt;
  late final DateTime deadline;

  DateTime? paidAt;
  Timer? countdownTimer;

  Duration remaining = const Duration(minutes: 10);

  final GlobalKey qrKey = GlobalKey();
  final GlobalKey receiptKey = GlobalKey();

  bool get isOnline => widget.paymentMethod == 'online';

  bool get isPaymentWarning =>
      isOnline &&
      remaining.inSeconds <= 300 &&
      !paymentSuccessful;

  bool get isExpired =>
      isOnline &&
      !DateTime.now().isBefore(deadline) &&
      !paymentSuccessful;

  @override
  void initState() {
    super.initState();

    createdAt = DateTime.now();
    deadline = createdAt.add(
      const Duration(minutes: 10),
    );

    orderNumber =
        'ORD-${createdAt.year}'
        '${createdAt.month.toString().padLeft(2, '0')}'
        '${createdAt.day.toString().padLeft(2, '0')}-'
        '${createdAt.microsecondsSinceEpoch.toString().substring(8)}';

    if (isOnline) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted || paymentSuccessful) {
          timer.cancel();
          return;
        }

        final difference = deadline.difference(
          DateTime.now(),
        );

        setState(() {
          remaining = difference.isNegative
              ? Duration.zero
              : difference;
        });

        if (remaining == Duration.zero) {
          timer.cancel();
        }
      },
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  String formatPrice(int value) {
    final result = value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    return 'Rp$result';
  }

  String get formattedCountdown {
    final minutes =
        remaining.inMinutes.toString().padLeft(2, '0');

    final seconds =
        (remaining.inSeconds % 60)
            .toString()
            .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  String formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;

    final hour =
        date.hour.toString().padLeft(2, '0');

    final minute =
        date.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute WIB';
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.dark,
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // =====================================
  // PEMBAYARAN BERHASIL
  // =====================================

  void _completePayment() {
    // Jangan mencatat atau menghapus dua kali.
    if (paymentSuccessful) return;

    // QRIS yang sudah melewati batas waktu
    // tidak boleh menyelesaikan transaksi.
    if (isExpired) {
      countdownTimer?.cancel();

      setState(() {
        remaining = Duration.zero;
      });

      _showMessage(
        'Waktu pembayaran QRIS telah habis.',
      );
      return;
    }

    if (widget.orderItems.isEmpty) {
      _showMessage(
        'Tidak ada produk yang dapat dicatat.',
      );
      return;
    }

    final now = DateTime.now();

    // 1. Simpan pesanan untuk Status & Riwayat.
    final order = SessionOrder(
      id: orderNumber,
      customerName: widget.customerName,
      orderType: widget.orderType,
      tableNumber: widget.tableNumber,
      paymentMethod: widget.paymentMethod,
      totalPayment: widget.totalPayment,
      createdAt: createdAt,
      paidAt: now,
      items: widget.orderItems
          .map(SessionOrderItem.fromCartItem)
          .toList(),
    );

    OrderSessionStore.instance.addOrder(order);

    // 2. Hapus hanya produk transaksi
    // yang berasal dari checkout keranjang.
    //
    // Produk yang tidak dipilih tetap ada.
    // Beli Sekarang tidak menghapus keranjang.
    if (widget.isCartCheckout) {
      CartStore.instance.removePurchasedItems(
        widget.orderItems,
      );
    }

    countdownTimer?.cancel();

    // 3. Tampilkan konfirmasi pembayaran.
    setState(() {
      paidAt = now;
      paymentSuccessful = true;
    });
  }

  void _backToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  // =====================================
  // SIMPAN DAN BAGIKAN GAMBAR
  // =====================================

  Future<void> _shareImage({
    required GlobalKey key,
    required String filename,
    required String message,
  }) async {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    try {
      final contextForImage = key.currentContext;

      if (contextForImage == null) {
        throw Exception('Gambar belum tersedia.');
      }

      final boundary = contextForImage.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Gambar belum siap.');
      }

      final ui.Image image = await boundary.toImage(
        pixelRatio: 3,
      );

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      image.dispose();

      if (byteData == null) {
        throw Exception('Gagal membuat gambar.');
      }

      final directory =
          await getTemporaryDirectory();

      final file = File(
        '${directory.path}/$filename.png',
      );

      await file.writeAsBytes(
        byteData.buffer.asUint8List(),
      );

      if (!mounted) return;

      await SharePlus.instance.share(
        ShareParams(
          text: message,
          files: [
            XFile(file.path),
          ],
        ),
      );
    } catch (error) {
      _showMessage(
        'Gambar gagal dibagikan: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  void _shareQris() {
    if (isExpired) {
      _showMessage(
        'QRIS simulasi sudah kedaluwarsa.',
      );
      return;
    }

    _shareImage(
      key: qrKey,
      filename: 'tapjaya_qris_$orderNumber',
      message:
          'QRIS simulasi TAP JAYA\n'
          'Pesanan: $orderNumber\n'
          'Total: ${formatPrice(widget.totalPayment)}',
    );
  }

  void _shareReceipt() {
    _shareImage(
      key: receiptKey,
      filename: 'tapjaya_struk_$orderNumber',
      message:
          'Struk simulasi TAP JAYA\n'
          'Pesanan: $orderNumber\n'
          'Total: ${formatPrice(widget.totalPayment)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        backgroundColor: AppColors.warmWhite,
        surfaceTintColor: AppColors.warmWhite,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: !paymentSuccessful,
        iconTheme: const IconThemeData(
          color: AppColors.dark,
        ),
        title: Text(
          paymentSuccessful
              ? 'Konfirmasi Pembayaran'
              : isOnline
                  ? 'QRIS'
                  : 'Pembayaran Kasir',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            22, 22, 22, 30,
          ),
          child: paymentSuccessful
              ? _buildSuccessPage()
              : isOnline
                  ? _buildQrisPage()
                  : _buildCashierPage(),
        ),
      ),
    );
  }

  // =====================================
  // HALAMAN PEMBAYARAN QRIS
  // =====================================

  Widget _buildQrisPage() {
    return Column(
      children: [
        Text(
          'Selesaikan pembayaran dalam',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.dark,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          formattedCountdown,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isPaymentWarning
                ? AppColors.red
                : AppColors.dark,
          ),
        ),

        const SizedBox(height: 20),

        RepaintBoundary(
          key: qrKey,
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2DED9),
              ),
            ),
            child: Column(
              children: [
                BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data:
                      'TAPJAYA-DEMO|'
                      '$orderNumber|'
                      '${widget.totalPayment}',
                  width: 196,
                  height: 196,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                ),

                const SizedBox(height: 9),

                Text(
                  'QRIS SIMULASI',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 22),

        Text(
          'Total Pembayaran',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.grey,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          formatPrice(widget.totalPayment),
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.dark,
          ),
        ),

        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: isProcessing || isExpired
              ? null
              : _shareQris,
          icon: const Icon(
            Icons.download_outlined,
            size: 17,
          ),
          label: Text(
            'Simpan / Bagikan QR',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.dark,
            side: const BorderSide(
              color: Color(0xFFDEDAD5),
            ),
          ),
        ),

        const SizedBox(height: 18),

        _buildInfoBox(
          'Cara Pembayaran',
          '1. Buka aplikasi e-wallet atau mobile banking.\n'
          '2. Pilih menu pembayaran QRIS.\n'
          '3. Pindai kode QRIS untuk melakukan pembayaran.\n'
          '4. Selesaikan pembayaran sesuai nominal.',
        ),

        const SizedBox(height: 22),

        if (isExpired)
          _buildInfoBox(
            'Waktu Habis',
            'Batas waktu pembayaran simulasi '
            'telah berakhir. Silakan kembali '
            'dan ulangi proses pemesanan.',
          )
        else
          _buildActionButton(
            'Simulasikan Pembayaran Berhasil',
            _completePayment,
          ),

        const SizedBox(height: 12),

        Text(
          'Demo tugas kuliah. Kode ini tidak '
          'dapat digunakan untuk pembayaran asli.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  // =====================================
  // HALAMAN PEMBAYARAN KASIR
  // =====================================

  Widget _buildCashierPage() {
    return Column(
      children: [
        Text(
          'Kode Pembayaran Kasir',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),

        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2DED9),
            ),
          ),
          child: Column(
            children: [
              BarcodeWidget(
                barcode: Barcode.code128(),
                data: orderNumber,
                width: 240,
                height: 80,
                drawText: false,
                color: Colors.black,
                backgroundColor: Colors.white,
              ),

              const SizedBox(height: 10),

              Text(
                'Pesanan #$orderNumber',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),

              const Divider(height: 26),

              Text(
                'Total Harga',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.grey,
                ),
              ),

              Text(
                formatPrice(widget.totalPayment),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Toko Kopi Jaya Begawan',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.dark,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6A7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Menunggu pembayaran',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _buildInfoBox(
          'Cara Pembayaran',
          '1. Tunjukkan kode pesanan kepada kasir.\n'
          '2. Kasir akan memeriksa pesanan.\n'
          '3. Lakukan pembayaran sesuai total harga.\n'
          '4. Tunggu hingga pembayaran selesai.',
        ),

        const SizedBox(height: 22),

        _buildActionButton(
          'Simulasikan Konfirmasi Kasir',
          _completePayment,
        ),

        const SizedBox(height: 10),

        Text(
          'Demo tugas kuliah. Konfirmasi kasir '
          'dilakukan secara simulasi.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  // =====================================
  // KONFIRMASI PEMBAYARAN
  // =====================================

  Widget _buildSuccessPage() {
    return Column(
      children: [
        const SizedBox(height: 22),

        const Icon(
          Icons.check_circle,
          size: 72,
          color: Color(0xFF20AE6B),
        ),

        const SizedBox(height: 12),

        Text(
          'Pembayaran Berhasil',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.dark,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          isOnline
              ? 'Pembayaran QRIS berhasil disimulasikan.'
              : 'Pembayaran di kasir berhasil disimulasikan.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.grey,
          ),
        ),

        const SizedBox(height: 24),

        RepaintBoundary(
          key: receiptKey,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE2DED9),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rincian Pembayaran',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),

                const SizedBox(height: 18),

                _detailRow(
                  'Nama',
                  widget.customerName,
                ),

                _detailRow(
                  'Metode',
                  isOnline
                      ? 'QRIS'
                      : 'Bayar di Kasir',
                ),

                _detailRow(
                  'Toko',
                  'Toko Kopi Jaya Begawan',
                ),

                _detailRow(
                  'Nomor Order',
                  orderNumber,
                ),

                _detailRow(
                  'Jenis Pesanan',
                  widget.orderType,
                ),

                if (widget.tableNumber.isNotEmpty)
                  _detailRow(
                    'Nomor Meja',
                    widget.tableNumber,
                  ),

                _detailRow(
                  'Tanggal Pembayaran',
                  formatDate(
                    paidAt ?? DateTime.now(),
                  ),
                ),

                _detailRow(
                  'Status',
                  'Dibayar',
                ),

                const Divider(height: 26),

                _detailRow(
                  'Total Pembayaran',
                  formatPrice(widget.totalPayment),
                ),

                const SizedBox(height: 6),

                Text(
                  'Bukti pembayaran simulasi',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        OutlinedButton.icon(
          onPressed:
              isProcessing ? null : _shareReceipt,
          icon: const Icon(
            Icons.ios_share_outlined,
            size: 18,
          ),
          label: Text(
            'Simpan / Bagikan Struk',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.dark,
            side: const BorderSide(
              color: Color(0xFFDEDAD5),
            ),
          ),
        ),

        const SizedBox(height: 22),

        _buildActionButton(
          'Kembali ke Beranda',
          _backToHome,
        ),
      ],
    );
  }

  // =====================================
  // KOMPONEN BANTUAN
  // =====================================

  Widget _detailRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(
    String title,
    String description,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2DED9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 11,
              height: 1.8,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
