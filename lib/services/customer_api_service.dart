import 'dart:convert';

import 'package:http/http.dart' as http;

class CustomerApiService {
  // Khusus iOS Simulator
  static const String baseUrl = 'http://127.0.0.1:5001/api/customer';

  static Future<List<Map<String, dynamic>>> getProducts() async {
    final uri = Uri.parse('$baseUrl/products');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil produk. HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Format respons API tidak valid.');
      }

      if (decoded['success'] != true) {
        throw Exception('API tidak berhasil mengambil daftar produk.');
      }

      final products = decoded['data'];

      if (products is! List) {
        throw const FormatException('Data produk bukan berupa daftar.');
      }

      return products.map<Map<String, dynamic>>((product) {
        if (product is! Map<String, dynamic>) {
          throw const FormatException('Format salah satu produk tidak valid.');
        }

        return product;
      }).toList();
    } catch (error) {
      throw Exception('Tidak dapat mengambil produk: $error');
    }
  }
}
