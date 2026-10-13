
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../models/cart_item.dart';
import '../services/cart_store.dart';
import 'order_screen.dart';

class DetailMilkshakeScreen extends StatefulWidget {
  const DetailMilkshakeScreen({super.key});

  @override
  State<DetailMilkshakeScreen> createState() =>
      _DetailMilkshakeScreenState();
}

class _DetailMilkshakeScreenState
    extends State<DetailMilkshakeScreen> {
  bool lessSugar = false;
  bool lessIce = false;
  int quantity = 1;

  final TextEditingController noteController =
      TextEditingController();

  static const int unitPrice = 24545;

  int get totalPrice => unitPrice * quantity;

  String formatPrice(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  String get cartItemId => [
        'milkshake-sweet-mango',
        lessSugar ? 'less-sugar' : 'normal-sugar',
        lessIce ? 'less-ice' : 'normal-ice',
        noteController.text.trim(),
      ].join('|');

  CartItem createOrderItem() {
    return CartItem(
      id: cartItemId,
      productName: 'Milkshake Sweet Mango',
      imagePath: 'assets/images/milkshake_sweet_mango.png',
      unitPrice: unitPrice,
      quantity: quantity,
      size: 'Large',
      extraShot: false,
      lessIce: lessIce,
      lessSugar: lessSugar,
      note: noteController.text.trim(),
    );
  }

  void addToCart() {
    CartStore.instance.addItem(createOrderItem());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.dark,
        duration: const Duration(seconds: 2),
        content: Text(
          '$quantity item berhasil ditambahkan ke keranjang',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void buyNow() {
    final CartItem item = createOrderItem();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderScreen(
          subtotal: totalPrice,
          orderItems: [item],
        ),
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImage(),
                    const SizedBox(height: 20),
                    _buildProductInfo(),
                    const SizedBox(height: 18),
                    _buildAdditionalSection(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNoteSection(),
                  const SizedBox(height: 18),
                  _buildTotal(),
                  const SizedBox(height: 18),
                  _buildBottomActions(),
                ],
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
              onPressed: () => Navigator.pop(context),
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
          'assets/images/milkshake_sweet_mango.png',
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
            'Milkshake Sweet Mango',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatPrice(unitPrice),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Perpaduan susu dan buah mangga yang segar.',
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
                label: 'Less Sugar',
                price: '+Rp 0',
                value: lessSugar,
                onChanged: (value) {
                  setState(() {
                    lessSugar = value;
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
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
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
          maxLines: 3,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.dark,
          ),
          decoration: InputDecoration(
            hintText:
                'Tambah catatan pesanan (misal: jangan terlalu manis)...',
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
              onPressed: buyNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dark,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
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
