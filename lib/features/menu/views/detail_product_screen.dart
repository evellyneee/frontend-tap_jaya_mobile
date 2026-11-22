
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tap_jaya_mobile/core/constants/app_colors.dart';
import 'package:tap_jaya_mobile/features/cart/models/cart_item.dart';
import 'package:tap_jaya_mobile/features/cart/viewmodels/cart_viewmodel.dart';
import 'package:tap_jaya_mobile/features/orders/views/order_screen.dart';

// =====================================
// MODEL ADD-ON SEMENTARA
// =====================================

class _ProductAddon {
  final int id;
  final String name;
  final int price;

  const _ProductAddon({
    required this.id,
    required this.name,
    required this.price,
  });
}

// =====================================
// DETAIL PRODUCT SCREEN
// =====================================

class DetailProductScreen extends StatefulWidget {
  final ValueChanged<int>? onAddToCart;

  const DetailProductScreen({
    super.key,
    this.onAddToCart,
  });

  @override
  State<DetailProductScreen> createState() =>
      _DetailProductScreenState();
}

class _DetailProductScreenState
    extends State<DetailProductScreen> {
  // =====================================
  // IDENTITAS PRODUK
  // =====================================

  static const int productId = 12;

  static const String productName =
      'Kopi Susu Berjaya di Bali';

  static const String productImage =
      'assets/images/kopi_susu_bali.png';

  // =====================================
  // HARGA SEMENTARA
  // =====================================

  // Sesuaikan dengan products.price dan
  // products.price_large di MySQL.
  //
  // Harga ini belum diambil dari API.

  static const int regularPrice = 24545;
  static const int largePrice = 30000;

  // =====================================
  // ADD-ON SEMENTARA
  // =====================================

  // ID dan harga wajib diverifikasi terhadap
  // product_addons dan product_addon_options.
  //
  // Jangan menganggap daftar ini sebagai
  // data yang sudah dibaca dari database.

  static const List<_ProductAddon> availableAddons = [
    _ProductAddon(
      id: 1,
      name: 'Extra Shot Espresso',
      price: 5000,
    ),
    _ProductAddon(
      id: 3,
      name: 'Caramel Syrup',
      price: 3000,
    ),
    _ProductAddon(
      id: 4,
      name: 'Vanilla Syrup',
      price: 3000,
    ),
    _ProductAddon(
      id: 5,
      name: 'Hazelnut Syrup',
      price: 3000,
    ),
  ];

  // =====================================
  // STATE PRODUK
  // =====================================

  String selectedSize = 'Large';

  final Set<int> selectedAddonIds = <int>{};

  bool lessIce = false;
  bool lessSugar = true;

  int quantity = 1;

  final TextEditingController noteController =
      TextEditingController();

  // =====================================
  // HARGA
  // =====================================

  int get basePrice {
    switch (selectedSize) {
      case 'Large':
        return largePrice;
      case 'Regular':
      default:
        return regularPrice;
    }
  }

  int get addonTotal {
    int total = 0;

    for (final addon in availableAddons) {
      if (selectedAddonIds.contains(addon.id)) {
        total += addon.price;
      }
    }

    return total;
  }

  int get unitPrice => basePrice + addonTotal;

  int get totalPrice => unitPrice * quantity;

  // =====================================
  // EXTRA SHOT
  // =====================================

  bool get extraShot {
    return availableAddons.any(
      (addon) =>
          addon.name == 'Extra Shot Espresso' &&
          selectedAddonIds.contains(addon.id),
    );
  }

  // =====================================
  // FORMAT HARGA
  // =====================================

  String formatPrice(int value) {
    final formatted = value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );

    return 'Rp $formatted';
  }

  // =====================================
  // ID UNIK KERANJANG
  // =====================================

  String get cartItemId {
    final addonIds = selectedAddonIds.toList()..sort();

    return [
      productId.toString(),
      selectedSize,
      addonIds.join(','),
      extraShot ? 'extra-shot' : 'no-extra-shot',
      lessIce ? 'less-ice' : 'normal-ice',
      lessSugar ? 'less-sugar' : 'normal-sugar',
      noteController.text.trim(),
    ].join('|');
  }

  // =====================================
  // BUAT CART ITEM
  // =====================================

  CartItem createOrderItem() {
    final addonIds = selectedAddonIds.toList()..sort();

    return CartItem(
      id: cartItemId,
      productId: productId,
      productName: productName,
      imagePath: productImage,
      unitPrice: unitPrice,
      quantity: quantity,
      size: selectedSize,
      addonIds: addonIds,
      extraShot: extraShot,
      lessIce: lessIce,
      lessSugar: lessSugar,
      note: noteController.text.trim(),
    );
  }

  // =====================================
  // TAMBAH KE KERANJANG
  // =====================================

  void addToCart() {
    final item = createOrderItem();

    CartViewModel.instance.addItem(item);

    widget.onAddToCart?.call(quantity);

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

  // =====================================
  // BELI SEKARANG
  // =====================================

  void buyNow() {
    final item = createOrderItem();

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

  // =====================================
  // DISPOSE
  // =====================================

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  // =====================================
  // BUILD
  // =====================================

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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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

  // =====================================
  // HEADER
  // =====================================

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

  // =====================================
  // GAMBAR PRODUK
  // =====================================

  Widget _buildProductImage() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          productImage,
          width: 185,
          height: 185,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // =====================================
  // INFORMASI PRODUK
  // =====================================

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
            productName,
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
            'Perpaduan espresso mantap, susu creamy, '
            'dan gula aren khas Bali dengan cita rasa '
            'manis yang pas.',
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

  // =====================================
  // PILIH UKURAN
  // =====================================

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
                price: formatPrice(regularPrice),
              ),
              _buildSizeOption(
                value: 'Large',
                label: 'Large (L)',
                price: formatPrice(largePrice),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================
  // PILIHAN UKURAN
  // =====================================

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
        padding: const EdgeInsets.symmetric(
          vertical: 4,
        ),
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

  // =====================================
  // PILIHAN ADD-ON
  // =====================================

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
              for (final addon in availableAddons)
                _buildAdditionalOption(
                  label: addon.name,
                  price:
                      '+${formatPrice(addon.price)}',
                  value: selectedAddonIds.contains(
                    addon.id,
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value) {
                        selectedAddonIds.add(addon.id);
                      } else {
                        selectedAddonIds.remove(addon.id);
                      }
                    });
                  },
                ),
              const Divider(
                color: Color(0xFFE5E0DB),
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

  // =====================================
  // OPSI TAMBAHAN
  // =====================================

  Widget _buildAdditionalOption({
    required String label,
    required String price,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 6,
        ),
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

  // =====================================
  // CATATAN PESANAN
  // =====================================

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
          maxLength: 1000,
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
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE5E0DB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFE5E0DB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.dark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =====================================
  // TOTAL HARGA
  // =====================================

  Widget _buildTotal() {
    return Text(
      'Total: ${formatPrice(totalPrice)} '
      '($quantity Item)',
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
    );
  }

  // =====================================
  // TOMBOL AKSI
  // =====================================

  Widget _buildBottomActions() {
    return Row(
      children: [
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
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
                borderRadius:
                    BorderRadius.circular(9),
              ),
            ),
            child: const Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
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
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(9),
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
