import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tap_jaya_mobile/core/config/api_config.dart';

class SimulatedPaymentService {
  const SimulatedPaymentService();

  Future<Map<String, dynamic>> completePayment({
    required String orderNumber,
  }) async {
    final number = orderNumber.trim().replaceFirst(RegExp(r'^#'), '');

    if (number.isEmpty) {
      throw Exception('Nomor pesanan kosong.');
    }

    final url = Uri.parse(
      '${ApiConfig.ordersUrl}/'
      '${Uri.encodeComponent(number)}'
      '/simulate-payment',
    );

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(ApiConfig.connectionTimeout);

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Respons backend tidak valid.');
      }

      final message = decoded['message']?.toString() ?? 'Pembayaran gagal.';

      if (response.statusCode != 200 || decoded['success'] != true) {
        throw Exception('$message (HTTP ${response.statusCode})');
      }

      final data = decoded['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception('Data pembayaran tidak ditemukan.');
      }

      final status = data['paymentStatus']?.toString().toLowerCase();

      if (status != 'paid') {
        throw Exception('Backend belum menyimpan pembayaran sebagai paid.');
      }

      return data;
    } on FormatException {
      throw Exception('Backend tidak mengembalikan JSON yang valid.');
    } catch (error) {
      throw Exception('Gagal memproses pembayaran: $error');
    }
  }
}
