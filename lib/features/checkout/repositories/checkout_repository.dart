
import '../../cart/models/cart_item.dart';
import '../../orders/viewmodels/order_session_store.dart';

class CheckoutRepository {
  final OrderSessionStore _orderStore = OrderSessionStore.instance;

  // Menyimpan pesanan setelah pembayaran berhasil.
  void saveOrder({
    required String orderNumber,
    required String customerName,
    required String orderType,
    required String tableNumber,
    required String paymentMethod,
    required int totalPayment,
    required DateTime createdAt,
    required DateTime paidAt,
    required List<CartItem> orderItems,
  }) {
    final order = SessionOrder(
      id: orderNumber,
      customerName: customerName,
      orderType: orderType,
      tableNumber: tableNumber,
      paymentMethod: paymentMethod,
      totalPayment: totalPayment,
      createdAt: createdAt,
      paidAt: paidAt,
      items: orderItems
          .map(SessionOrderItem.fromCartItem)
          .toList(),
    );

    _orderStore.addOrder(order);
  }

  // Memeriksa apakah nomor pesanan sudah tersimpan.
  bool hasOrder(String orderNumber) {
    return _orderStore.hasOrder(orderNumber);
  }
}
