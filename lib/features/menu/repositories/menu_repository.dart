
import 'package:tap_jaya_mobile/core/network/api_client.dart';

import '../models/customer_product.dart';

class MenuRepository {
  final ApiClient _apiClient;

  const MenuRepository({
    this._apiClient = const ApiClient(),
  });

  Future<List<CustomerProduct>> getProducts() async {
    final response = await _apiClient.get('/mobile/products');

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Gagal mengambil produk.',
      );
    }

    final rawData = response['data'];

    if (rawData is! List) {
      throw const FormatException(
        'Format daftar produk tidak valid.',
      );
    }

    return rawData.map<CustomerProduct>((item) {
      if (item is! Map) {
        throw const FormatException(
          'Format data produk tidak valid.',
        );
      }

      return CustomerProduct.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }
}
