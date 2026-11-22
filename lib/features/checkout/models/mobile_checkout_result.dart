
class MobileCheckoutResult {
  // =====================================
  // PROPERTIES
  // =====================================

  final String orderNumber;
  final int total;
  final String paymentStatus;
  final String qrUrl;
  final DateTime? expiresAt;

  // =====================================
  // CONSTRUCTOR
  // =====================================

  const MobileCheckoutResult({
    required this.orderNumber,
    required this.total,
    required this.paymentStatus,
    required this.qrUrl,
    this.expiresAt,
  });

  // =====================================
  // FROM JSON
  // =====================================

  factory MobileCheckoutResult.fromJson(
    Map<String, dynamic> json,
  ) {
    // Nomor pesanan.
    final orderNumber =
        json['orderNumber']?.toString().trim() ?? '';

    if (orderNumber.isEmpty) {
      throw const FormatException(
        'Nomor pesanan dari server tidak valid.',
      );
    }

    // Total pembayaran.
    final dynamic rawTotal = json['total'];

    final int total;

    if (rawTotal is num) {
      total = rawTotal.toInt();
    } else if (rawTotal is String) {
      total = int.tryParse(rawTotal.trim()) ?? -1;
    } else {
      total = -1;
    }

    if (total < 0) {
      throw const FormatException(
        'Total pembayaran dari server tidak valid.',
      );
    }

    // Status pembayaran.
    final paymentStatus =
        json['paymentStatus']
            ?.toString()
            .trim()
            .toLowerCase() ??
        'pending';

    // URL atau data QRIS.
    // Masih kosong jika QRIS belum diintegrasikan.
    final qrUrl =
        json['qrUrl']?.toString().trim() ?? '';

    // Waktu kedaluwarsa QRIS.
    final rawExpiresAt = json['expiresAt'];

    DateTime? expiresAt;

    if (rawExpiresAt != null &&
        rawExpiresAt.toString().trim().isNotEmpty) {
      expiresAt = DateTime.tryParse(
        rawExpiresAt.toString(),
      );
    }

    // =====================================
    // RESULT
    // =====================================

    return MobileCheckoutResult(
      orderNumber: orderNumber,
      total: total,
      paymentStatus: paymentStatus.isEmpty
          ? 'pending'
          : paymentStatus,
      qrUrl: qrUrl,
      expiresAt: expiresAt,
    );
  }

  // =====================================
  // PAYMENT STATUS HELPERS
  // =====================================

  bool get isPending =>
      paymentStatus == 'pending';

  bool get isPaid =>
      paymentStatus == 'paid' ||
      paymentStatus == 'success' ||
      paymentStatus == 'settlement';

  bool get isExpired =>
      paymentStatus == 'expired';

  bool get hasQris =>
      qrUrl.isNotEmpty;
}