
import '../../cart/models/cart_item.dart';

class CheckoutData {
  final String customerName;
  final String email;
  final String orderType;
  final String tableNumber;
  final String paymentMethod;
  final int totalPayment;
  final List<CartItem> orderItems;
  final bool isCartCheckout;

  const CheckoutData({
    required this.customerName,
    required this.email,
    required this.orderType,
    required this.tableNumber,
    required this.paymentMethod,
    required this.totalPayment,
    required this.orderItems,
    this.isCartCheckout = false,
  });

  bool get isDineIn => orderType == 'Makan di Tempat';

  bool get isOnline => paymentMethod == 'online';
}
