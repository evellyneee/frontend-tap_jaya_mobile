
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tap_jaya_mobile/features/menu/repositories/customer_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Customer API berhasil mengambil produk aktif', (tester) async {
    final repository = CustomerRepository();
    final products = await repository.getProducts();

    expect(products, isNotEmpty);

    for (final product in products) {
      expect(product.containsKey('id'), isTrue);
      expect(product.containsKey('name'), isTrue);
      expect(product.containsKey('category'), isTrue);
      expect(product.containsKey('price'), isTrue);
      expect(product.containsKey('stock'), isTrue);
      expect(product['is_active'], 1);
    }

    debugPrint(
      'Berhasil mengambil ${products.length} produk dari Customer API',
    );

    for (final product in products) {
      debugPrint(
        'ID: ${product['id']} | '
        'Nama: ${product['name']} | '
        'Harga: ${product['price']}',
      );
    }
  });
}
