class ApiConfig {
  ApiConfig._();

  // Base URL backend TAP JAYA
  static const String baseUrl = 'http://127.0.0.1:5001/api';

  // Endpoint khusus pelanggan
  static const String customerUrl = '$baseUrl/customer';

  // Endpoint produk
  static const String productsUrl = '$customerUrl/products';

  // Timeout koneksi
  static const Duration connectionTimeout = Duration(seconds: 15);
}
