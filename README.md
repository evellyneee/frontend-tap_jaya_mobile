# TAP JAYA Mobile

TAP JAYA Mobile adalah aplikasi mobile berbasis **Flutter** yang dibuat sebagai project UTS. Aplikasi ini dirancang untuk membantu pengguna melihat menu, mencari produk, memilih kategori, melihat detail produk, melakukan kustomisasi pesanan, mengatur jumlah item, serta menambahkan produk ke keranjang.

Project ini dikembangkan dengan fokus pada implementasi UI/UX mobile yang sederhana, konsisten, dan mudah digunakan.

## Fitur Utama

- Splash Screen
- Login simulasi
- Home / daftar menu
- Pencarian produk
- Filter kategori
  - Semua
  - Kopi
  - Non Kopi
  - Makanan
- Detail produk
- Pilihan ukuran produk
- Additional / kustomisasi pesanan
- Catatan pesanan
- Quantity produk
- Perhitungan total harga
- Add to Cart
- Badge jumlah item pada keranjang
- Bottom Navigation

## Teknologi yang Digunakan

- Flutter
- Dart
- Google Fonts
- Material Design
- Local State / Data Lokal

## Struktur Project

```text
tap_jaya_mobile/
├── assets/
│   └── images/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   └── theme/
│   ├── data/
│   ├── models/
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   └── detail_product_screen.dart
│   ├── widgets/
│   └── main.dart
├── pubspec.yaml
└── README.md
