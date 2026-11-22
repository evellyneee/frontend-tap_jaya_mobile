import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tap_jaya_mobile/core/constants/app_colors.dart';
import 'package:tap_jaya_mobile/features/cart/models/cart_item.dart';

import 'payment_simulation_screen.dart';

class CustomerInformationScreen extends StatefulWidget {
  final String orderType;
  final int totalPayment;
  final List<CartItem> orderItems;
  final bool isCartCheckout;

  const CustomerInformationScreen({
    super.key,
    required this.orderType,
    required this.totalPayment,
    required this.orderItems,
    this.isCartCheckout = false,
  });

  @override
  State<CustomerInformationScreen> createState() =>
      _CustomerInformationScreenState();
}

class _CustomerInformationScreenState extends State<CustomerInformationScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final tableController = TextEditingController();

  String selectedPayment = 'online';
  bool agreeTerms = false;
  bool cashierConfirmation = false;
  bool isNavigating = false;

  bool get isDineIn {
    final value = widget.orderType.trim().toLowerCase();

    return value == 'makan di tempat' ||
        value == 'dine-in' ||
        value == 'dinein';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    tableController.dispose();
    super.dispose();
  }

  String formatPrice(int value) {
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    return 'Rp $formatted';
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.dark,
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
        ),
      ),
    );
  }

  // ============================================================
  // VALIDASI INFORMASI PELANGGAN
  //
  // Perbaikan:
  // Halaman ini tidak lagi menolak productId yang kosong.
  // Pencarian dan validasi ID MySQL dilakukan oleh
  // CheckoutRepository sebelum pesanan dikirim ke backend.
  // ============================================================

  void _validatePayment() {
    if (isNavigating) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final table = tableController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      _showMessage('Lengkapi informasi pelanggan terlebih dahulu.');
      return;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _showMessage('Alamat email tidak valid.');
      return;
    }

    if (name.length > 100) {
      _showMessage('Nama maksimal 100 karakter.');
      return;
    }

    if (isDineIn && table.isEmpty) {
      _showMessage('Masukkan nomor meja terlebih dahulu.');
      return;
    }

    if (table.length > 20) {
      _showMessage('Nomor meja maksimal 20 karakter.');
      return;
    }

    if (!agreeTerms) {
      _showMessage('Setujui syarat dan kebijakan privasi terlebih dahulu.');
      return;
    }

    if (selectedPayment == 'cashier' && !cashierConfirmation) {
      _showMessage('Centang konfirmasi pembayaran di kasir.');
      return;
    }

    if (widget.orderItems.isEmpty) {
      _showMessage('Pesanan masih kosong.');
      return;
    }

    // Pemeriksaan productId dihapus dari halaman ini.
    //
    // Alasannya:
    // CartItem lama mungkin belum memiliki productId.
    // CheckoutRepository akan mencoba mencari ID MySQL
    // berdasarkan nama produk melalui API /mobile/products.
    //
    // Pemeriksaan jumlah tetap dilakukan di sini.

    for (final item in widget.orderItems) {
      if (item.quantity <= 0) {
        _showMessage('Jumlah produk ${item.productName} tidak valid.');
        return;
      }
    }

    setState(() {
      isNavigating = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSimulationScreen(
          paymentMethod: selectedPayment,
          customerName: name,
          customerEmail: email,
          orderType: isDineIn ? 'Dine-in' : 'Takeaway',
          tableNumber: isDineIn ? table : '',
          totalPayment: widget.totalPayment,
          orderItems: List<CartItem>.from(widget.orderItems),
          isCartCheckout: widget.isCartCheckout,
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          isNavigating = false;
        });
      }
    });
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: AppColors.dark),
            ),
          ),
          Text(
            'Informasi Pelanggan',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
    );
  }

  // ============================================================
  // INPUT PELANGGAN
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.dark),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(fontSize: 10, color: AppColors.grey),
        prefixIcon: Icon(icon, size: 20, color: AppColors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFFE2DED9)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: Color(0xFFE2DED9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.dark),
        ),
      ),
    );
  }

  // ============================================================
  // LOKASI TOKO
  // ============================================================

  Widget _buildStoreLocation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2DED9)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EDE5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_outlined, color: AppColors.red),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toko Kopi Jaya Begawan',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Kopi Jaya Begawan Malang',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.red, size: 21),
        ],
      ),
    );
  }

  // ============================================================
  // TOMBOL PILIHAN PEMBAYARAN
  // ============================================================

  Widget _buildPaymentButton({required String value, required String title}) {
    final active = selectedPayment == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPayment = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.dark : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppColors.dark,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PILIHAN METODE PEMBAYARAN
  // ============================================================

  Widget _buildPaymentSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECE7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPaymentButton(value: 'online', title: 'Pembayaran Online'),
          _buildPaymentButton(value: 'cashier', title: 'Bayar di Kasir'),
        ],
      ),
    );
  }

  // ============================================================
  // PEMBAYARAN ONLINE
  // ============================================================

  Widget _buildOnlinePayment() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2DED9)),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EDE5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.qr_code_2, color: AppColors.dark, size: 27),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QRIS',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Pembayaran online melalui QRIS.',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF2E9E62), size: 23),
        ],
      ),
    );
  }

  // ============================================================
  // PEMBAYARAN DI KASIR
  // ============================================================

  Widget _buildCashierPayment() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7E8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF0D8A4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFC78312),
                size: 23,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pesanan akan dicatat terlebih dahulu. '
                  'Pembayaran diselesaikan langsung di kasir.',
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    height: 1.5,
                    color: AppColors.dark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            setState(() {
              cashierConfirmation = !cashierConfirmation;
            });
          },
          child: Row(
            children: [
              Checkbox(
                value: cashierConfirmation,
                activeColor: AppColors.dark,
                onChanged: (value) {
                  setState(() {
                    cashierConfirmation = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  'Saya akan melakukan pembayaran di kasir.',
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    color: AppColors.dark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SYARAT DAN KEBIJAKAN PRIVASI
  // ============================================================

  Widget _buildTerms() {
    return InkWell(
      onTap: () {
        setState(() {
          agreeTerms = !agreeTerms;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: agreeTerms,
            activeColor: AppColors.dark,
            onChanged: (value) {
              setState(() {
                agreeTerms = value ?? false;
              });
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 11),
              child: Text(
                'Saya menyetujui syarat, ketentuan, '
                'dan kebijakan privasi.',
                style: GoogleFonts.poppins(
                  fontSize: 9.5,
                  height: 1.4,
                  color: AppColors.dark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BAGIAN BAWAH: TOTAL DAN BAYAR SEKARANG
  // ============================================================

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE7E3DF))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Pembayaran',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatPrice(widget.totalPayment),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: isNavigating ? null : _validatePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dark,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isNavigating ? 'Memuat...' : 'Bayar Sekarang',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HALAMAN UTAMA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Nama Lengkap*'),
                    const SizedBox(height: 7),
                    _buildTextField(
                      controller: nameController,
                      hintText: 'Masukkan nama lengkap',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Email Customer*'),
                    const SizedBox(height: 7),
                    _buildTextField(
                      controller: emailController,
                      hintText: 'Masukkan email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    if (isDineIn) ...[
                      const SizedBox(height: 16),
                      _buildLabel('Nomor Meja*'),
                      const SizedBox(height: 7),
                      _buildTextField(
                        controller: tableController,
                        hintText: 'Contoh: 12',
                        icon: Icons.table_restaurant_outlined,
                      ),
                    ],
                    const SizedBox(height: 22),
                    _buildLabel('Anda memesan di'),
                    const SizedBox(height: 8),
                    _buildStoreLocation(),
                    const SizedBox(height: 24),
                    _buildLabel('Metode Pembayaran'),
                    const SizedBox(height: 9),
                    _buildPaymentSelector(),
                    const SizedBox(height: 24),
                    _buildLabel('Selesaikan Pembayaran'),
                    const SizedBox(height: 9),
                    if (selectedPayment == 'online')
                      _buildOnlinePayment()
                    else
                      _buildCashierPayment(),
                    const SizedBox(height: 14),
                    _buildTerms(),
                  ],
                ),
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }
}
