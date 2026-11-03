import 'package:flutter_test/flutter_test.dart';
import 'package:tap_jaya_mobile/services/menu_recommendation_service.dart';

void main() {
  const service = MenuRecommendationService();

  test('maksimal 3 rekomendasi dan tidak memuat Add On', () {
    final results = service.recommend(const MenuPreference());
    expect(results, isNotEmpty);
    expect(results.length, lessThanOrEqualTo(3));
    expect(
      results.any((result) => result.product.category == 'Add On'),
      isFalse,
    );
  });

  test('anggaran dan jenis minuman dipatuhi', () {
    final results = service.recommend(
      const MenuPreference(
        group: 'Minuman',
        taste: 'Segar',
        maximumPrice: 20000,
      ),
    );
    expect(results, isNotEmpty);
    for (final item in results) {
      expect(item.product.lowestPrice, lessThanOrEqualTo(20000));
      expect([
        'Signature',
        'Black Series',
        'Milk Based Coffee',
        'Manual',
        'Milk Based',
        'Tea',
        'Chocolate',
      ], contains(item.product.category));
    }
  });

  test('kategori makanan dan snack tidak tercampur', () {
    final snack = service.recommend(
      const MenuPreference(group: 'Snack', taste: 'Gurih', maximumPrice: 80000),
    );
    expect(snack, isNotEmpty);
    expect(snack.every((item) => item.product.category == 'Snack'), isTrue);
  });

  test('tidak ada hasil jika anggaran terlalu kecil', () {
    final results = service.recommend(
      const MenuPreference(
        group: 'Makanan',
        taste: 'Pedas',
        maximumPrice: 1000,
      ),
    );
    expect(results, isEmpty);
  });
}
