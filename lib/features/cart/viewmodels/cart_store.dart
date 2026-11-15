import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';

class CartStore extends ChangeNotifier {
  CartStore._();

  static final CartStore instance = CartStore._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.length;

  // Total jumlah seluruh produk di keranjang.
  int get totalQuantity {
    return _items.fold<int>(0, (total, item) => total + item.quantity);
  }

  // Total jumlah produk yang dipilih.
  int get selectedQuantity {
    return _items
        .where((item) => item.isSelected)
        .fold<int>(0, (total, item) => total + item.quantity);
  }

  // Total harga produk yang dipilih.
  int get selectedTotal {
    return _items
        .where((item) => item.isSelected)
        .fold<int>(0, (total, item) => total + item.totalPrice);
  }

  // Daftar produk yang dipilih.
  List<CartItem> get selectedItems {
    return List.unmodifiable(_items.where((item) => item.isSelected));
  }

  bool get allSelected {
    if (_items.isEmpty) {
      return false;
    }

    return _items.every((item) => item.isSelected);
  }

  bool get hasSelectedItems {
    return _items.any((item) => item.isSelected);
  }

  // Menambahkan produk ke keranjang.
  void addItem(CartItem newItem) {
    if (newItem.quantity <= 0) {
      return;
    }

    final int existingIndex = _items.indexWhere(
      (item) => item.id == newItem.id,
    );

    if (existingIndex >= 0) {
      final existingItem = _items[existingIndex];

      existingItem.quantity += newItem.quantity;
      existingItem.isSelected = true;
    } else {
      _items.add(newItem);
    }

    notifyListeners();
  }

  // Mengubah jumlah produk dalam keranjang.
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

  // Memperbarui konfigurasi produk.
  void updateItem({required String currentId, required CartItem updatedItem}) {
    final int currentIndex = _items.indexWhere((item) => item.id == currentId);

    if (currentIndex == -1) {
      return;
    }

    final bool previousSelection = _items[currentIndex].isSelected;

    _items.removeAt(currentIndex);

    final int sameConfigurationIndex = _items.indexWhere(
      (item) => item.id == updatedItem.id,
    );

    if (updatedItem.quantity > 0) {
      if (sameConfigurationIndex >= 0) {
        final existingItem = _items[sameConfigurationIndex];

        existingItem.quantity += updatedItem.quantity;

        existingItem.isSelected = existingItem.isSelected || previousSelection;
      } else {
        updatedItem.isSelected = previousSelection;

        _items.insert(
          currentIndex <= _items.length ? currentIndex : _items.length,
          updatedItem,
        );
      }
    }

    notifyListeners();
  }

  // Memilih atau membatalkan pilihan produk.
  void toggleItem(String id, bool selected) {
    final int index = _items.indexWhere((item) => item.id == id);

    if (index == -1) {
      return;
    }

    _items[index].isSelected = selected;

    notifyListeners();
  }

  // Memilih atau membatalkan semua produk.
  void selectAll(bool selected) {
    if (_items.isEmpty) {
      return;
    }

    for (final item in _items) {
      item.isSelected = selected;
    }

    notifyListeners();
  }

  // Menghapus satu produk secara manual.
  void removeItem(String id) {
    final int previousLength = _items.length;

    _items.removeWhere((item) => item.id == id);

    if (_items.length != previousLength) {
      notifyListeners();
    }
  }

  // =========================================
  // BARU: HAPUS PRODUK YANG SUDAH DIBAYAR
  // =========================================

  // Dipanggil HANYA setelah pembayaran berhasil
  // dan HANYA untuk checkout yang berasal
  // dari keranjang, bukan Beli Sekarang.
  //
  // Penghapusan menggunakan ID konfigurasi produk
  // dan jumlah yang dibeli.
  //
  // Contoh:
  // Keranjang berisi:
  // - Kopi 1x (dipilih)
  // - Bakmie 1x (tidak dipilih)
  //
  // Setelah checkout kopi berhasil:
  // - Kopi dihapus
  // - Bakmie tetap ada.
  //
  // Jika jumlah kopi bertambah saat checkout
  // sedang berjalan, hanya kuantitas transaksi
  // yang dikurangi.

  void removePurchasedItems(List<CartItem> purchasedItems) {
    if (purchasedItems.isEmpty || _items.isEmpty) {
      return;
    }

    bool changed = false;

    for (final purchasedItem in purchasedItems) {
      if (purchasedItem.quantity <= 0) {
        continue;
      }

      final int index = _items.indexWhere(
        (item) => item.id == purchasedItem.id,
      );

      if (index == -1) {
        continue;
      }

      final CartItem currentItem = _items[index];

      final int remainingQuantity =
          currentItem.quantity - purchasedItem.quantity;

      if (remainingQuantity <= 0) {
        _items.removeAt(index);
      } else {
        currentItem.quantity = remainingQuantity;
      }

      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  // Menghapus seluruh isi keranjang.
  // Tidak digunakan untuk checkout parsial.
  void clearCart() {
    if (_items.isEmpty) {
      return;
    }

    _items.clear();

    notifyListeners();
  }
}
