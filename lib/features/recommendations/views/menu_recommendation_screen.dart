import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tap_jaya_mobile/core/constants/app_colors.dart';
import 'package:tap_jaya_mobile/features/menu/models/official_menu_catalog.dart';
import 'package:tap_jaya_mobile/features/menu/views/detail_official_screen.dart';
import 'package:tap_jaya_mobile/features/recommendations/models/menu_preference.dart';
import 'package:tap_jaya_mobile/features/recommendations/models/menu_recommendation.dart';
import 'package:tap_jaya_mobile/features/recommendations/services/menu_recommendation_service.dart';

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

  List<MenuRecommendation> _recommended = [];
  bool _loading = false;
  String? _error;

  int _requestVersion = 0;

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
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final requestVersion = ++_requestVersion;

    final preference = MenuPreference(
      group: _group,
      taste: _taste,
      maximumPrice: _budget == 0 ? null : _budget,
    );

    setState(() {
      _loading = true;
      _error = null;
      _recommended = [];
    });

    try {
      final results = await _engine.recommend(preference, limit: 3);

      if (!mounted || requestVersion != _requestVersion) {
        return;
      }

      setState(() {
        _recommended = results;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || requestVersion != _requestVersion) {
        return;
      }

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _changeGroup(String value) {
    if (_group == value) return;

    setState(() {
      _group = value;
    });

    _loadRecommendations();
  }

  void _changeTaste(String value) {
    if (_taste == value) return;

    setState(() {
      _taste = value;
    });

    _loadRecommendations();
  }

  void _changeBudget(int value) {
    if (_budget == value) return;

    setState(() {
      _budget = value;
    });

    _loadRecommendations();
  }

  @override
  Widget build(BuildContext context) {
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
              'Pilih selera dan anggaran. '
              'Sistem AI akan membandingkan '
              'karakteristik menu untuk '
              'menampilkan 3 pilihan teratas.',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey),
            ),
            const SizedBox(height: 22),

            _heading('Jenis menu'),
            const SizedBox(height: 8),

            Wrap(
              spacing: 7,
              runSpacing: 2,
              children: _groups.map((group) {
                return ChoiceChip(
                  label: Text(group, style: GoogleFonts.poppins(fontSize: 11)),
                  selected: _group == group,
                  selectedColor: const Color(0xFFF1CBC5),
                  onSelected: (_) => _changeGroup(group),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            _heading('Rasa favorit'),
            const SizedBox(height: 8),

            Wrap(
              spacing: 7,
              runSpacing: 2,
              children: _tastes.map((taste) {
                return ChoiceChip(
                  label: Text(taste, style: GoogleFonts.poppins(fontSize: 11)),
                  selected: _taste == taste,
                  selectedColor: const Color(0xFFF1CBC5),
                  onSelected: (_) => _changeTaste(taste),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            _heading('Anggaran maksimal'),
            const SizedBox(height: 8),

            DropdownButtonFormField<int>(
              initialValue: _budget,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _budgets.map((amount) {
                return DropdownMenuItem<int>(
                  value: amount,
                  child: Text(
                    amount == 0
                        ? 'Tanpa batas'
                        : OfficialMenuCatalog.rupiah(amount),
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _changeBudget(value);
                }
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

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              _errorResult()
            else if (_recommended.isEmpty)
              _emptyResult()
            else
              ..._recommended.map((result) => _recommendationCard(result)),

            const SizedBox(height: 16),

            Text(
              'Saran menu dihitung menggunakan '
              'Content-Based Filtering, TF-IDF, '
              'dan Cosine Similarity pada layanan '
              'AI TAP JAYA. Rekomendasi tidak '
              'menggunakan riwayat pembelian pribadi.',
              style: GoogleFonts.poppins(fontSize: 10, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heading(String value) {
    return Text(
      value,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
      ),
    );
  }

  Widget _emptyResult() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Belum ada menu yang sesuai. '
        'Pilih jenis menu lain atau '
        'naikkan batas anggaran.',
        style: GoogleFonts.poppins(fontSize: 12),
      ),
    );
  }

  Widget _errorResult() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gagal mengambil rekomendasi AI.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(_error ?? '', style: GoogleFonts.poppins(fontSize: 11)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadRecommendations,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

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
            builder: (context) => DetailOfficialScreen(menu: product),
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
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(
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
