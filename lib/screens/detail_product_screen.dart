import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

class DetailProductScreen extends StatefulWidget {
  final ValueChanged<int> onAddToCart;

  const DetailProductScreen({
    super.key,
    required this.onAddToCart,
  });

  @override
  State<DetailProductScreen> createState() =>
      _DetailProductScreenState();
}

class _DetailProductScreenState
    extends State<DetailProductScreen> {
  String selectedSize = 'Large';

  bool extraShot = false;
  bool lessIce = false;
  bool lessSugar = true;

  int quantity = 3;

  final TextEditingController noteController =
      TextEditingController();

  int get basePrice {
    if (selectedSize == 'Regular') {
      return 24545;
    }

    return 30000;
  }

  int get additionalPrice {
    int total = 0;

    if (extraShot) {
      total += 5000;
    }

    return total;
  }

  int get totalPrice {
    return (basePrice + additionalPrice) * quantity;
  }

  String formatPrice(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  void addToCart() {
    widget.onAddToCart(quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.dark,
        content: Text(
          '$quantity item berhasil ditambahkan ke keranjang',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
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
                  20,
                  8,
                  20,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImage(),
                    const SizedBox(height: 20),
                    _buildProductInfo(),
                    const SizedBox(height: 20),
                    _buildSizeSection(),
                    const SizedBox(height: 18),
                    _buildAdditionalSection(),
                    const SizedBox(height: 18),
                    _buildNoteSection(),
                    const SizedBox(height: 18),
                    _buildTotal(),
                    const SizedBox(height: 18),
                    _buildBottomActions(),
                  ],
                ),
              ),
            ),
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
              icon: const Icon(
                Icons.arrow_back,
                size: 28,
                color: AppColors.dark,
              ),
            ),
          ),
          Text(
            'Detail Menu',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          'assets/images/kopi_susu_bali.png',
          width: 185,
          height: 185,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E0DB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kopi Susu Berjaya di Bali',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rp 30.000',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Perpaduan espresso mantap, susu creamy, dan gula aren khas Bali dengan cita rasa manis yang pas.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.4,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Ukuran*',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E0DB),
            ),
          ),
          child: Column(
            children: [
              _buildSizeOption(
                value: 'Regular',
                label: 'Regular (R)',
                price: 'Rp 24.545',
              ),
              _buildSizeOption(
                value: 'Large',
                label: 'Large (L)',
                price: 'Rp 30.000',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSizeOption({
    required String value,
    required String label,
    required String price,
  }) {
    final selected = selectedSize == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedSize = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              size: 20,
              color: AppColors.dark,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: AppColors.dark,
                ),
              ),
            ),
            Text(
              price,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional (Opsional)',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E0DB),
            ),
          ),
          child: Column(
            children: [
              _buildAdditionalOption(
                label: 'Extra Shot Espresso',
                price: '+Rp 5.000',
                value: extraShot,
                onChanged: (value) {
                  setState(() {
                    extraShot = value;
                  });
                },
              ),
              _buildAdditionalOption(
                label: 'Less Ice',
                price: '+Rp 0',
                value: lessIce,
                onChanged: (value) {
                  setState(() {
                    lessIce = value;
                  });
                },
              ),
              _buildAdditionalOption(
                label: 'Less Sugar',
                price: '+Rp 0',
                value: lessSugar,
                onChanged: (value) {
                  setState(() {
                    lessSugar = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalOption({
    required String label,
    required String price,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              value
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              size: 20,
              color: AppColors.dark,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.dark,
                ),
              ),
            ),
            Text(
              price,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catatan Pesanan',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: noteController,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.dark,
          ),
          decoration: InputDecoration(
            hintText:
                'Tambah catatan pesanan (misal: sedikit es)...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE5E0DB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE5E0DB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.dark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotal() {
    return Text(
      'Total: ${formatPrice(totalPrice)} ($quantity Item)',
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
    );
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: const Color(0xFFD8D3CE),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (quantity > 1) {
                    setState(() {
                      quantity--;
                    });
                  }
                },
                child: const Icon(
                  Icons.remove_circle_outline,
                  size: 21,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                '$quantity',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 7),
              GestureDetector(
                onTap: () {
                  setState(() {
                    quantity++;
                  });
                },
                child: const Icon(
                  Icons.add_circle_outline,
                  size: 21,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 90,
          height: 46,
          child: OutlinedButton(
            onPressed: addToCart,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white,
              side: const BorderSide(
                color: Color(0xFFD8D3CE),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 23,
                  color: AppColors.dark,
                ),
                SizedBox(width: 3),
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 25,
                  color: AppColors.dark,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: Text(
                'Beli Sekarang',
                maxLines: 1,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}