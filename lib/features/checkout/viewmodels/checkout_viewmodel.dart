
import 'package:flutter/foundation.dart';

import '../models/checkout_data.dart';
import '../models/mobile_checkout_result.dart';
import '../repositories/checkout_repository.dart';

import '../../cart/models/cart_item.dart';
import '../../cart/viewmodels/cart_viewmodel.dart';

// =====================================
// CHECKOUT VIEW MODEL
// =====================================

class CheckoutViewModel extends ChangeNotifier {
  CheckoutViewModel._();

  static final CheckoutViewModel instance =
      CheckoutViewModel._();

  final CheckoutRepository _repository =
      CheckoutRepository();

  final CartViewModel _cartViewModel =
      CartViewModel.instance;

  // =====================================
  // PAYMENT STATE
  // =====================================

  String selectedPayment = 'online';

  bool agreeTerms = false;
  bool cashierConfirmation = false;

  bool isProcessing = false;
  bool paymentSuccessful = false;

  String? errorMessage;

  // =====================================
  // BACKEND ORDER STATE
  // =====================================

  MobileCheckoutResult? checkoutResult;

  String? get backendOrderNumber =>
      checkoutResult?.orderNumber;

  int? get backendTotal =>
      checkoutResult?.total;

  String get paymentStatus =>
      checkoutResult?.paymentStatus ?? 'pending';

  String get qrUrl =>
      checkoutResult?.qrUrl ?? '';

  DateTime? get expiresAt =>
      checkoutResult?.expiresAt;

  bool get orderCreated =>
      checkoutResult != null;

  // =====================================
  // SELECT PAYMENT
  // =====================================

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

  // =====================================
  // RESET FORM
  // =====================================

  void resetForm() {
    selectedPayment = 'online';

    agreeTerms = false;
    cashierConfirmation = false;

    paymentSuccessful = false;
    isProcessing = false;

    checkoutResult = null;
    errorMessage = null;

    notifyListeners();
  }

  // =====================================
  // VALIDASI PELANGGAN
  // =====================================

  String? validateCustomer({
    required String name,
    required String email,
    required String orderType,
  }) {
    if (name.trim().isEmpty ||
        email.trim().isEmpty) {
      return 'Lengkapi informasi pelanggan terlebih dahulu.';
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email.trim())) {
      return 'Masukkan alamat email yang valid.';
    }

    if (orderType.trim().isEmpty) {
      return 'Pilih jenis pesanan terlebih dahulu.';
    }

    return null;
  }

  // =====================================
  // VALIDASI PEMBAYARAN
  // =====================================

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

    final isDineIn =
        orderType == 'Makan di Tempat' ||
        orderType == 'Dine-in';

    if (isDineIn &&
        tableNumber.trim().isEmpty) {
      return 'Masukkan nomor meja terlebih dahulu.';
    }

    if (!agreeTerms) {
      return 'Setujui syarat dan kebijakan privasi terlebih dahulu.';
    }

    if (selectedPayment == 'cashier' &&
        !cashierConfirmation) {
      return 'Centang konfirmasi pembayaran di kasir.';
    }

    return null;
  }

  // =====================================
  // CREATE CHECKOUT DATA
  // =====================================

  CheckoutData createCheckoutData({
    required String name,
    required String email,
    required String orderType,
    required String tableNumber,
    required int totalPayment,
    required List<CartItem> orderItems,
    required bool isCartCheckout,
  }) {
    final isDineIn =
        orderType == 'Makan di Tempat' ||
        orderType == 'Dine-in';

    return CheckoutData(
      customerName: name.trim(),
      email: email.trim(),
      orderType: orderType,
      tableNumber:
          isDineIn ? tableNumber.trim() : '',
      paymentMethod: selectedPayment,
      totalPayment: totalPayment,
      orderItems: List.unmodifiable(orderItems),
      isCartCheckout: isCartCheckout,
    );
  }

  // =====================================
  // CREATE ORDER IN BACKEND
  // =====================================

  Future<bool> completePayment({
    required CheckoutData data,
    required String orderNumber,
    required DateTime createdAt,
    required DateTime paidAt,
    String? customerToken,
  }) async {
    // Parameter orderNumber, createdAt, dan paidAt
    // dipertahankan untuk kompatibilitas
    // dengan layar Flutter yang sudah ada.
    //
    // Nomor pesanan resmi berasal dari backend.
    // paidAt tidak digunakan sebagai bukti pembayaran.

    if (isProcessing) {
      return false;
    }

    // Jangan membuat pesanan yang sama dua kali
    // selama hasil checkout masih tersimpan.
    if (checkoutResult != null) {
      return true;
    }

    if (data.orderItems.isEmpty) {
      errorMessage =
          'Tidak ada produk yang dapat dicatat.';
      notifyListeners();
      return false;
    }

    isProcessing = true;
    paymentSuccessful = false;
    errorMessage = null;

    notifyListeners();

    try {
      // =====================================
      // SEND ORDER TO BACKEND
      // =====================================

      final result =
          await _repository.createQrisOrder(
        customerName: data.customerName,
        customerEmail: data.email,
        orderType: data.orderType,
        tableNumber: data.tableNumber,
        totalPayment: data.totalPayment,
        orderItems: data.orderItems,
        customerToken: customerToken,
      );

      // =====================================
      // SAVE BACKEND RESPONSE
      // =====================================

      checkoutResult = result;

      // Pesanan sudah dibuat, tetapi pembayaran
      // belum tentu berhasil.
      paymentSuccessful = result.isPaid;

      // =====================================
      // UPDATE CART
      // =====================================

      // Keranjang tidak dihapus sebelum pembayaran
      // benar-benar terverifikasi.
      if (paymentSuccessful &&
          data.isCartCheckout) {
        _cartViewModel.removePurchasedItems(
          data.orderItems,
        );
      }

      return true;
    } catch (error) {
      errorMessage =
          'Gagal membuat pesanan: $error';

      return false;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  // =====================================
  // REFRESH ORDER STATUS
  // =====================================

  Future<Map<String, dynamic>?>
      refreshOrderStatus() async {
    final orderNumber =
        checkoutResult?.orderNumber;

    if (orderNumber == null ||
        orderNumber.isEmpty) {
      errorMessage =
          'Belum ada pesanan yang dibuat.';
      notifyListeners();
      return null;
    }

    try {
      final order =
          await _repository.getPaymentStatus(
        orderNumber,
      );

      errorMessage = null;
      notifyListeners();

      // Endpoint ini mengembalikan status pesanan,
      // bukan verifikasi pembayaran QRIS.
      return order;
    } catch (error) {
      errorMessage =
          'Gagal memperbarui status pesanan: $error';

      notifyListeners();
      return null;
    }
  }

  // =====================================
  // CLEAR ERROR
  // =====================================

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // =====================================
  // DISPOSE
  // =====================================

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}