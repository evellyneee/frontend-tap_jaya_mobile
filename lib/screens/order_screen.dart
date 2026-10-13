
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../models/cart_item.dart';
import '../services/cart_store.dart';
import 'customer_information_screen.dart';

class OrderScreen extends StatefulWidget {
  final int subtotal;

  // Untuk Beli Sekarang: dikirim dari Detail Menu.
  // Untuk Checkout Keranjang: otomatis membaca item terpilih.
  final List<CartItem>? orderItems;

  const OrderScreen({
    super.key,
    required this.subtotal,
    this.orderItems,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String selectedOrderType = 'Makan di Tempat';

  late final List<CartItem> itemsToOrder;

  @override
  void initState() {
    super.initState();

    // Simpan salinan daftar item saat halaman Order dibuka.
    // Beli Sekarang tidak mengambil isi keranjang.
    // Checkout dari keranjang hanya mengambil item dicentang.
    itemsToOrder = List<CartItem>.from(
      widget.orderItems ??
          CartStore.instance.items.where(
            (item) => item.isSelected,
          ),
    );
  }

  String formatPrice(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  int get tax => (widget.subtotal * 0.10).round();

  int get serviceFee => 2000;

  int get totalPayment =>
      widget.subtotal + tax + serviceFee;

  List<String> getItemDetails(CartItem item) {
    final List<String> details = [];

    if (item.size.isNotEmpty) {
      details.add('Ukuran: ${item.size}');
    }

    if (item.extraShot) {
      details.add('Extra Shot Espresso');
    }

    if (item.lessIce) {
      details.add('Less Ice');
    }

    if (item.lessSugar) {
      details.add('Less Sugar');
    }

    // Extra Sambal tersimpan di note pada model lama.
    // Pisahkan agar tampil sebagai additional.
    if (item.productName == 'Cireng' &&
        item.note.contains('Extra Sambal (+Rp 2.000)')) {
      details.add('Extra Sambal (+Rp 2.000)');
    }

    return details;
  }

  String getCustomerNote(CartItem item) {
    String note = item.note.trim();

    if (item.productName == 'Cireng') {
      note = note
          .replaceFirst('Extra Sambal (+Rp 2.000)', '')
          .replaceFirst(RegExp(r'^\s*\|\s*'), '')
          .trim();
    }

    return note;
  }

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
                padding: const EdgeInsets.fromLTRB(
                  20, 12, 20, 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Jenis Pesanan'),
                    const SizedBox(height: 10),
                    _buildOrderTypeSelector(),

                    const SizedBox(height: 24),
                    _buildOrderTypeInformation(),

                    const SizedBox(height: 24),

                    // BAGIAN BARU
                    _buildSectionTitle('Ringkasan Pesanan'),
                    const SizedBox(height: 10),
                    _buildOrderSummary(),

                    const SizedBox(height: 28),

                    _buildSectionTitle('Ringkasan Pembayaran'),
                    const SizedBox(height: 10),
                    _buildPaymentSummary(),

                    const SizedBox(height: 24),
                    _buildInformationBox(),
                  ],
                ),
              ),
            ),

            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.dark,
              ),
            ),
          ),
          Text(
            'Order',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECE7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildOrderTypeButton(
            title: 'Makan di Tempat',
            icon: Icons.restaurant_outlined,
          ),
          _buildOrderTypeButton(
            title: 'Bawa Pulang',
            icon: Icons.shopping_bag_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeButton({
    required String title,
    required IconData icon,
  }) {
    final bool active = selectedOrderType == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedOrderType = title;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 6,
          ),
          decoration: BoxDecoration(
            color: active
                ? AppColors.dark
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: active
                    ? Colors.white
                    : AppColors.dark,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? Colors.white
                        : AppColors.dark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTypeInformation() {
    final bool dineIn =
        selectedOrderType == 'Makan di Tempat';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2DED9),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EDE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              dineIn
                  ? Icons.restaurant_outlined
                  : Icons.shopping_bag_outlined,
              color: AppColors.red,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedOrderType,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dineIn
                      ? 'Nikmati pesanan langsung di Kopi Jaya Begawan.'
                      : 'Pesanan akan dikemas agar mudah dibawa pulang.',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    height: 1.4,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: AppColors.red,
            size: 22,
          ),
        ],
      ),
    );
  }

  // RINGKASAN PESANAN BARU
  Widget _buildOrderSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2DED9),
        ),
      ),
      child: itemsToOrder.isEmpty
          ? Text(
              'Rincian menu tidak tersedia.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.grey,
              ),
            )
          : Column(
              children: [
                for (int i = 0; i < itemsToOrder.length; i++) ...[
                  if (i > 0) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      child: Divider(
                        height: 1,
                        color: Color(0xFFE2DED9),
                      ),
                    ),
                  ],
                  _buildOrderItem(itemsToOrder[i]),
                ],
              ],
            ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    final List<String> details = getItemDetails(item);
    final String customerNote = getCustomerNote(item);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                item.imagePath,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${item.quantity} item × ${formatPrice(item.unitPrice)}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.grey,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    formatPrice(
                      item.quantity * item.unitPrice,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        if (details.isNotEmpty) ...[
          const SizedBox(height: 10),

          Text(
            details.join(' • '),
            style: GoogleFonts.poppins(
              fontSize: 10,
              height: 1.5,
              color: AppColors.grey,
            ),
          ),
        ],

        if (customerNote.isNotEmpty) ...[
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F3EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.edit_note_outlined,
                      color: AppColors.dark,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Catatan Pesanan',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  customerNote,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.dark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
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
        children: [
          _buildPaymentRow(
            title: 'Subtotal Pesanan',
            value: formatPrice(widget.subtotal),
          ),
          const SizedBox(height: 14),
          _buildPaymentRow(
            title: 'PPN (10%)',
            value: formatPrice(tax),
          ),
          const SizedBox(height: 14),
          _buildPaymentRow(
            title: 'Biaya Layanan',
            value: formatPrice(serviceFee),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(
              height: 1,
              color: Color(0xFFE2DED9),
            ),
          ),
          _buildPaymentRow(
            title: 'Total Pembayaran',
            value: formatPrice(totalPayment),
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow({
    required String title,
    required String value,
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: bold ? 12 : 11,
            fontWeight: bold
                ? FontWeight.w600
                : FontWeight.w400,
            color: AppColors.dark,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: bold ? 13 : 11,
            fontWeight: bold
                ? FontWeight.w700
                : FontWeight.w500,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }

  Widget _buildInformationBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3EE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.red,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              selectedOrderType == 'Makan di Tempat'
                  ? 'Pesanan akan disajikan untuk dinikmati di Kopi Jaya Begawan.'
                  : 'Pesanan akan dikemas untuk dibawa pulang.',
              style: GoogleFonts.poppins(
                fontSize: 10,
                height: 1.5,
                color: AppColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE7E3DF),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CustomerInformationScreen(
                    orderType: selectedOrderType,
                    totalPayment: totalPayment,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dark,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Lanjut ke Informasi Pelanggan',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
