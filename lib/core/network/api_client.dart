
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tap_jaya_mobile/core/config/api_config.dart';

class ApiClient {
  const ApiClient();

  Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Format respons API tidak valid.',
        );
      }

      return decoded;
    } on FormatException {
      rethrow;
    } catch (error) {
      throw Exception('Gagal menghubungi API: $error');
    }
  }
}
