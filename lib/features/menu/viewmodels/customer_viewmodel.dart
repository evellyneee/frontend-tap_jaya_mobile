import 'package:flutter/foundation.dart';

import '../repositories/customer_repository.dart';

class CustomerViewModel extends ChangeNotifier {
  final CustomerRepository _repository;

  CustomerViewModel({CustomerRepository? repository})
    : _repository = repository ?? CustomerRepository();

  List<Map<String, dynamic>> _products = [];

  bool _isLoading = false;

  String? _errorMessage;

  List<Map<String, dynamic>> get products => _products;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.getProducts();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
