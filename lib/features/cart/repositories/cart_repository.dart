
import '../models/cart_item.dart';

class CartRepository {
  final List<CartItem> _items = [];

  // Mengambil seluruh produk dalam keranjang.
  List<CartItem> getItems() {
    return List.unmodifiable(_items);
  }

  // Menambahkan produk ke keranjang.
  void addItem(CartItem newItem) {
    if (newItem.quantity <= 0) return;

    final index = _items.indexWhere(
      (item) => item.id == newItem.id,
    );

    if (index >= 0) {
      _items[index].quantity += newItem.quantity;
      _items[index].isSelected = true;
    } else {
      _items.add(newItem);
    }
  }

  // Mengubah jumlah produk.
  void updateQuantity(String id, int quantity) {
    final index = _items.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1) return;

    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = quantity;
    }
  }

  // Mengubah konfigurasi produk.
  void updateItem({
    required String currentId,
    required CartItem updatedItem,
  }) {
    final currentIndex = _items.indexWhere(
      (item) => item.id == currentId,
    );

    if (currentIndex == -1) return;

    final previousSelection = _items[currentIndex].isSelected;

    _items.removeAt(currentIndex);

    final sameIndex = _items.indexWhere(
      (item) => item.id == updatedItem.id,
    );

    if (updatedItem.quantity <= 0) return;

    if (sameIndex >= 0) {
      _items[sameIndex].quantity += updatedItem.quantity;
      _items[sameIndex].isSelected =
          _items[sameIndex].isSelected || previousSelection;
    } else {
      updatedItem.isSelected = previousSelection;

      _items.insert(
        currentIndex <= _items.length
            ? currentIndex
            : _items.length,
        updatedItem,
      );
    }
  }

  // Memilih atau membatalkan pilihan produk.
  void toggleItem(String id, bool selected) {
    final index = _items.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1) return;

    _items[index].isSelected = selected;
  }

  // Memilih seluruh produk.
  void selectAll(bool selected) {
    for (final item in _items) {
      item.isSelected = selected;
    }
  }

  // Menghapus satu produk.
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
  }

  // Menghapus produk yang telah dibayar.
  void removePurchasedItems(List<CartItem> purchasedItems) {
    for (final purchasedItem in purchasedItems) {
      if (purchasedItem.quantity <= 0) continue;

      final index = _items.indexWhere(
        (item) => item.id == purchasedItem.id,
      );

      if (index == -1) continue;

      final currentItem = _items[index];
      final remaining = currentItem.quantity - purchasedItem.quantity;

      if (remaining <= 0) {
        _items.removeAt(index);
      } else {
        currentItem.quantity = remaining;
      }
    }
  }

  // Mengosongkan keranjang.
  void clearCart() {
    _items.clear();
  }
}
