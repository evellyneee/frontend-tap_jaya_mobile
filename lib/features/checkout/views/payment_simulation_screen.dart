import 'dart:async';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tap_jaya_mobile/features/cart/models/cart_item.dart';
import 'package:tap_jaya_mobile/features/checkout/repositories/checkout_repository.dart';
import 'package:tap_jaya_mobile/features/orders/services/simulated_payment_service.dart';
import 'package:tap_jaya_mobile/features/orders/viewmodels/order_session_store.dart';

class PaymentSimulationScreen extends StatefulWidget {
  final String paymentMethod;
  final String customerName;
  final String customerEmail;
  final String orderType;
  final String tableNumber;
  final int totalPayment;
  final List<CartItem> orderItems;
  final bool isCartCheckout;

  const PaymentSimulationScreen({
    super.key,
    required this.paymentMethod,
    required this.customerName,
    required this.customerEmail,
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

class _PaymentSimulationScreenState extends State<PaymentSimulationScreen> {
  final CheckoutRepository _checkout = CheckoutRepository();

  final SimulatedPaymentService _payment = const SimulatedPaymentService();

  String? _orderNumber;
  String? _error;

  int? _serverTotal;

  bool _creating = true;
  bool _paying = false;
  bool _paid = false;
  bool _recorded = false;

  late final DateTime _createdAt;
  DateTime? _paidAt;

  bool get _isQris => widget.paymentMethod == 'online';

  int get _total => _serverTotal ?? widget.totalPayment;

  @override
  void initState() {
    super.initState();
    _createdAt = DateTime.now();
    _createOrder();
  }

  Future<void> _createOrder() async {
    setState(() {
      _creating = true;
      _error = null;
    });

    try {
      final result = await _checkout.createQrisOrder(
        customerName: widget.customerName,
        customerEmail: widget.customerEmail,
        orderType: widget.orderType,
        tableNumber: widget.tableNumber,
        totalPayment: widget.totalPayment,
        orderItems: widget.orderItems,
      );

      if (!mounted) return;

      setState(() {
        _orderNumber = result.orderNumber;
        _serverTotal = result.total;
        _creating = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _creating = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _completeSimulatedPayment() async {
    if (_paying || _paid) return;

    final number = _orderNumber;

    if (number == null || number.isEmpty) {
      _showError('Nomor pesanan belum tersedia.');
      return;
    }

    setState(() {
      _paying = true;
      _error = null;
    });

    try {
      final result = await _payment.completePayment(orderNumber: number);

      if (result['paymentStatus'] != 'paid') {
        throw Exception('Backend belum mengonfirmasi pembayaran.');
      }

      if (!mounted) return;

      final now = DateTime.now();

      if (!_recorded) {
        final sessionOrder = SessionOrder(
          id: number,
          customerName: widget.customerName,
          orderType: widget.orderType,
          tableNumber: widget.tableNumber,
          paymentMethod: widget.paymentMethod,
          totalPayment: _total,
          createdAt: _createdAt,
          paidAt: now,
          items: widget.orderItems.map(SessionOrderItem.fromCartItem).toList(),
        );

        OrderSessionStore.instance.addOrder(sessionOrder);

        _recorded = true;
      }

      setState(() {
        _paid = true;
        _paidAt = now;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
      });

      _showError('Pembayaran gagal: $error');
    } finally {
      if (mounted) {
        setState(() {
          _paying = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  String _rupiah(int amount) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    return 'Rp$formatted';
  }

  Widget _text(
    String value, {
    double size = 12,
    FontWeight weight = FontWeight.normal,
    Color color = const Color(0xFF222222),
  }) {
    return Text(
      value,
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight,
        color: color,
      ),
    );
  }

  Widget _button(String label, VoidCallback? action) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: action,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF202020),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: _text(
          label,
          size: 11,
          weight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _infoBox(String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4E0DC)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            description,
            style: GoogleFonts.poppins(fontSize: 10, height: 1.8),
          ),
        ],
      ),
    );
  }

  Widget _qrisPage() {
    final number = _orderNumber!;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E1DC)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              BarcodeWidget(
                barcode: Barcode.qrCode(),
                data: 'TAPJAYA-DEMO|$number|$_total',
                width: 155,
                height: 155,
              ),
              const SizedBox(height: 6),
              _text('QRIS', size: 9),
            ],
          ),
        ),
        const SizedBox(height: 19),
        _text('Total Pembayaran', size: 11, color: Colors.grey),
        const SizedBox(height: 4),
        _text(_rupiah(_total), size: 20, weight: FontWeight.bold),
        const SizedBox(height: 7),
        _text('Nomor Pesanan: $number', size: 10, color: Colors.grey),
        const SizedBox(height: 25),
        _infoBox(
          'Cara Pembayaran',
          'Pembayaran QRIS ini merupakan simulasi proyek.\n'
              '1. Pastikan nominal pesanan sudah benar.\n'
              '2. Klik Periksa Status Pembayaran satu kali.\n'
              '3. Pembayaran otomatis diselesaikan oleh sistem.\n'
              '4. Pesanan tercatat di backend dan website admin.',
        ),
        const SizedBox(height: 19),
        _button(
          _paying ? 'Memproses Pembayaran...' : 'Periksa Status Pembayaran',
          _paying ? null : _completeSimulatedPayment,
        ),
        const SizedBox(height: 9),
        _text(
          _paying
              ? 'Status pembayaran: processing'
              : 'Status pembayaran: pending',
          size: 9,
          color: Colors.grey,
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          _text(_error!, size: 10, color: Colors.red),
        ],
      ],
    );
  }

  Widget _cashierPage() {
    return Column(
      children: [
        _text('Kode Pembayaran Kasir', size: 16, weight: FontWeight.bold),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          color: Colors.white,
          child: BarcodeWidget(
            barcode: Barcode.code128(),
            data: _orderNumber!,
            width: 240,
            height: 85,
          ),
        ),
        const SizedBox(height: 15),
        _text('Nomor Pesanan: ${_orderNumber!}', size: 11),
        const SizedBox(height: 10),
        _text(_rupiah(_total), size: 21, weight: FontWeight.bold),
        const SizedBox(height: 24),
        _infoBox(
          'Pembayaran di Kasir',
          'Tunjukkan nomor pesanan kepada kasir. '
              'Metode ini tetap menunggu konfirmasi '
              'pembayaran dari kasir.',
        ),
      ],
    );
  }

  Widget _successPage() {
    return Column(
      children: [
        const SizedBox(height: 28),
        const Icon(Icons.check_circle, size: 80, color: Color(0xFF16A765)),
        const SizedBox(height: 14),
        _text('Pembayaran Berhasil', size: 21, weight: FontWeight.bold),
        const SizedBox(height: 10),
        _text(
          'Pembayaran simulasi telah dikonfirmasi '
          'oleh backend TAP JAYA.',
          size: 12,
        ),
        const SizedBox(height: 25),
        _infoBox(
          'Detail Pesanan',
          'Nomor Pesanan: ${_orderNumber!}\n'
              'Nama Pelanggan: ${widget.customerName}\n'
              'Jenis Pesanan: ${widget.orderType}\n'
              'Total: ${_rupiah(_total)}\n'
              'Status Pembayaran: paid\n'
              'Waktu: ${_paidAt?.toLocal() ?? "-"}',
        ),
        const SizedBox(height: 18),
        _text(
          'Pesanan telah tersimpan di MySQL dan '
          'tersedia untuk diambil oleh website admin.',
          size: 11,
          color: Colors.grey,
        ),
        const SizedBox(height: 20),
        _button('Selesai', () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }),
      ],
    );
  }

  @override
  void dispose() {
    _checkout.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: _text(
          _paid
              ? 'Konfirmasi Pembayaran'
              : _isQris
              ? 'QRIS'
              : 'Pembayaran Kasir',
          size: 15,
          weight: FontWeight.w600,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFAF9F6),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: _creating
            ? const Center(child: CircularProgressIndicator())
            : _orderNumber == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _text(
                        _error ?? 'Gagal membuat pesanan.',
                        color: Colors.red,
                      ),
                      const SizedBox(height: 20),
                      _button('Coba Lagi', _createOrder),
                    ],
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(23, 20, 23, 30),
                child: _paid
                    ? _successPage()
                    : _isQris
                    ? _qrisPage()
                    : _cashierPage(),
              ),
      ),
    );
  }
}
