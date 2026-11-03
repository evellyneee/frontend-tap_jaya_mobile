import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../models/cart_item.dart';
import '../models/official_menu_catalog.dart';
import '../services/cart_store.dart';
import 'order_screen.dart';

/// Layar detail generik untuk produk katalog tambahan.
/// Mengikuti halaman detail menu lama: varian, tambahan opsional,
/// catatan, jumlah, total, tambah keranjang, dan beli sekarang.
class DetailOfficialScreen extends StatefulWidget {
  final OfficialProduct menu;
  final CartItem? editingItem;

  const DetailOfficialScreen({super.key, required this.menu, this.editingItem});

  @override
  State<DetailOfficialScreen> createState() => _DetailOfficialScreenState();
}

class _DetailOfficialScreenState extends State<DetailOfficialScreen> {
  late int selectedVariant;
  late int quantity;
  late bool lessIce;
  late bool lessSugar;
  late final Set<String> selectedAddons;
  late final TextEditingController noteController;

  bool get isDrink => const [
    'Signature',
    'Manual',
    'Black Series',
    'Milk Based Coffee',
    'Tea',
    'Milk Based',
    'Chocolate',
    'Milkshake',
  ].contains(widget.menu.category);

  bool get isCoffee => const [
    'Signature',
    'Manual',
    'Black Series',
    'Milk Based Coffee',
  ].contains(widget.menu.category);

  List<OfficialAddon> get availableAddons =>
      OfficialMenuCatalog.availableAddonsFor(widget.menu);

  bool get supportsLessIce =>
      isDrink &&
      !const [
        'Tubruk',
        'Tubruk Susu',
        'Chamomile',
        'Green Tea Jasmine',
        'Black Tea Jasmine',
      ].contains(widget.menu.name);

  bool get supportsLessSugar =>
      isDrink &&
      !const [
        'Tubruk',
        'Tubruk Susu',
        'Americano',
        'Chamomile',
        'Green Tea Jasmine',
        'Black Tea Jasmine',
      ].contains(widget.menu.name);

  OfficialVariant get variant => widget.menu.variants[selectedVariant];
  int? get basePrice => variant.price;
  int get addonPrice => availableAddons
      .where((addon) => selectedAddons.contains(addon.name))
      .fold<int>(0, (total, addon) => total + addon.price);
  int? get unitPrice => basePrice == null ? null : basePrice! + addonPrice;
  int? get totalPrice => unitPrice == null ? null : unitPrice! * quantity;

  bool get canOrder =>
      unitPrice != null &&
      (widget.menu.priceVerified ||
          OfficialMenuCatalog.allowHistoricalPrototypeOrder);

  @override
  void initState() {
    super.initState();
    final old = widget.editingItem;
    final match = widget.menu.variants.indexWhere((v) => v.label == old?.size);
    selectedVariant = match < 0 ? 0 : match;
    quantity = old?.quantity ?? 1;
    lessIce = old?.lessIce ?? false;
    lessSugar = old?.lessSugar ?? false;
    final parts = old?.id.split('|') ?? <String>[];
    selectedAddons = parts.length > 3 && parts[3].isNotEmpty
        ? parts[3].split(',').toSet()
        : <String>{};
    noteController = TextEditingController(
      text: parts.length >= 7 ? parts.skip(6).join('|') : '',
    );
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  CartItem _buildItem() {
    final extras = selectedAddons.toList()..sort();
    final note = noteController.text.trim();
    return CartItem(
      id: [
        'official',
        widget.menu.id,
        variant.label,
        extras.join(','),
        lessIce ? 'less-ice' : 'normal-ice',
        lessSugar ? 'less-sugar' : 'normal-sugar',
        note,
      ].join('|'),
      productName: widget.menu.name,
      imagePath: widget.menu.imagePath ?? 'assets/images/tap_jaya_logo.png',
      unitPrice: unitPrice!,
      quantity: quantity,
      size: variant.label,
      extraShot: extras.contains('Extra Shot'),
      lessIce: supportsLessIce && lessIce,
      lessSugar: supportsLessSugar && lessSugar,
      note: extras.isEmpty
          ? note
          : '${extras.join(', ')}${note.isEmpty ? '' : ' • $note'}',
    );
  }

  Future<void> _addToCart() async {
    if (!canOrder || !mounted) return;
    final item = _buildItem();
    if (widget.editingItem != null) {
      CartStore.instance.updateItem(
        currentId: widget.editingItem!.id,
        updatedItem: item,
      );
      Navigator.pop(context);
      return;
    }
    CartStore.instance.addItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.dark,
        content: Text(
          '$quantity item ditambahkan ke keranjang',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _buyNow() async {
    if (!canOrder || !mounted) return;
    final item = _buildItem();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OrderScreen(subtotal: totalPrice!, orderItems: [item]),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
    ),
  );

  Widget _panel(Widget child) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE5E0DB)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: child,
  );

  Widget _image() => Container(
    height: 185,
    width: 185,
    decoration: BoxDecoration(
      color: const Color(0xFFF5EDE5),
      borderRadius: BorderRadius.circular(14),
    ),
    clipBehavior: Clip.antiAlias,
    child: widget.menu.imagePath == null
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isDrink ? Icons.local_cafe_outlined : Icons.restaurant_outlined,
                color: AppColors.dark,
                size: 56,
              ),
              const SizedBox(height: 8),
              Text(
                'Foto belum tersedia',
                style: GoogleFonts.poppins(fontSize: 10, color: AppColors.grey),
              ),
            ],
          )
        : Image.asset(
            widget.menu.imagePath!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.image_not_supported_outlined, size: 48),
            ),
          ),
  );

  Widget _sizeSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle(isDrink ? 'Pilih Ukuran / Varian' : 'Pilih Porsi / Varian'),
      _panel(
        Column(
          children: [
            for (int i = 0; i < widget.menu.variants.length; i++)
              InkWell(
                onTap: widget.menu.variants[i].price == null
                    ? null
                    : () => setState(() => selectedVariant = i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      Icon(
                        i == selectedVariant
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: i == selectedVariant
                            ? AppColors.red
                            : AppColors.grey,
                        size: 21,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.menu.variants[i].label,
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ),
                      Text(
                        widget.menu.variants[i].price == null
                            ? 'Belum tersedia'
                            : OfficialMenuCatalog.formatRupiah(
                                widget.menu.variants[i].price!,
                              ),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.menu.variants[i].price == null
                              ? AppColors.grey
                              : AppColors.dark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );

  Widget _addonsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle('Tambahan (Opsional)'),
      _panel(
        Column(
          children: [
            for (final addon in availableAddons)
              CheckboxListTile(
                dense: true,
                value: selectedAddons.contains(addon.name),
                activeColor: AppColors.red,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  addon.name,
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                secondary: Text(
                  '+${OfficialMenuCatalog.formatRupiah(addon.price)}',
                  style: GoogleFonts.poppins(fontSize: 10),
                ),
                onChanged: (value) => setState(() {
                  if (value ?? false) {
                    selectedAddons.add(addon.name);
                  } else {
                    selectedAddons.remove(addon.name);
                  }
                }),
              ),
            if (supportsLessIce) ...[
              CheckboxListTile(
                dense: true,
                value: lessIce,
                activeColor: AppColors.red,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Kurangi Es',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                onChanged: (value) => setState(() => lessIce = value ?? false),
              ),
            ],
            if (supportsLessSugar) ...[
              CheckboxListTile(
                dense: true,
                value: lessSugar,
                activeColor: AppColors.red,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Kurangi Gula',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                onChanged: (value) =>
                    setState(() => lessSugar = value ?? false),
              ),
            ],
            if (!isDrink && availableAddons.isEmpty)
              Text(
                'Tidak ada tambahan untuk menu ini.',
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.grey),
              ),
          ],
        ),
      ),
    ],
  );

  Widget _noteSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle('Catatan Pesanan'),
      _panel(
        TextField(
          controller: noteController,
          maxLines: 3,
          maxLength: 160,
          style: GoogleFonts.poppins(fontSize: 12),
          decoration: InputDecoration(
            hintText: isDrink
                ? 'Contoh: tanpa es atau less sweet'
                : 'Contoh: saus dipisah atau tidak pedas',
            hintStyle: GoogleFonts.poppins(fontSize: 11, color: AppColors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
    ],
  );

  Widget _footer() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Jumlah', style: GoogleFonts.poppins(fontSize: 12)),
              const Spacer(),
              IconButton(
                onPressed: quantity > 1
                    ? () => setState(() => quantity--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '$quantity',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => quantity++),
                icon: const Icon(Icons.add_circle_outline),
              ),
              const SizedBox(width: 12),
              Text(
                totalPrice == null
                    ? 'Belum ada harga'
                    : OfficialMenuCatalog.formatRupiah(totalPrice!),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: canOrder ? _addToCart : null,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.dark),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text(
                    widget.editingItem == null
                        ? 'Tambah Keranjang'
                        : 'Simpan Perubahan',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.dark,
                    ),
                  ),
                ),
              ),
              if (widget.editingItem == null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canOrder ? _buyNow : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text(
                      'Beli Sekarang',
                      style: GoogleFonts.poppins(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final menu = widget.menu;
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        backgroundColor: AppColors.warmWhite,
        centerTitle: true,
        title: Text(
          widget.editingItem == null ? 'Detail Menu' : 'Ubah Pesanan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.dark,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: _image()),
                    const SizedBox(height: 16),
                    _panel(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            menu.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            menu.category,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            menu.description,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 18),
                    _sizeSection(),
                    const SizedBox(height: 18),
                    _addonsSection(),
                    const SizedBox(height: 18),
                    _noteSection(),
                  ],
                ),
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }
}
