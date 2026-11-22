import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:tap_jaya_mobile/core/config/api_config.dart';
import 'package:tap_jaya_mobile/features/menu/models/official_menu_catalog.dart';
import 'package:tap_jaya_mobile/features/recommendations/models/menu_preference.dart';
import 'package:tap_jaya_mobile/features/recommendations/models/menu_recommendation.dart';

class MenuRecommendationService {
  const MenuRecommendationService({http.Client? client}) : _client = client;

  final http.Client? _client;

  static const Set<String> _drinkCategories = {
    'Signature',
    'Black Series',
    'Milk Based Coffee',
    'Manual',
    'Milk Based',
    'Tea',
    'Chocolate',
  };

  static const Set<String> _foodCategories = {
    'Main Course',
    'Chicken Wings',
    'Pizza Porter',
  };

  /// Mengambil rekomendasi dari Python AI melalui backend Express.
  ///
  /// Hasil AI dicocokkan dengan katalog resmi Flutter
  /// agar gambar, harga, dan navigasi detail tetap berfungsi.
  Future<List<MenuRecommendation>> recommend(
    MenuPreference preference, {
    int limit = 3,
  }) async {
    if (limit <= 0) {
      return <MenuRecommendation>[];
    }

    final preferences = <String>[];

    if (preference.group != 'Semua') {
      preferences.add(preference.group);
    }

    if (preference.taste != 'Apa saja') {
      preferences.add(preference.taste);
    }

    if (preferences.isEmpty) {
      preferences.add('Semua');
    }

    final requestBody = <String, dynamic>{'preferences': preferences};

    if (preference.maximumPrice != null) {
      requestBody['budget'] = preference.maximumPrice;
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/mobile/recommendations');

    final client = _client ?? http.Client();
    final ownsClient = _client == null;

    try {
      final response = await client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(ApiConfig.connectionTimeout);

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Backend mengembalikan respons JSON tidak valid.');
      }

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Format respons backend tidak valid.');
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          decoded['success'] != true) {
        throw Exception(
          decoded['message']?.toString() ?? 'Gagal mengambil rekomendasi AI.',
        );
      }

      // Respons Express:
      //
      // {
      //   "success": true,
      //   "data": {
      //     "total": 5,
      //     "recommendations": [...]
      //   }
      // }

      final data = decoded['data'];

      if (data is! Map) {
        throw Exception('Data rekomendasi AI tidak valid.');
      }

      final rawRecommendations = data['recommendations'];

      if (rawRecommendations is! List) {
        throw Exception('Daftar rekomendasi AI tidak ditemukan.');
      }

      // Menggunakan katalog resmi Flutter.
      // Add On tidak boleh direkomendasikan sebagai menu utama.
      final catalog = OfficialMenuCatalog.menus
          .where((product) => product.category != 'Add On')
          .toList(growable: false);

      final results = <MenuRecommendation>[];
      final usedProductIds = <String>{};

      for (final raw in rawRecommendations) {
        if (raw is! Map) {
          continue;
        }

        // Python AI mengembalikan nama produk dari MySQL.
        final aiName = raw['name']?.toString() ?? '';

        if (aiName.trim().isEmpty) {
          continue;
        }

        // Cocokkan berdasarkan nama.
        //
        // Kategori tidak ikut dibandingkan karena MySQL
        // menggunakan kategori umum seperti "Makanan",
        // sedangkan Flutter menggunakan "Main Course".
        OfficialProduct? matchedProduct;

        for (final product in catalog) {
          if (_normalize(product.name) == _normalize(aiName)) {
            matchedProduct = product;
            break;
          }
        }

        // Jangan membuat produk fiktif jika nama
        // dari database tidak ada dalam katalog.
        if (matchedProduct == null) {
          continue;
        }

        final product = matchedProduct;

        // Pastikan kategori sesuai pilihan pelanggan.
        if (!_matchesGroup(product.category, preference.group)) {
          continue;
        }

        // Pastikan harga resmi katalog sesuai anggaran.
        final budget = preference.maximumPrice;

        if (budget != null && product.lowestPrice > budget) {
          continue;
        }

        // Hindari produk yang sama muncul dua kali.
        if (!usedProductIds.add(product.id)) {
          continue;
        }

        // Skor tetap berasal dari Python AI.
        final rawScore = raw['score'];

        final double score;

        if (rawScore is num) {
          score = rawScore.toDouble();
        } else {
          score = double.tryParse(rawScore?.toString() ?? '') ?? 0.0;
        }

        final rawReason = raw['reason']?.toString().trim();

        final reason = rawReason != null && rawReason.isNotEmpty
            ? rawReason
            : 'Menu ini sesuai dengan preferensi '
                  '${preference.taste.toLowerCase()} '
                  'dan anggaran yang dipilih.';

        results.add(
          MenuRecommendation(product: product, score: score, reason: reason),
        );

        if (results.length >= limit) {
          break;
        }
      }

      return results;
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  /// Memastikan kategori menu sesuai preferensi.
  bool _matchesGroup(String category, String group) {
    switch (group) {
      case 'Minuman':
        return _drinkCategories.contains(category);

      case 'Makanan':
        return _foodCategories.contains(category);

      case 'Snack':
        return category == 'Snack';

      case 'Semua':
      default:
        return true;
    }
  }

  /// Menyamakan nama produk tanpa membedakan
  /// huruf besar, spasi, atau tanda baca.
  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
