import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../models/official_menu_catalog.dart';
import '../services/menu_recommendation_service.dart';
import 'detail_official_screen.dart';

/// Halaman preferensi + 3 rekomendasi yang terhubung ke detail menu existing.
class MenuRecommendationScreen extends StatefulWidget {
  const MenuRecommendationScreen({super.key});

  @override
  State<MenuRecommendationScreen> createState() =>
      _MenuRecommendationScreenState();
}

class _MenuRecommendationScreenState extends State<MenuRecommendationScreen> {
  final _engine = const MenuRecommendationService();
  String _group = 'Minuman';
  String _taste = 'Creamy';
  int _budget = 40000;

  static const _groups = ['Semua', 'Minuman', 'Makanan', 'Snack'];
  static const _tastes = [
    'Creamy',
    'Manis',
    'Segar',
    'Kopi Kuat',
    'Gurih',
    'Pedas',
    'Apa saja',
  ];
  static const _budgets = [25000, 40000, 60000, 80000, 0];

  @override
  Widget build(BuildContext context) {
    final preference = MenuPreference(
      group: _group,
      taste: _taste,
      maximumPrice: _budget == 0 ? null : _budget,
    );
    final recommended = _engine.recommend(preference);

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        title: Text(
          'Rekomendasi Menu',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              'Cari menu yang cocok buatmu',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Pilih selera dan anggaran. Sistem akan membandingkan karakteristik menu untuk menampilkan 3 pilihan teratas.',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey),
            ),
            const SizedBox(height: 22),
            _heading('Jenis menu'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 2,
              children: _groups
                  .map(
                    (group) => ChoiceChip(
                      label: Text(
                        group,
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                      selected: _group == group,
                      selectedColor: const Color(0xFFF1CBC5),
                      onSelected: (_) => setState(() => _group = group),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            _heading('Rasa favorit'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 2,
              children: _tastes
                  .map(
                    (taste) => ChoiceChip(
                      label: Text(
                        taste,
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                      selected: _taste == taste,
                      selectedColor: const Color(0xFFF1CBC5),
                      onSelected: (_) => setState(() => _taste = taste),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            _heading('Anggaran maksimal'),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _budget,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _budgets
                  .map(
                    (amount) => DropdownMenuItem<int>(
                      value: amount,
                      child: Text(
                        amount == 0
                            ? 'Tanpa batas'
                            : OfficialMenuCatalog.rupiah(amount),
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _budget = value);
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(child: _heading('3 Rekomendasi Untukmu')),
              ],
            ),
            const SizedBox(height: 10),
            if (recommended.isEmpty)
              _emptyResult()
            else
              ...recommended.map((result) => _recommendationCard(result)),
            const SizedBox(height: 16),
            Text(
              'Saran menu dihitung dari kemiripan deskripsi dan atribut produk. Ini bukan rekomendasi berdasarkan data pembelian pribadi.',
              style: GoogleFonts.poppins(fontSize: 10, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heading(String value) => Text(
    value,
    style: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.dark,
    ),
  );

  Widget _emptyResult() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      'Belum ada menu yang sesuai. Pilih jenis menu lain atau naikkan batas anggaran.',
      style: GoogleFonts.poppins(fontSize: 12),
    ),
  );

  Widget _recommendationCard(MenuRecommendation result) {
    final product = result.product;
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => DetailOfficialScreen(menu: product),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: product.image == null
                    ? const SizedBox(
                        width: 82,
                        height: 82,
                        child: Icon(Icons.coffee),
                      )
                    : Image.asset(
                        product.image!,
                        width: 82,
                        height: 82,
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, stack) => const SizedBox(
                          width: 82,
                          height: 82,
                          child: Icon(Icons.image_not_supported),
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      OfficialMenuCatalog.rupiah(product.lowestPrice),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      result.reason,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.red),
            ],
          ),
        ),
      ),
    );
  }
}
