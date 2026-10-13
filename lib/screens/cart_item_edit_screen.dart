import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../models/cart_item.dart';
import '../services/cart_store.dart';

class CartItemEditScreen extends StatefulWidget {
  final String productName;
  final String imagePath;
  final int unitPrice;
  final int initialQuantity;

  final String? itemId;
  final String initialSize;
  final bool initialExtraShot;
  final bool initialLessIce;
  final bool initialLessSugar;
  final String initialNote;

  const CartItemEditScreen({
    super.key,
    required this.productName,
    required this.imagePath,
    required this.unitPrice,
    required this.initialQuantity,
    this.itemId,
    this.initialSize = '',
    this.initialExtraShot = false,
    this.initialLessIce = false,
    this.initialLessSugar = false,
    this.initialNote = '',
  });

  @override
  State<CartItemEditScreen> createState() => _CartItemEditScreenState();
}

class _CartItemEditScreenState extends State<CartItemEditScreen> {
  late int quantity;

  late String selectedSize;

  late bool extraShot;
  late bool lessIce;
  late bool lessSugar;

  late TextEditingController noteController;

  bool get supportsCustomization {
    return widget.productName == 'Kopi Susu Berjaya di Bali' ||
        widget.initialSize.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    quantity = widget.initialQuantity;

    selectedSize = widget.initialSize.isNotEmpty ? widget.initialSize : 'Large';

    extraShot = widget.initialExtraShot;
    lessIce = widget.initialLessIce;
    lessSugar = widget.initialLessSugar;

    noteController = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    noteController.dispose();

    super.dispose();
  }

  int get basePrice {
    if (widget.productName == 'Kopi Susu Berjaya di Bali') {
      if (selectedSize == 'Regular') {
        return 24545;
      }

      return 30000;
    }

    return widget.unitPrice;
  }

  int get additionalPrice {
    if (!supportsCustomization) {
      return 0;
    }

    int total = 0;

    if (extraShot) {
      total += 5000;
    }

    return total;
  }

  int get currentUnitPrice {
    if (supportsCustomization) {
      return basePrice + additionalPrice;
    }

    return widget.unitPrice;
  }

  int get totalPrice {
    return currentUnitPrice * quantity;
  }

  String formatPrice(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  String get updatedItemId {
    if (widget.productName == 'Kopi Susu Berjaya di Bali') {
      final String note = noteController.text.trim();

      return [
        'kopi-susu-berjaya-di-bali',
        selectedSize,
        extraShot ? 'extra-shot' : 'no-extra-shot',
        lessIce ? 'less-ice' : 'normal-ice',
        lessSugar ? 'less-sugar' : 'normal-sugar',
        note,
      ].join('|');
    }

    return widget.itemId ??
        widget.productName.toLowerCase().replaceAll(' ', '-');
  }

  void _saveChanges() {
    /*
      Mode lama dipertahankan sementara agar
      file lain yang belum direvisi tetap aman.
    */
    if (widget.itemId == null) {
      Navigator.pop(context, quantity);

      return;
    }

    final CartItem updatedItem = CartItem(
      id: updatedItemId,
      productName: widget.productName,
      imagePath: widget.imagePath,
      unitPrice: currentUnitPrice,
      quantity: quantity,
      size: supportsCustomization ? selectedSize : '',
      extraShot: supportsCustomization && extraShot,
      lessIce: supportsCustomization && lessIce,
      lessSugar: supportsCustomization && lessSugar,
      note: supportsCustomization ? noteController.text.trim() : '',
    );

    CartStore.instance.updateItem(
      currentId: widget.itemId!,
      updatedItem: updatedItem,
    );

    Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    if (widget.itemId == null) {
      return;
    }

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Hapus Pesanan?',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus ${widget.productName} dari keranjang?',
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.5,
              color: AppColors.dark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                'Hapus',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    CartStore.instance.removeItem(widget.itemId!);

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImage(),

                    const SizedBox(height: 18),

                    _buildProductInformation(),

                    if (supportsCustomization) ...[
                      const SizedBox(height: 22),

                      _buildSizeSection(),

                      const SizedBox(height: 20),

                      _buildAdditionalSection(),

                      const SizedBox(height: 20),

                      _buildNoteSection(),
                    ],

                    const SizedBox(height: 22),

                    _buildQuantitySection(),

                    const SizedBox(height: 22),

                    _buildTotalSection(),

                    const SizedBox(height: 28),

                    _buildSaveButton(),

                    if (widget.itemId != null) ...[
                      const SizedBox(height: 12),

                      _buildDeleteButton(),
                    ],
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
                size: 26,
                color: AppColors.dark,
              ),
            ),
          ),

          Text(
            'Ubah Pesanan',
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

  Widget _buildProductImage() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          widget.imagePath,
          width: 180,
          height: 180,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProductInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2DED9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.productName,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            formatPrice(currentUnitPrice),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.red,
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
        _sectionTitle('Pilih Ukuran*'),

        const SizedBox(height: 9),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2DED9)),
          ),
          child: Column(
            children: [
              _sizeOption(
                value: 'Regular',
                label: 'Regular (R)',
                price: 'Rp 24.545',
              ),

              const Divider(height: 10, color: Color(0xFFEEEAE6)),

              _sizeOption(
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

  Widget _sizeOption({
    required String value,
    required String label,
    required String price,
  }) {
    final bool selected = selectedSize == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedSize = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 21,
              color: AppColors.dark,
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: AppColors.dark,
                ),
              ),
            ),

            Text(
              price,
              style: GoogleFonts.poppins(
                fontSize: 11,
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
        _sectionTitle('Additional (Opsional)'),

        const SizedBox(height: 9),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2DED9)),
          ),
          child: Column(
            children: [
              _additionalOption(
                label: 'Extra Shot Espresso',
                price: '+Rp 5.000',
                value: extraShot,
                onChanged: (value) {
                  setState(() {
                    extraShot = value;
                  });
                },
              ),

              _additionalOption(
                label: 'Less Ice',
                price: '+Rp 0',
                value: lessIce,
                onChanged: (value) {
                  setState(() {
                    lessIce = value;
                  });
                },
              ),

              _additionalOption(
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

  Widget _additionalOption({
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
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              size: 21,
              color: AppColors.dark,
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.dark),
              ),
            ),

            Text(
              price,
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.dark),
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
        _sectionTitle('Catatan Pesanan'),

        const SizedBox(height: 9),

        TextField(
          controller: noteController,
          maxLines: 3,
          onChanged: (_) {
            setState(() {});
          },
          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.dark),
          decoration: InputDecoration(
            hintText: 'Contoh: sedikit es, tanpa sedotan...',
            hintStyle: GoogleFonts.poppins(fontSize: 10, color: AppColors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2DED9)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2DED9)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.dark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Jumlah Pesanan'),

        const SizedBox(height: 9),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2DED9)),
          ),
          child: Row(
            children: [
              _quantityButton(
                icon: Icons.remove,
                enabled: quantity > 1,
                onTap: () {
                  if (quantity <= 1) {
                    return;
                  }

                  setState(() {
                    quantity--;
                  });
                },
              ),

              Expanded(
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
              ),

              _quantityButton(
                icon: Icons.add,
                enabled: true,
                onTap: () {
                  setState(() {
                    quantity++;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2DED9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.grey),
              ),

              const SizedBox(height: 2),

              Text(
                '$quantity item',
                style: GoogleFonts.poppins(fontSize: 10, color: AppColors.grey),
              ),
            ],
          ),

          Text(
            formatPrice(totalPrice),
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Simpan Perubahan',
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _confirmDelete,
        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.red),
        label: Text(
          'Hapus dari Keranjang',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.red,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFF5EDE5) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: enabled ? AppColors.dark : AppColors.grey),
      ),
    );
  }
}
