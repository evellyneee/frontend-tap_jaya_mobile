import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import 'cart_item_edit_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int mangoQuantity = 1;
  int cirengQuantity = 1;

  bool mangoSelected = true;
  bool cirengSelected = true;

  final int mangoPrice = 24545;
  final int cirengPrice = 15455;

  String formatPrice(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  int get selectedCount {
    int count = 0;

    if (mangoSelected) {
      count += mangoQuantity;
    }

    if (cirengSelected) {
      count += cirengQuantity;
    }

    return count;
  }

  int get totalPrice {
    int total = 0;

    if (mangoSelected) {
      total += mangoPrice * mangoQuantity;
    }

    if (cirengSelected) {
      total += cirengPrice * cirengQuantity;
    }

    return total;
  }

  Future<void> _editMango() async {
    final int? result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => CartItemEditScreen(
          productName: 'Milkshake Sweet Mango',
          imagePath: 'assets/images/milkshake_sweet_mango.png',
          unitPrice: mangoPrice,
          initialQuantity: mangoQuantity,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        mangoQuantity = result;
      });
    }
  }

  Future<void> _editCireng() async {
    final int? result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => CartItemEditScreen(
          productName: 'Cireng',
          imagePath: 'assets/images/cireng.png',
          unitPrice: cirengPrice,
          initialQuantity: cirengQuantity,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        cirengQuantity = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool allSelected = mangoSelected && cirengSelected;

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                children: [
                  _buildCartItem(
                    imagePath: 'assets/images/milkshake_sweet_mango.png',
                    name: 'Milkshake Sweet Mango',
                    price: mangoPrice,
                    quantity: mangoQuantity,
                    selected: mangoSelected,
                    onChanged: (value) {
                      setState(() {
                        mangoSelected = value ?? false;
                      });
                    },
                    onEdit: _editMango,
                  ),

                  const SizedBox(height: 14),

                  _buildCartItem(
                    imagePath: 'assets/images/cireng.png',
                    name: 'Cireng',
                    price: cirengPrice,
                    quantity: cirengQuantity,
                    selected: cirengSelected,
                    onChanged: (value) {
                      setState(() {
                        cirengSelected = value ?? false;
                      });
                    },
                    onEdit: _editCireng,
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 18, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE7E3DF))),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Checkbox(
                      value: allSelected,
                      activeColor: AppColors.dark,
                      onChanged: (value) {
                        setState(() {
                          mangoSelected = value ?? false;

                          cirengSelected = value ?? false;
                        });
                      },
                    ),

                    Text(
                      'Semua',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.dark,
                      ),
                    ),

                    const Spacer(),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: AppColors.grey,
                          ),
                        ),

                        Text(
                          formatPrice(totalPrice),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 10),

                    SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: selectedCount == 0 ? null : () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dark,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.lightGrey,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Checkout ($selectedCount)',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
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
      height: 62,
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
            'Keranjang Saya (2)',
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

  Widget _buildCartItem({
    required String imagePath,
    required String name,
    required int price,
    required int quantity,
    required bool selected,
    required ValueChanged<bool?> onChanged,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDEDAD5)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: selected,
            activeColor: AppColors.dark,
            onChanged: onChanged,
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset(
              imagePath,
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
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  formatPrice(price),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Text(
                      '$quantity item',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: AppColors.grey,
                      ),
                    ),

                    const Spacer(),

                    TextButton(
                      onPressed: onEdit,
                      child: Text(
                        'Ubah',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
