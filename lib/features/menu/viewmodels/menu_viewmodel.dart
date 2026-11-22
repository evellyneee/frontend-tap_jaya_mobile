
import 'package:flutter/foundation.dart';

import '../models/customer_product.dart';
import '../repositories/menu_repository.dart';

class MenuViewModel extends ChangeNotifier {
  final MenuRepository _repository;

  MenuViewModel({
    MenuRepository? repository,
  }) : _repository = repository ?? const MenuRepository();

  // WAJIB CustomerProduct, bukan Map<String, String>
  List<CustomerProduct> _products = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<CustomerProduct> get products =>
      List.unmodifiable(_products);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  bool get isEmpty => _products.isEmpty;

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<CustomerProduct> result =
          await _repository.getProducts();

      _products = result;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}