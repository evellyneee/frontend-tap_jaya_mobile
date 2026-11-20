
import 'package:flutter/foundation.dart';

import '../models/menu_preference.dart';
import '../models/menu_recommendation.dart';
import '../services/menu_recommendation_service.dart';

class MenuRecommendationViewModel extends ChangeNotifier {
  MenuRecommendationViewModel._();

  static final MenuRecommendationViewModel instance =
      MenuRecommendationViewModel._();

  final MenuRecommendationService _service =
      const MenuRecommendationService();

  // Preferensi awal pengguna.
  String _group = 'Minuman';
  String _taste = 'Creamy';
  int _budget = 40000;

  // Mengambil nilai preferensi.
  String get group => _group;
  String get taste => _taste;
  int get budget => _budget;

  // Pilihan kategori menu.
  static const List<String> groups = [
    'Semua',
    'Minuman',
    'Makanan',
    'Snack',
  ];

  // Pilihan rasa.
  static const List<String> tastes = [
    'Creamy',
    'Manis',
    'Segar',
    'Kopi Kuat',
    'Gurih',
    'Pedas',
  ];

  // Pilihan anggaran.
  static const List<int> budgets = [
    25000,
    40000,
    60000,
    80000,
    0,
  ];

  // Membentuk preferensi berdasarkan pilihan pengguna.
  MenuPreference get preference {
    return MenuPreference(
      group: _group,
      taste: _taste,
      maximumPrice: _budget == 0 ? null : _budget,
    );
  }

  // Mengambil hasil rekomendasi dari Service.
  List<MenuRecommendation> get recommendations {
    return _service.recommend(preference);
  }

  // Mengubah kategori menu.
  void updateGroup(String value) {
    if (!groups.contains(value)) return;

    _group = value;
    notifyListeners();
  }

  // Mengubah preferensi rasa.
  void updateTaste(String value) {
    if (!tastes.contains(value)) return;

    _taste = value;
    notifyListeners();
  }

  // Mengubah batas anggaran.
  void updateBudget(int value) {
    if (!budgets.contains(value)) return;

    _budget = value;
    notifyListeners();
  }

  // Mengembalikan preferensi ke pengaturan awal.
  void resetPreferences() {
    _group = 'Minuman';
    _taste = 'Creamy';
    _budget = 40000;

    notifyListeners();
  }
}