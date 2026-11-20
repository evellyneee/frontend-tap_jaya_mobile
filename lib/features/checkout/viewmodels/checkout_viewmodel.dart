
import 'package:flutter/foundation.dart';

import '../models/checkout_data.dart';
import '../repositories/checkout_repository.dart';

import '../../cart/models/cart_item.dart';
import '../../cart/viewmodels/cart_viewmodel.dart';

class CheckoutViewModel extends ChangeNotifier {
  CheckoutViewModel._();

  static final CheckoutViewModel instance = CheckoutViewModel._();

  final CheckoutRepository _repository = CheckoutRepository();

  final CartViewModel _cartViewModel = CartViewModel.instance;

  String selectedPayment = 'online';

  bool agreeTerms = false;
  bool cashierConfirmation = false;

  bool isProcessing = false;
  bool paymentSuccessful = false;

  String? errorMessage;

  void selectPayment(String method) {
    selectedPayment = method;
    errorMessage = null;
    notifyListeners();
  }

  void setAgreeTerms(bool value) {
    agreeTerms = value;
    errorMessage = null;
    notifyListeners();
  }

  void setCashierConfirmation(bool value) {
    cashierConfirmation = value;
    errorMessage = null;
    notifyListeners();
  }

  void resetForm() {
    selectedPayment = 'online';
    agreeTerms = false;
    cashierConfirmation = false;
    errorMessage = null;
    notifyListeners();
  }

  // Validasi informasi pelanggan.
  String? validateCustomer({
    required String name,
    required String email,
    required String orderType,
  }) {
    if (name.trim().isEmpty || email.trim().isEmpty) {
      return 'Lengkapi informasi pelanggan terlebih dahulu.';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
        .hasMatch(email.trim())) {
      return 'Masukkan alamat email yang valid.';
    }

    if (orderType == 'Makan di Tempat') {
      return null;
    }

    return null;
  }

  // Validasi sebelum menuju pembayaran.
  String? validatePayment({
    required String name,
    required String email,
    required String tableNumber,
    required String orderType,
  }) {
    final customerError = validateCustomer(
      name: name,
      email: email,
      orderType: orderType,
    );

    if (customerError != null) {
      return customerError;
    }

    if (orderType == 'Makan di Tempat' &&
        tableNumber.trim().isEmpty) {
      return 'Masukkan nomor meja terlebih dahulu.';
    }

    if (!agreeTerms) {
      return 'Setujui syarat dan kebijakan privasi terlebih dahulu.';
    }

    if (selectedPayment == 'cashier' && !cashierConfirmation) {
      return 'Centang konfirmasi pembayaran di kasir.';
    }

    return null;
  }

  // Membuat data checkout.
  CheckoutData createCheckoutData({
    required String name,
    required String email,
    required String orderType,
    required String tableNumber,
    required int totalPayment,
    required List<CartItem> orderItems,
    required bool isCartCheckout,
  }) {
    return CheckoutData(
      customerName: name.trim(),
      email: email.trim(),
      orderType: orderType,
      tableNumber: orderType == 'Makan di Tempat'
          ? tableNumber.trim()
          : '',
      paymentMethod: selectedPayment,
      totalPayment: totalPayment,
      orderItems: List.unmodifiable(orderItems),
      isCartCheckout: isCartCheckout,
    );
  }

  // Menyelesaikan pembayaran dan mencatat pesanan.
  bool completePayment({
    required CheckoutData data,
    required String orderNumber,
    required DateTime createdAt,
    required DateTime paidAt,
  }) {
    if (paymentSuccessful || isProcessing) {
      return false;
    }

    if (data.orderItems.isEmpty) {
      errorMessage = 'Tidak ada produk yang dapat dicatat.';
      notifyListeners();
      return false;
    }

    if (_repository.hasOrder(orderNumber)) {
      errorMessage = 'Pesanan sudah pernah dicatat.';
      notifyListeners();
      return false;
    }

    isProcessing = true;
    notifyListeners();

    try {
      _repository.saveOrder(
        orderNumber: orderNumber,
        customerName: data.customerName,
        orderType: data.orderType,
        tableNumber: data.tableNumber,
        paymentMethod: data.paymentMethod,
        totalPayment: data.totalPayment,
        createdAt: createdAt,
        paidAt: paidAt,
        orderItems: data.orderItems,
      );

      if (data.isCartCheckout) {
        _cartViewModel.removePurchasedItems(data.orderItems);
      }

      paymentSuccessful = true;
      errorMessage = null;

      return true;
    } catch (error) {
      errorMessage = 'Gagal menyimpan pesanan: $error';
      return false;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
