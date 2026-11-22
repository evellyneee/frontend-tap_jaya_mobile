import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:tap_jaya_mobile/core/config/api_config.dart';

import '../../cart/models/cart_item.dart';
import '../../menu/models/customer_product.dart';
import '../../menu/repositories/menu_repository.dart';
import '../models/mobile_checkout_result.dart';

class CheckoutRepository {
  final http.Client _client;
  final MenuRepository _menuRepository;

  CheckoutRepository({http.Client? client, MenuRepository? menuRepository})
    : _client = client ?? http.Client(),
      _menuRepository = menuRepository ?? const MenuRepository();

  // ============================================================
  // NORMALISASI JENIS PESANAN
  // ============================================================

  String _normalizeOrderType(String orderType) {
    switch (orderType.trim()) {
      case 'Dine-in':
      case 'Makan di Tempat':
        return 'Dine-in';

      case 'Takeaway':
      case 'Bawa Pulang':
        return 'Takeaway';

      default:
        throw Exception('Jenis pesanan harus Dine-in atau Takeaway.');
    }
  }

  // ============================================================
  // NORMALISASI UKURAN
  // ============================================================

  String _normalizeSize(String size) {
    switch (size.trim().toLowerCase()) {
      case '':
      case 'regular':
      case 'small':
      case 'standar':
      case 'standard':
        return 'Regular';

      case 'medium':
        return 'Medium';

      case 'large':
        return 'Large';

      default:
        throw Exception('Ukuran produk "$size" tidak valid.');
    }
  }

  // ============================================================
  // NORMALISASI NAMA PRODUK
  // ============================================================

  String _normalizeProductName(String name) {
    return name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  // ============================================================
  // CARI ID PRODUK ASLI DARI API MYSQL
  // ============================================================

  int _findProductId({
    required CartItem item,
    required List<CustomerProduct> products,
  }) {
    final normalizedName = _normalizeProductName(item.productName);

    final matches = products.where((product) {
      return _normalizeProductName(product.name) == normalizedName;
    }).toList();

    if (matches.isEmpty) {
      throw Exception(
        'Produk "${item.productName}" tidak ditemukan '
        'di API produk MySQL. '
        'Periksa nama, status, dan kategori produk '
        'pada database.',
      );
    }

    if (matches.length > 1) {
      throw Exception(
        'Produk "${item.productName}" memiliki '
        'lebih dari satu kecocokan di API. '
        'ID tidak dapat ditentukan secara aman.',
      );
    }

    final product = matches.single;

    if (!product.isAvailable) {
      throw Exception(
        'Produk "${item.productName}" '
        'sedang tidak tersedia.',
      );
    }

    if (item.quantity > product.stock) {
      throw Exception(
        'Stok "${item.productName}" tidak mencukupi. '
        'Stok tersedia: ${product.stock}.',
      );
    }

    if (product.id <= 0) {
      throw Exception(
        'ID MySQL untuk "${item.productName}" '
        'tidak valid.',
      );
    }

    debugPrint(
      'CHECKOUT ID DARI API | '
      'nama=${product.name} | '
      'productId=${product.id}',
    );

    return product.id;
  }

  // ============================================================
  // CREATE ORDER
  // POST /api/mobile/checkout
  // ============================================================

  Future<MobileCheckoutResult> createQrisOrder({
    required String customerName,
    required String customerEmail,
    required String orderType,
    required String tableNumber,
    required int totalPayment,
    required List<CartItem> orderItems,
    String customerNote = '',
    String? customerToken,
  }) async {
    // ==========================================================
    // VALIDASI PELANGGAN
    // ==========================================================

    final normalizedOrderType = _normalizeOrderType(orderType);

    if (customerName.trim().isEmpty) {
      throw Exception('Nama pelanggan wajib diisi.');
    }

    if (customerName.trim().length > 100) {
      throw Exception('Nama pelanggan maksimal 100 karakter.');
    }

    if (orderItems.isEmpty) {
      throw Exception('Keranjang pesanan tidak boleh kosong.');
    }

    if (normalizedOrderType == 'Dine-in' && tableNumber.trim().isEmpty) {
      throw Exception('Nomor meja wajib diisi.');
    }

    if (tableNumber.trim().length > 20) {
      throw Exception('Nomor meja maksimal 20 karakter.');
    }

    // ==========================================================
    // AMBIL DATA API HANYA JIKA ADA ID KOSONG
    // ==========================================================

    final needsProductLookup = orderItems.any(
      (item) => item.productId == null || item.productId! <= 0,
    );

    List<CustomerProduct> backendProducts = <CustomerProduct>[];

    if (needsProductLookup) {
      try {
        backendProducts = await _menuRepository.getProducts();

        debugPrint(
          'CHECKOUT | '
          'Jumlah produk dari API: '
          '${backendProducts.length}',
        );
      } catch (error) {
        throw Exception(
          'Gagal mengambil data produk dari backend. '
          'Periksa koneksi API dan server. '
          'Detail: $error',
        );
      }
    }

    // ==========================================================
    // KONVERSI CART ITEMS
    // ==========================================================

    final items = <Map<String, dynamic>>[];

    // Produk dengan konfigurasi identik digabungkan.
    final itemIndexes = <String, int>{};

    for (final item in orderItems) {
      // ========================================================
      // VALIDASI DAN PEMULIHAN PRODUCT ID MYSQL
      // ========================================================

      int? productId = item.productId;

      debugPrint(
        'CHECKOUT SEBELUM VALIDASI | '
        'nama=${item.productName} | '
        'productId=$productId | '
        'cartId=${item.id}',
      );

      // Jika ID belum ada, cari berdasarkan nama
      // produk yang terdaftar di backend.
      if (productId == null || productId <= 0) {
        productId = _findProductId(item: item, products: backendProducts);
      }

      if (productId <= 0) {
        throw Exception(
          'ID produk ${item.productName} '
          'tidak valid.',
        );
      }

      debugPrint(
        'CHECKOUT ID FINAL | '
        'nama=${item.productName} | '
        'productId=$productId',
      );

      // ========================================================
      // VALIDASI JUMLAH
      // ========================================================

      if (item.quantity <= 0) {
        throw Exception(
          'Jumlah produk ${item.productName} '
          'tidak valid.',
        );
      }

      // ========================================================
      // NORMALISASI UKURAN
      // ========================================================

      final size = _normalizeSize(item.size);

      // ========================================================
      // VALIDASI ADD-ON
      // ========================================================

      final addonIds = <int>[];
      final uniqueAddonIds = <int>{};

      for (final addonId in item.addonIds) {
        if (addonId <= 0) {
          throw Exception(
            'ID add-on untuk '
            '${item.productName} tidak valid.',
          );
        }

        if (!uniqueAddonIds.add(addonId)) {
          throw Exception(
            'Add-on yang sama dipilih '
            'lebih dari sekali pada '
            '${item.productName}.',
          );
        }

        addonIds.add(addonId);
      }

      addonIds.sort();

      // ========================================================
      // VALIDASI CATATAN
      // ========================================================

      final note = item.note.trim();

      if (note.length > 1000) {
        throw Exception(
          'Catatan ${item.productName} '
          'maksimal 1000 karakter.',
        );
      }

      // ========================================================
      // IDENTITAS KONFIGURASI
      // ========================================================

      final itemKey = jsonEncode({
        'productId': productId,
        'size': size,
        'addonIds': addonIds,
        'extraShot': item.extraShot,
        'lessIce': item.lessIce,
        'lessSugar': item.lessSugar,
        'note': note,
      });

      final existingIndex = itemIndexes[itemKey];

      if (existingIndex != null) {
        final existingQuantity = items[existingIndex]['quantity'] as int;

        items[existingIndex]['quantity'] = existingQuantity + item.quantity;
      } else {
        itemIndexes[itemKey] = items.length;

        items.add({
          'productId': productId,
          'quantity': item.quantity,
          'size': size,
          'addonIds': addonIds,
          'extraShot': item.extraShot,
          'lessIce': item.lessIce,
          'lessSugar': item.lessSugar,
          'note': note,
        });
      }
    }

    // ==========================================================
    // REQUEST HEADERS
    // ==========================================================

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (customerToken != null && customerToken.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${customerToken.trim()}';
    }

    // ==========================================================
    // REQUEST BODY
    // ==========================================================

    final body = <String, dynamic>{
      'customerName': customerName.trim(),
      'customerEmail': customerEmail.trim(),
      'orderType': normalizedOrderType,
      'tableNumber': normalizedOrderType == 'Dine-in' ? tableNumber.trim() : '',
      'customerNote': customerNote.trim(),
      'totalPayment': totalPayment,
      'items': items,
    };

    debugPrint(
      'CHECKOUT | '
      'Jumlah item yang dikirim: ${items.length}',
    );

    // ==========================================================
    // KIRIM CHECKOUT KE BACKEND
    // ==========================================================

    final response = await _client
        .post(
          Uri.parse(ApiConfig.checkoutUrl),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.connectionTimeout);

    // ==========================================================
    // PARSE RESPONSE
    // ==========================================================

    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Respons backend bukan JSON yang valid.');
    }

    if (response.statusCode != 201) {
      final message = decoded is Map ? decoded['message']?.toString() : null;

      throw Exception(message ?? 'Checkout gagal.');
    }

    if (decoded is! Map || decoded['data'] is! Map) {
      throw Exception('Format respons checkout tidak valid.');
    }

    final data = Map<String, dynamic>.from(decoded['data'] as Map);

    return MobileCheckoutResult.fromJson(data);
  }

  // ============================================================
  // GET ORDER STATUS
  // GET /api/mobile/orders/:orderNumber
  // ============================================================

  Future<Map<String, dynamic>> getPaymentStatus(String orderNumber) async {
    final normalizedOrderNumber = orderNumber.trim().replaceFirst(
      RegExp(r'^#'),
      '',
    );

    if (normalizedOrderNumber.isEmpty) {
      throw Exception('Nomor pesanan tidak valid.');
    }

    final ordersUri = Uri.parse(ApiConfig.ordersUrl);

    final normalizedPath = ordersUri.path.endsWith('/')
        ? ordersUri.path.substring(0, ordersUri.path.length - 1)
        : ordersUri.path;

    final orderUri = ordersUri.replace(
      path:
          '$normalizedPath/'
          '${Uri.encodeComponent(normalizedOrderNumber)}',
    );

    final response = await _client
        .get(orderUri, headers: {'Accept': 'application/json'})
        .timeout(ApiConfig.connectionTimeout);

    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Respons status pesanan '
        'bukan JSON yang valid.',
      );
    }

    if (response.statusCode != 200) {
      final message = decoded is Map ? decoded['message']?.toString() : null;

      throw Exception(message ?? 'Gagal mengambil status pesanan.');
    }

    if (decoded is! Map || decoded['data'] is! Map) {
      throw Exception('Format data pesanan tidak valid.');
    }

    return Map<String, dynamic>.from(decoded['data'] as Map);
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    _client.close();
  }
}
