import 'dart:math' as math;

import '../models/official_menu_catalog.dart';

/// Preferensi eksplisit dari pelanggan (tanpa akun dan tanpa server).
class MenuPreference {
  final String group;
  final String taste;
  final int? maximumPrice;

  const MenuPreference({
    this.group = 'Minuman',
    this.taste = 'Creamy',
    this.maximumPrice = 40000,
  });
}

class MenuRecommendation {
  final OfficialProduct product;
  final double score;
  final String reason;

  const MenuRecommendation({
    required this.product,
    required this.score,
    required this.reason,
  });
}

/// Content-Based Filtering: TF-IDF dari teks menu + cosine similarity.
/// Ini prototipe rekomendasi berbasis konten, BUKAN model yang sudah
/// dilatih dari riwayat pembelian pelanggan.
class MenuRecommendationService {
  const MenuRecommendationService();

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

  static const Set<String> _stopWords = {
    'dan',
    'atau',
    'dengan',
    'yang',
    'di',
    'ke',
    'dari',
    'untuk',
    'ini',
    'itu',
    'pada',
    'dalam',
    'serta',
    'sebagai',
    'dilengkapi',
    'disajikan',
    'pilihan',
    'menjadi',
    'memberikan',
    'menggunakan',
    'rasa',
    'menu',
    'khas',
    'berpadu',
    'memiliki',
    'tersedia',
    'lebih',
    'satu',
    'dua',
    'tiga',
    'the',
    'with',
    'of',
    'and',
  };

  static final Map<String, String> _tasteQueries = {
    'Creamy': 'creamy susu lembut krim latte cokelat',
    'Manis': 'manis madu gula karamel cokelat susu',
    'Segar': 'segar menyegarkan lemon jeruk buah teh',
    'Kopi Kuat': 'kuat pekat espresso kopi robusta',
    'Gurih': 'gurih asin ayam nasi keju mentega',
    'Pedas': 'pedas cabai sambal spicy nashville',
    'Apa saja': '',
  };

  static final Map<String, String> _groupQueries = {
    'Semua': 'kopi teh susu nasi ayam pizza snack',
    'Minuman': 'kopi espresso susu teh cokelat minuman',
    'Makanan': 'nasi ayam pizza makanan gurih',
    'Snack': 'snack camilan renyah saus gyoza',
  };

  List<MenuRecommendation> recommend(
    MenuPreference preference, {
    int limit = 3,
  }) {
    if (limit <= 0) return const [];

    // Add On tidak direkomendasikan sebagai produk utama.
    final allProducts = OfficialMenuCatalog.menus
        .where((product) => product.category != 'Add On')
        .toList(growable: false);
    final candidates = allProducts
        .where((product) {
          if (!_matchesGroup(product, preference.group)) return false;
          final budget = preference.maximumPrice;
          if (budget != null && product.lowestPrice > budget) return false;
          return true;
        })
        .toList(growable: false);

    if (candidates.isEmpty) return const [];

    // IDF dihitung dari keseluruhan katalog, bukan dari 3 hasil terpilih.
    final documents = allProducts.map(_productTokens).toList(growable: false);
    final frequency = <String, int>{};
    for (final document in documents) {
      for (final term in document.toSet()) {
        frequency[term] = (frequency[term] ?? 0) + 1;
      }
    }
    final idf = <String, double>{};
    for (final entry in frequency.entries) {
      idf[entry.key] = math.log((1 + documents.length) / (1 + entry.value)) + 1;
    }

    final tasteQuery = _tasteQueries[preference.taste] ?? '';
    final groupQuery =
        _groupQueries[preference.group] ?? _groupQueries['Semua']!;
    final userTokens = _tokens('$tasteQuery $tasteQuery $groupQuery');
    final userVector = _vector(userTokens, idf);

    final scored = <MenuRecommendation>[];
    for (final product in candidates) {
      final productVector = _vector(_productTokens(product), idf);
      final similarity = _cosine(userVector, productVector);
      // Sedikit preferensi harga rendah di antara hasil dengan skor serupa.
      final budget = preference.maximumPrice;
      final affordability = budget == null || budget <= 0
          ? 0.0
          : (1 - product.lowestPrice / budget).clamp(0.0, 1.0);
      final score = 0.95 * similarity + 0.05 * affordability;
      final reason = preference.taste == 'Apa saja'
          ? 'Sesuai pilihan jenis menu dan anggaranmu.'
          : 'Cocok dengan preferensi ${preference.taste.toLowerCase()} dan anggaranmu.';
      scored.add(
        MenuRecommendation(product: product, score: score, reason: reason),
      );
    }
    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final byPrice = a.product.lowestPrice.compareTo(b.product.lowestPrice);
      return byPrice != 0 ? byPrice : a.product.name.compareTo(b.product.name);
    });
    return scored.take(limit).toList(growable: false);
  }

  bool _matchesGroup(OfficialProduct product, String group) {
    switch (group) {
      case 'Minuman':
        return _drinkCategories.contains(product.category);
      case 'Makanan':
        return _foodCategories.contains(product.category);
      case 'Snack':
        return product.category == 'Snack';
      default:
        return true;
    }
  }

  List<String> _productTokens(OfficialProduct product) {
    final text = '${product.name} ${product.category} ${product.description}';
    final lower = text.toLowerCase();
    final extra = <String>[];
    if (RegExp(r'susu|latte|milk|krim|creamy|cokelat|lembut').hasMatch(lower)) {
      extra.addAll(['creamy', 'susu', 'lembut']);
    }
    if (RegExp(r'manis|madu|gula|karamel|cokelat|honey').hasMatch(lower)) {
      extra.addAll(['manis', 'madu']);
    }
    if (RegExp(r'segar|lemon|jeruk|orange|buah|mint|lychee|tea')
        .hasMatch(lower)) {
      extra.addAll(['segar', 'menyegarkan']);
    }
    if (RegExp(r'espresso|robusta|pekat|kuat|americano').hasMatch(lower)) {
      extra.addAll(['kopi', 'kuat', 'espresso']);
    }
    if (RegExp(r'ayam|nasi|saus|keju|mentega|gurih|pizza|salted')
        .hasMatch(lower)) {
      extra.addAll(['gurih', 'makanan']);
    }
    if (RegExp(r'pedas|cabai|sambal|chili|nashville').hasMatch(lower)) {
      extra.addAll(['pedas', 'cabai']);
    }
    if (product.category == 'Snack')
      extra.addAll(['snack', 'camilan', 'renyah']);
    return [..._tokens(text), ...extra, ...extra];
  }

  List<String> _tokens(String text) =>
      RegExp(r'[a-z0-9]+')
          .allMatches(text.toLowerCase())
          .map((match) => match.group(0)!)
          .where((term) => term.length > 2 && !_stopWords.contains(term))
          .toList(growable: false);

  Map<String, double> _vector(List<String> tokens, Map<String, double> idf) {
    if (tokens.isEmpty) return {};
    final counts = <String, int>{};
    for (final token in tokens) {
      counts[token] = (counts[token] ?? 0) + 1;
    }
    final weights = <String, double>{};
    for (final entry in counts.entries) {
      weights[entry.key] =
          (entry.value / tokens.length) * (idf[entry.key] ?? 1.0);
    }
    return weights;
  }

  double _cosine(Map<String, double> a, Map<String, double> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    var dot = 0.0;
    var sizeA = 0.0;
    var sizeB = 0.0;
    for (final entry in a.entries) {
      sizeA += entry.value * entry.value;
      dot += entry.value * (b[entry.key] ?? 0);
    }
    for (final value in b.values) {
      sizeB += value * value;
    }
    if (sizeA == 0 || sizeB == 0) return 0;
    return dot / (math.sqrt(sizeA) * math.sqrt(sizeB));
  }
}
