
class CartItem {
  // =====================================
  // IDENTITAS PRODUK
  // =====================================

  // ID unik item dalam keranjang.
  // Dapat mencakup ukuran, add-on,
  // dan kustomisasi produk.
  final String id;

  // ID asli produk dari tabel products MySQL.
  //
  // Sementara dibuat opsional untuk
  // kompatibilitas dengan kode Flutter lama.
  final int? productId;

  final String productName;
  final String imagePath;

  // Harga per unit yang ditampilkan Flutter.
  //
  // Nilai ini sebaiknya sudah mencakup
  // harga ukuran dan seluruh add-on.
  //
  // Backend tetap menghitung ulang harga
  // berdasarkan database MySQL.
  final int unitPrice;

  // =====================================
  // JUMLAH DAN STATUS PILIHAN
  // =====================================

  int quantity;
  bool isSelected;

  // =====================================
  // KONFIGURASI PRODUK
  // =====================================

  final String size;

  // Daftar ID add-on dari product_addons.id.
  //
  // Contoh: [1, 3, 5]
  //
  // ID harus sesuai dengan add-on yang
  // tersedia untuk produk tersebut.
  final List<int> addonIds;

  // Kustomisasi tambahan.
  final bool extraShot;
  final bool lessIce;
  final bool lessSugar;

  // Catatan khusus untuk satu item.
  final String note;

  // =====================================
  // CONSTRUCTOR
  // =====================================

  CartItem({
    required this.id,
    this.productId,
    required this.productName,
    required this.imagePath,
    required this.unitPrice,
    required this.quantity,
    this.isSelected = true,
    this.size = '',
    List<int> addonIds = const [],
    this.extraShot = false,
    this.lessIce = false,
    this.lessSugar = false,
    this.note = '',
  }) : addonIds = List<int>.unmodifiable(addonIds);

  // =====================================
  // TOTAL HARGA ITEM
  // =====================================

  int get totalPrice {
    return unitPrice * quantity;
  }

  // =====================================
  // VALIDASI ID PRODUK MYSQL
  // =====================================

  bool get hasValidProductId {
    return productId != null && productId! > 0;
  }

  // =====================================
  // STATUS ADD-ON
  // =====================================

  bool get hasAddons {
    return addonIds.isNotEmpty;
  }

  // =====================================
  // IDENTITAS KONFIGURASI
  // =====================================

  // Digunakan untuk membedakan produk
  // dengan pilihan kustomisasi berbeda.
  //
  // Contoh:
  // Kopi Large + Extra Shot
  // berbeda dari Kopi Large + Caramel.

  String get configurationKey {
    final sortedAddonIds = [...addonIds]..sort();

    return [
      productId ?? id,
      size.trim().toLowerCase(),
      sortedAddonIds.join(','),
      extraShot,
      lessIce,
      lessSugar,
      note.trim(),
    ].join('|');
  }
}
