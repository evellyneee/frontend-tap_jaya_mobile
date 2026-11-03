import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

/// Pratinjau produk referensi. Produk belum aktif di checkout karena
/// harga dan ketersediaannya belum dikonfirmasi untuk cabang Begawan.
class DetailCatalogScreen extends StatelessWidget {
  final Map<String, String> product;

  const DetailCatalogScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        backgroundColor: AppColors.warmWhite,
        centerTitle: true,
        title: Text(
          'Detail Menu',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.dark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EDE5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(
                    product['category'] == 'Kopi'
                        ? Icons.local_cafe_outlined
                        : product['category'] == 'Non Kopi'
                        ? Icons.local_drink_outlined
                        : product['category'] == 'Snack'
                        ? Icons.bakery_dining_outlined
                        : Icons.restaurant_outlined,
                    size: 64,
                    color: AppColors.dark,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E0DB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${product['category'] ?? ''} • ${product['subcategory'] ?? ''}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product['description'] ?? '',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EDE5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Referensi menu Begawan dari daftar daring 2023. '
                  'Harga, foto, dan ketersediaan saat ini belum terverifikasi. '
                  'Menu ini belum dapat dimasukkan ke keranjang.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.dark,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Kembali ke Menu', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
