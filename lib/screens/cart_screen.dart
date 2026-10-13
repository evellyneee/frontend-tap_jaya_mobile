import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../models/cart_item.dart';
import '../services/cart_store.dart';
import 'cart_item_edit_screen.dart';
import 'order_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartStore cartStore = CartStore.instance;

  @override
  void initState() {
    super.initState();

    cartStore.addListener(_refreshCart);
  }

  void _refreshCart() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  void dispose() {
    cartStore.removeListener(_refreshCart);

    super.dispose();
  }

  String formatPrice(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  Future<void> _editItem(CartItem item) async {
    final int? result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => CartItemEditScreen(
          productName: item.productName,
          imagePath: item.imagePath,
          unitPrice: item.unitPrice,
          initialQuantity: item.quantity,
        ),
      ),
    );

    if (result != null) {
      cartStore.updateQuantity(item.id, result);
    }
  }

  void _goToOrder() {
    if (cartStore.selectedQuantity == 0) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderScreen(subtotal: cartStore.selectedTotal),
      ),
    );
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
              child: cartStore.isEmpty ? _buildEmptyCart() : _buildCartList(),
            ),

            _buildBottomCheckout(),
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
            'Keranjang Saya (${cartStore.itemCount})',
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

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 70,
              color: AppColors.grey,
            ),

            const SizedBox(height: 18),

            Text(
              'Keranjang masih kosong',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Tambahkan menu yang ingin kamu pesan terlebih dahulu.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                height: 1.5,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      itemCount: cartStore.items.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 14);
      },
      itemBuilder: (context, index) {
        final CartItem item = cartStore.items[index];

        return _buildCartItem(item);
      },
    );
  }

  Widget _buildCartItem(CartItem item) {
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
            value: item.isSelected,
            activeColor: AppColors.dark,
            onChanged: (value) {
              cartStore.toggleItem(item.id, value ?? false);
            },
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(9),
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
                  formatPrice(item.unitPrice),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),

                if (item.size.isNotEmpty) ...[
                  const SizedBox(height: 4),

                  Text(
                    _buildCustomizationText(item),
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      height: 1.4,
                      color: AppColors.grey,
                    ),
                  ),
                ],

                const SizedBox(height: 6),

                Row(
                  children: [
                    Text(
                      '${item.quantity} item',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: AppColors.grey,
                      ),
                    ),

                    const Spacer(),

                    TextButton(
                      onPressed: () {
                        _editItem(item);
                      },
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

  String _buildCustomizationText(CartItem item) {
    final List<String> details = [];

    if (item.size.isNotEmpty) {
      details.add(item.size);
    }

    if (item.extraShot) {
      details.add('Extra Shot');
    }

    if (item.lessIce) {
      details.add('Less Ice');
    }

    if (item.lessSugar) {
      details.add('Less Sugar');
    }

    if (item.note.isNotEmpty) {
      details.add('Catatan: ${item.note}');
    }

    return details.join(' • ');
  }

  Widget _buildBottomCheckout() {
    final bool canCheckout = cartStore.selectedQuantity > 0;

    return Container(
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
              value: cartStore.allSelected,
              activeColor: AppColors.dark,
              onChanged: cartStore.isEmpty
                  ? null
                  : (value) {
                      cartStore.selectAll(value ?? false);
                    },
            ),

            Text(
              'Semua',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: cartStore.isEmpty ? AppColors.grey : AppColors.dark,
              ),
            ),

            const Spacer(),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: AppColors.grey,
                  ),
                ),

                Text(
                  formatPrice(cartStore.selectedTotal),
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
                onPressed: canCheckout ? _goToOrder : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dark,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.lightGrey,
                  disabledForegroundColor: AppColors.grey,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Checkout (${cartStore.selectedQuantity})',
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
    );
  }
}
