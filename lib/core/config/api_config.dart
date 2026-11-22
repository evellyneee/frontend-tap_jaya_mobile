
import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // =====================================
  // KONFIGURASI BACKEND TAP JAYA
  // =====================================

  // Alamat backend untuk Flutter Web.
  static const String _webHost = 'localhost';

  // Alamat backend untuk emulator Android.
  static const String _androidEmulatorHost = '10.0.2.2';

  // Alamat backend untuk perangkat fisik.
  //
  // Ganti melalui --dart-define ketika menjalankan
  // Flutter pada HP fisik.
  //
  // Contoh:
  // flutter run --dart-define=API_HOST=192.168.1.10
  static const String _customHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: '',
  );

  static String get _host {
    if (_customHost.isNotEmpty) {
      return _customHost;
    }

    if (kIsWeb) {
      return _webHost;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidEmulatorHost;
    }

    return _webHost;
  }

  // =====================================
  // BASE URL
  // =====================================

  static String get baseUrl =>
      'http://$_host:5000/api';

  // =====================================
  // MOBILE ENDPOINTS
  // =====================================

  static String get productsUrl =>
      '$baseUrl/mobile/products';

  static String get checkoutUrl =>
      '$baseUrl/mobile/checkout';

  static String get ordersUrl =>
      '$baseUrl/mobile/orders';

  static String get recommendationsUrl =>
      '$baseUrl/mobile/recommendations';

  // =====================================
  // TIMEOUT
  // =====================================

  static const Duration connectionTimeout =
      Duration(seconds: 15);
}