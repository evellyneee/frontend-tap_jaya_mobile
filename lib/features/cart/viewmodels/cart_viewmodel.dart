import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../repositories/cart_repository.dart';

class CartViewModel extends ChangeNotifier {
  CartViewModel._();

  static final CartViewModel instance = CartViewModel._();

  final CartRepository _repository = CartRepository();

  // Mengambil seluruh produk dalam keranjang.
  List<CartItem> get items => _repository.getItems();

  bool get isEmpty => items.isEmpty;

  int get itemCount => items.length;

  // Total jumlah seluruh produk.
  int get totalQuantity {
    return items.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );
  }

  // Total jumlah produk yang dipilih.
  int get selectedQuantity {
    return items
        .where((item) => item.isSelected)
        .fold<int>(0, (total, item) => total + item.quantity);
  }

  // Total harga produk yang dipilih.
  int get selectedTotal {
    return items
        .where((item) => item.isSelected)
        .fold<int>(0, (total, item) => total + item.totalPrice);
  }

  // Daftar produk yang dipilih.
  List<CartItem> get selectedItems {
    return List.unmodifiable(
      items.where((item) => item.isSelected),
    );
  }

  bool get allSelected {
    if (isEmpty) return false;

    return items.every((item) => item.isSelected);
  }

  bool get hasSelectedItems {
    return items.any((item) => item.isSelected);
  }

  // Menambahkan produk ke keranjang.
  void addItem(CartItem newItem) {
    _repository.addItem(newItem);
    notifyListeners();
  }

  // Mengubah jumlah produk.
  void updateQuantity(String id, int quantity) {
    _repository.updateQuantity(id, quantity);
    notifyListeners();
  }

  // Memperbarui konfigurasi produk.
  void updateItem({
    required String currentId,
    required CartItem updatedItem,
  }) {
    _repository.updateItem(
      currentId: currentId,
      updatedItem: updatedItem,
    );

    notifyListeners();
  }

  // Memilih atau membatalkan pilihan produk.
  void toggleItem(String id, bool selected) {
    _repository.toggleItem(id, selected);
    notifyListeners();
  }

  // Memilih atau membatalkan semua produk.
  void selectAll(bool selected) {
    _repository.selectAll(selected);
    notifyListeners();
  }

  // Menghapus satu produk.
  void removeItem(String id) {
    _repository.removeItem(id);
    notifyListeners();
  }

  // Menghapus produk yang sudah dibayar.
  void removePurchasedItems(List<CartItem> purchasedItems) {
    _repository.removePurchasedItems(purchasedItems);
    notifyListeners();
  }

  // Menghapus seluruh isi keranjang.
  void clearCart() {
    if (isEmpty) return;

    _repository.clearCart();
    notifyListeners();
  }
}
