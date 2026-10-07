import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import 'customer_information_screen.dart';

class OrderScreen extends StatefulWidget {
  final int subtotal;

  const OrderScreen({super.key, required this.subtotal});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String selectedOrderType = 'Makan di Tempat';

  String formatPrice(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  int get tax {
    return (widget.subtotal * 0.10).round();
  }

  int get serviceFee {
    return 2000;
  }

  int get totalPayment {
    return widget.subtotal + tax + serviceFee;
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jenis Pesanan',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _buildOrderTypeSelector(),

                    const SizedBox(height: 24),

                    _buildOrderTypeInformation(),

                    const SizedBox(height: 28),

                    Text(
                      'Ringkasan Pembayaran',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2DED9)),
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
                            child: Divider(height: 1, color: Color(0xFFE2DED9)),
                          ),

                          _buildPaymentRow(
                            title: 'Total Pembayaran',
                            value: formatPrice(totalPayment),
                            bold: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
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
                    ),
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
              icon: const Icon(Icons.arrow_back, color: AppColors.dark),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.dark : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: active ? Colors.white : AppColors.dark,
              ),

              const SizedBox(width: 6),

              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppColors.dark,
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
    final bool dineIn = selectedOrderType == 'Makan di Tempat';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2DED9)),
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
              dineIn ? Icons.restaurant_outlined : Icons.shopping_bag_outlined,
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

          const Icon(Icons.check_circle, color: AppColors.red, size: 22),
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
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            color: AppColors.dark,
          ),
        ),

        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: bold ? 13 : 11,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE7E3DF))),
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
                  builder: (context) => CustomerInformationScreen(
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
