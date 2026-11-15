import '../core/network/api_client.dart';

class CustomerRepository {
  final ApiClient apiClient;

  CustomerRepository({this.apiClient = const ApiClient()});

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await apiClient.get('/customer/products');

      if (response['success'] != true) {
        throw Exception('API gagal mengambil daftar produk.');
      }

      final data = response['data'];

      if (data is! List) {
        throw const FormatException('Format data produk tidak valid.');
      }

      return data.map<Map<String, dynamic>>((product) {
        if (product is! Map) {
          throw const FormatException('Format salah satu produk tidak valid.');
        }

        return Map<String, dynamic>.from(product);
      }).toList();
    } catch (error) {
      throw Exception('Gagal mengambil produk: $error');
    }
  }
}
