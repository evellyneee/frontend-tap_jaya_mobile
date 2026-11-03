import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';

// Tahapan proses pesanan.
// completed = selesai dibuat dan siap diambil.
// pickedUp = sudah diambil customer, masuk riwayat.
enum OrderProgress { received, processing, completed, pickedUp }

class SessionOrderItem {
  final String productName;
  final String imagePath;
  final int unitPrice;
  final int quantity;
  final String size;
  final bool extraShot;
  final bool lessIce;
  final bool lessSugar;
  final String note;

  const SessionOrderItem({
    required this.productName,
    required this.imagePath,
    required this.unitPrice,
    required this.quantity,
    required this.size,
    required this.extraShot,
    required this.lessIce,
    required this.lessSugar,
    required this.note,
  });

  factory SessionOrderItem.fromCartItem(CartItem item) {
    return SessionOrderItem(
      productName: item.productName,
      imagePath: item.imagePath,
      unitPrice: item.unitPrice,
      quantity: item.quantity,
      size: item.size,
      extraShot: item.extraShot,
      lessIce: item.lessIce,
      lessSugar: item.lessSugar,
      note: item.note,
    );
  }

  int get totalPrice => unitPrice * quantity;
}

class SessionOrder {
  final String id;
  final String customerName;
  final String orderType;
  final String tableNumber;
  final String paymentMethod;
  final int totalPayment;
  final DateTime createdAt;
  final DateTime paidAt;
  final List<SessionOrderItem> items;

  OrderProgress progress;
  DateTime? pickedUpAt;

  SessionOrder({
    required this.id,
    required this.customerName,
    required this.orderType,
    required this.tableNumber,
    required this.paymentMethod,
    required this.totalPayment,
    required this.createdAt,
    required this.paidAt,
    required this.items,
    this.progress = OrderProgress.received,
    this.pickedUpAt,
  });

  // Selesai dibuat oleh barista.
  bool get isCompleted =>
      progress == OrderProgress.completed || progress == OrderProgress.pickedUp;

  // Benar-benar sudah diambil customer.
  bool get isPickedUp => progress == OrderProgress.pickedUp;

  // Tetap aktif selama belum diambil.
  bool get isActive => !isPickedUp;

  int get totalQuantity {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }
}

class OrderSessionStore extends ChangeNotifier {
  OrderSessionStore._();

  static final OrderSessionStore instance = OrderSessionStore._();

  final List<SessionOrder> _orders = [];

  // Semua pesanan yang belum diambil customer.
  // Termasuk pesanan yang sudah selesai dibuat.
  List<SessionOrder> get activeOrders {
    return List.unmodifiable(_orders.where((order) => order.isActive));
  }

  // Hanya pesanan yang telah diambil customer.
  List<SessionOrder> get historyOrders {
    return List.unmodifiable(_orders.where((order) => order.isPickedUp));
  }

  List<SessionOrder> get allOrders {
    return List.unmodifiable(_orders);
  }

  bool get isEmpty => _orders.isEmpty;

  bool hasOrder(String id) {
    return _orders.any((order) => order.id == id);
  }

  SessionOrder? findOrder(String id) {
    for (final order in _orders) {
      if (order.id == id) {
        return order;
      }
    }

    return null;
  }

  // Catat pesanan setelah pembayaran simulasi sukses.
  void addOrder(SessionOrder order) {
    if (hasOrder(order.id)) {
      return;
    }

    _orders.insert(0, order);

    notifyListeners();
  }

  // Tahap 1 -> Tahap 2
  // Pesanan Diterima -> Sedang Diproses.
  void startProcessing(String id) {
    final order = findOrder(id);

    if (order == null) {
      return;
    }

    if (order.progress != OrderProgress.received) {
      return;
    }

    order.progress = OrderProgress.processing;

    notifyListeners();
  }

  // Tahap 2 -> Tahap 3
  // Sedang Diproses -> Pesanan Selesai.
  // Belum masuk ke riwayat.
  void completeOrder(String id) {
    final order = findOrder(id);

    if (order == null) {
      return;
    }

    if (order.progress != OrderProgress.processing) {
      return;
    }

    order.progress = OrderProgress.completed;

    notifyListeners();
  }

  // Tahap 3 -> Tahap 4
  // Pesanan Selesai -> Pesanan Diambil.
  // Baru masuk ke Riwayat Pesanan.
  void pickUpOrder(String id) {
    final order = findOrder(id);

    if (order == null) {
      return;
    }

    if (order.progress != OrderProgress.completed) {
      return;
    }

    order.progress = OrderProgress.pickedUp;
    order.pickedUpAt = DateTime.now();

    notifyListeners();
  }

  // Mengosongkan data simulasi sesi aplikasi.
  void clearSession() {
    if (_orders.isEmpty) {
      return;
    }

    _orders.clear();

    notifyListeners();
  }
}
