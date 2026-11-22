import 'package:flutter/foundation.dart';

import '../models/menu_preference.dart';
import '../models/menu_recommendation.dart';
import '../services/menu_recommendation_service.dart';

class MenuRecommendationViewModel extends ChangeNotifier {
  MenuRecommendationViewModel._();

  static final MenuRecommendationViewModel instance =
      MenuRecommendationViewModel._();

  final MenuRecommendationService _service = const MenuRecommendationService();

  String _group = 'Minuman';
  String _taste = 'Creamy';
  int _budget = 40000;

  List<MenuRecommendation> _recommendations = [];

  bool _isLoading = false;
  String? _errorMessage;

  int _requestVersion = 0;

  String get group => _group;
  String get taste => _taste;
  int get budget => _budget;

  List<MenuRecommendation> get recommendations =>
      List.unmodifiable(_recommendations);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const List<String> groups = ['Semua', 'Minuman', 'Makanan', 'Snack'];

  static const List<String> tastes = [
    'Creamy',
    'Manis',
    'Segar',
    'Kopi Kuat',
    'Gurih',
    'Pedas',
    'Apa saja',
  ];

  static const List<int> budgets = [25000, 40000, 60000, 80000, 0];

  MenuPreference get preference {
    return MenuPreference(
      group: _group,
      taste: _taste,
      maximumPrice: _budget == 0 ? null : _budget,
    );
  }

  Future<void> loadRecommendations() async {
    final currentRequest = ++_requestVersion;

    _isLoading = true;
    _errorMessage = null;
    _recommendations = [];
    notifyListeners();

    try {
      final results = await _service.recommend(preference, limit: 3);

      if (currentRequest != _requestVersion) {
        return;
      }

      _recommendations = results;
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      if (currentRequest != _requestVersion) {
        return;
      }

      _recommendations = [];
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateGroup(String value) {
    if (!groups.contains(value)) return;
    if (_group == value) return;

    _group = value;
    loadRecommendations();
  }

  void updateTaste(String value) {
    if (!tastes.contains(value)) return;
    if (_taste == value) return;

    _taste = value;
    loadRecommendations();
  }

  void updateBudget(int value) {
    if (!budgets.contains(value)) return;
    if (_budget == value) return;

    _budget = value;
    loadRecommendations();
  }

  void resetPreferences() {
    _group = 'Minuman';
    _taste = 'Creamy';
    _budget = 40000;

    loadRecommendations();
  }
}
