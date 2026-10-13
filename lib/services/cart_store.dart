import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';

class CartStore extends ChangeNotifier {
  CartStore._();

  static final CartStore instance = CartStore._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.length;

  int get totalQuantity {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  int get selectedQuantity {
    return _items
        .where((item) => item.isSelected)
        .fold(0, (total, item) => total + item.quantity);
  }

  int get selectedTotal {
    return _items
        .where((item) => item.isSelected)
        .fold(0, (total, item) => total + item.totalPrice);
  }

  bool get allSelected {
    if (_items.isEmpty) {
      return false;
    }

    return _items.every((item) => item.isSelected);
  }

  void addItem(CartItem newItem) {
    final int existingIndex = _items.indexWhere(
      (item) => item.id == newItem.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += newItem.quantity;

      _items[existingIndex].isSelected = true;
    } else {
      _items.add(newItem);
    }

    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    final int index = _items.indexWhere((item) => item.id == id);

    if (index == -1) {
      return;
    }

    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = quantity;
    }

    notifyListeners();
  }

  void updateItem({required String currentId, required CartItem updatedItem}) {
    final int currentIndex = _items.indexWhere((item) => item.id == currentId);

    if (currentIndex == -1) {
      return;
    }

    final bool previousSelection = _items[currentIndex].isSelected;

    final int sameConfigurationIndex = _items.indexWhere(
      (item) => item.id == updatedItem.id && item.id != currentId,
    );

    if (sameConfigurationIndex >= 0) {
      _items[sameConfigurationIndex].quantity += updatedItem.quantity;

      _items[sameConfigurationIndex].isSelected =
          _items[sameConfigurationIndex].isSelected || previousSelection;

      _items.removeAt(currentIndex);
    } else {
      updatedItem.isSelected = previousSelection;

      _items[currentIndex] = updatedItem;
    }

    notifyListeners();
  }

  void toggleItem(String id, bool selected) {
    final int index = _items.indexWhere((item) => item.id == id);

    if (index == -1) {
      return;
    }

    _items[index].isSelected = selected;

    notifyListeners();
  }

  void selectAll(bool selected) {
    for (final item in _items) {
      item.isSelected = selected;
    }

    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);

    notifyListeners();
  }

  void clearCart() {
    _items.clear();

    notifyListeners();
  }
}
