class CustomerProduct {
  final int id;
  final String name;
  final String category;
  final int price;
  final int stock;
  final String? imagePath;
  final bool isActive;

  const CustomerProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.imagePath,
    required this.isActive,
  });

  factory CustomerProduct.fromJson(Map<String, dynamic> json) {
    final id = _parseInteger(json['id'], 'id');
    final price = _parsePrice(json['price']);
    final stock = _parseInteger(json['stock'], 'stock');

    final name = json['name'];
    final category = json['category'];

    if (id <= 0) {
      throw const FormatException('ID produk tidak valid.');
    }

    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('Nama produk tidak valid.');
    }

    if (category is! String || category.trim().isEmpty) {
      throw const FormatException('Kategori produk tidak valid.');
    }

    if (price < 0) {
      throw const FormatException('Harga produk tidak valid.');
    }

    if (stock < 0) {
      throw const FormatException('Stok produk tidak valid.');
    }

    final rawImage = json['image'];
    final imagePath = rawImage is String && rawImage.trim().isNotEmpty
        ? rawImage.trim()
        : null;

    return CustomerProduct(
      id: id,
      name: name.trim(),
      category: category.trim(),
      price: price,
      stock: stock,
      imagePath: imagePath,
      isActive: _parseActive(json['is_active']),
    );
  }

  static int _parseInteger(dynamic value, String field) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      final result = int.tryParse(value.trim());
      if (result != null) {
        return result;
      }
    }

    throw FormatException('Nilai $field tidak valid.');
  }

  static int _parsePrice(dynamic value) {
    final String rawValue;

    if (value is int) {
      rawValue = value.toString();
    } else if (value is double && value.isFinite) {
      rawValue = value.toString();
    } else if (value is String) {
      rawValue = value.trim();
    } else {
      throw const FormatException('Format harga tidak valid.');
    }

    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(rawValue)) {
      throw const FormatException('Format harga tidak valid.');
    }

    final parts = rawValue.split('.');
    final whole = int.tryParse(parts[0]);

    if (whole == null) {
      throw const FormatException('Harga produk terlalu besar.');
    }

    if (parts.length == 2 && int.parse(parts[1].padRight(2, '0')) != 0) {
      throw const FormatException(
        'Harga memiliki pecahan rupiah yang belum didukung.',
      );
    }

    return whole;
  }

  static bool _parseActive(dynamic value) {
    if (value == true || value == 1 || value == '1') {
      return true;
    }

    if (value == false || value == 0 || value == '0') {
      return false;
    }

    throw const FormatException('Status produk tidak valid.');
  }

  bool get isAvailable => isActive && stock > 0;

  String get formattedPrice {
    final digits = price.toString();

    final formatted = digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    return 'Rp $formatted';
  }

  String get cartId => 'api|$id|Standar';
}
