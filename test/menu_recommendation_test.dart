import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:tap_jaya_mobile/features/recommendations/models/menu_preference.dart';
import 'package:tap_jaya_mobile/features/recommendations/services/menu_recommendation_service.dart';

void main() {
  group('MenuRecommendationService', () {
    test('mengirim preferensi dan anggaran ke backend', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');

        expect(request.url.path, '/api/mobile/recommendations');

        final body = jsonDecode(request.body) as Map<String, dynamic>;

        expect(body['preferences'], ['Minuman', 'Segar']);

        expect(body['budget'], 20000);

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Rekomendasi menu berhasil diperoleh.',
            'data': {'total': 0, 'recommendations': []},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = MenuRecommendationService(client: client);

      final results = await service.recommend(
        const MenuPreference(
          group: 'Minuman',
          taste: 'Segar',
          maximumPrice: 20000,
        ),
      );

      expect(results, isEmpty);

      client.close();
    });

    test('tidak mengirim budget jika tanpa batas', () async {
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;

        expect(body.containsKey('budget'), isFalse);

        expect(body['preferences'], ['Semua']);

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'total': 0, 'recommendations': []},
          }),
          200,
        );
      });

      final service = MenuRecommendationService(client: client);

      final results = await service.recommend(
        const MenuPreference(
          group: 'Semua',
          taste: 'Apa saja',
          maximumPrice: null,
        ),
      );

      expect(results, isEmpty);

      client.close();
    });

    test('membatasi hasil maksimal 3 rekomendasi', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'total': 0, 'recommendations': []},
          }),
          200,
        );
      });

      final service = MenuRecommendationService(client: client);

      final results = await service.recommend(const MenuPreference(), limit: 3);

      expect(results.length, lessThanOrEqualTo(3));

      client.close();
    });

    test('mengembalikan daftar kosong jika limit nol', () async {
      final client = MockClient((request) async {
        fail('HTTP tidak boleh dipanggil jika limit nol.');
      });

      final service = MenuRecommendationService(client: client);

      final results = await service.recommend(const MenuPreference(), limit: 0);

      expect(results, isEmpty);

      client.close();
    });

    test('menangani kesalahan HTTP dari backend', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Layanan rekomendasi AI tidak tersedia.',
          }),
          502,
        );
      });

      final service = MenuRecommendationService(client: client);

      await expectLater(
        service.recommend(const MenuPreference()),
        throwsException,
      );

      client.close();
    });

    test('menangani respons JSON tidak valid', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = MenuRecommendationService(client: client);

      await expectLater(
        service.recommend(const MenuPreference()),
        throwsException,
      );

      client.close();
    });
  });
}
