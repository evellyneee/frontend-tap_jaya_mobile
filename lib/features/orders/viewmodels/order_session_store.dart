import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tap_jaya_mobile/core/config/api_config.dart';

import '../../cart/models/cart_item.dart';

// =====================================
// STATUS PESANAN FLUTTER
// =====================================

enum OrderProgress { received, processing, completed, pickedUp }

// =====================================
// MODEL ITEM PESANAN
// =====================================

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

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'imagePath': imagePath,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'size': size,
      'extraShot': extraShot,
      'lessIce': lessIce,
      'lessSugar': lessSugar,
      'note': note,
    };
  }

  factory SessionOrderItem.fromJson(Map<String, dynamic> json) {
    return SessionOrderItem(
      productName: json['productName']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? '',
      unitPrice: _readInt(json['unitPrice']),
      quantity: _readInt(json['quantity']),
      size: json['size']?.toString() ?? '',
      extraShot: json['extraShot'] == true,
      lessIce: json['lessIce'] == true,
      lessSugar: json['lessSugar'] == true,
      note: json['note']?.toString() ?? '',
    );
  }
}

// =====================================
// MODEL PESANAN
// =====================================

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
  String backendStatus;
  String? paymentStatus;

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
    this.backendStatus = 'Menunggu',
    this.paymentStatus,
  });

  bool get isCompleted =>
      progress == OrderProgress.completed || progress == OrderProgress.pickedUp;

  bool get isPickedUp => progress == OrderProgress.pickedUp;

  bool get isActive => !isPickedUp;

  int get totalQuantity {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'orderType': orderType,
      'tableNumber': tableNumber,
      'paymentMethod': paymentMethod,
      'totalPayment': totalPayment,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'progress': progress.name,
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'backendStatus': backendStatus,
      'paymentStatus': paymentStatus,
    };
  }

  factory SessionOrder.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    final parsedItems = <SessionOrderItem>[];

    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          parsedItems.add(
            SessionOrderItem.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final progressName = json['progress']?.toString() ?? '';

    final progress = OrderProgress.values.firstWhere(
      (value) => value.name == progressName,
      orElse: () => OrderProgress.received,
    );

    return SessionOrder(
      id: json['id']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      orderType: json['orderType']?.toString() ?? '',
      tableNumber: json['tableNumber']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      totalPayment: _readInt(json['totalPayment']),
      createdAt: _readDateTime(json['createdAt']),
      paidAt: _readDateTime(json['paidAt']),
      items: parsedItems,
      progress: progress,
      pickedUpAt: _readNullableDateTime(json['pickedUpAt']),
      backendStatus: json['backendStatus']?.toString() ?? 'Menunggu',
      paymentStatus: json['paymentStatus']?.toString(),
    );
  }
}

// =====================================
// UTILITAS PARSING
// =====================================

int _readInt(dynamic value) {
  if (value is int) return value;

  if (value is num) return value.toInt();

  return num.tryParse(value?.toString() ?? '')?.toInt() ?? 0;
}

DateTime _readDateTime(dynamic value) {
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}

DateTime? _readNullableDateTime(dynamic value) {
  if (value == null) return null;

  return DateTime.tryParse(value.toString());
}

// =====================================
// ORDER SESSION STORE
// =====================================

class OrderSessionStore extends ChangeNotifier {
  OrderSessionStore._();

  static final OrderSessionStore instance = OrderSessionStore._();

  static const String _storageKey = 'tapjaya_customer_orders_v1';

  final List<SessionOrder> _orders = [];

  bool _initialized = false;
  bool _isSynchronizing = false;
  String? _lastSyncError;

  Future<void>? _initializationFuture;
  Future<void> _pendingSave = Future<void>.value();

  bool get isInitialized => _initialized;
  bool get isSynchronizing => _isSynchronizing;
  String? get lastSyncError => _lastSyncError;

  List<SessionOrder> get activeOrders {
    return List.unmodifiable(_orders.where((order) => order.isActive));
  }

  List<SessionOrder> get historyOrders {
    return List.unmodifiable(_orders.where((order) => order.isPickedUp));
  }

  List<SessionOrder> get allOrders {
    return List.unmodifiable(_orders);
  }

  bool get isEmpty => _orders.isEmpty;

  String _normalizeNumber(String value) {
    return value.trim().replaceFirst(RegExp(r'^#'), '');
  }

  bool hasOrder(String id) {
    return findOrder(id) != null;
  }

  SessionOrder? findOrder(String id) {
    final normalized = _normalizeNumber(id);

    for (final order in _orders) {
      if (_normalizeNumber(order.id) == normalized) {
        return order;
      }
    }

    return null;
  }

  // =====================================
  // MEMUAT PESANAN TERSIMPAN
  // =====================================

  Future<void> initialize() {
    return _initializationFuture ??= _initializeInternal();
  }

  Future<void> _initializeInternal() async {
    try {
      final preferences = await SharedPreferences.getInstance();

      final storedJson = preferences.getString(_storageKey);

      if (storedJson != null && storedJson.isNotEmpty) {
        final decoded = jsonDecode(storedJson);

        if (decoded is List) {
          final restoredOrders = <SessionOrder>[];

          for (final value in decoded) {
            if (value is! Map) continue;

            try {
              final order = SessionOrder.fromJson(
                Map<String, dynamic>.from(value),
              );

              if (order.id.trim().isNotEmpty) {
                restoredOrders.add(order);
              }
            } catch (error) {
              debugPrint('Pesanan tersimpan tidak valid: $error');
            }
          }

          final existingIds = _orders
              .map((order) => _normalizeNumber(order.id))
              .toSet();

          for (final order in restoredOrders) {
            final normalized = _normalizeNumber(order.id);

            if (!existingIds.contains(normalized)) {
              _orders.add(order);
              existingIds.add(normalized);
            }
          }
        }
      }
    } catch (error) {
      _lastSyncError = 'Gagal memuat riwayat tersimpan: $error';

      debugPrint(_lastSyncError);
    } finally {
      _initialized = true;
      notifyListeners();
    }

    // Periksa status terkini setelah data
    // lokal berhasil dipulihkan.
    await synchronizeActiveOrders();
  }

  // =====================================
  // MENYIMPAN PESANAN KE PERANGKAT
  // =====================================

  Future<void> _saveOrders() {
    // Ambil snapshot sekarang agar penulisan
    // berurutan tidak memakai data yang berubah.
    final encoded = jsonEncode(_orders.map((order) => order.toJson()).toList());

    _pendingSave = _pendingSave
        .catchError((Object error) {
          debugPrint('Penyimpanan sebelumnya gagal: $error');
        })
        .then((_) async {
          final preferences = await SharedPreferences.getInstance();

          final success = await preferences.setString(_storageKey, encoded);

          if (!success) {
            throw Exception('Penyimpanan pesanan gagal.');
          }
        });

    return _pendingSave;
  }

  void _persistChanges() {
    notifyListeners();

    unawaited(
      _saveOrders().catchError((Object error) {
        debugPrint('Gagal menyimpan sesi pesanan: $error');
      }),
    );
  }

  // =====================================
  // MENAMBAHKAN PESANAN
  // =====================================

  void addOrder(SessionOrder order) {
    if (hasOrder(order.id)) {
      return;
    }

    _orders.insert(0, order);
    _persistChanges();
  }

  // =====================================
  // STATUS DARI BACKEND
  // =====================================

  OrderProgress? _mapBackendStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'menunggu':
        return OrderProgress.received;

      case 'diproses':
        return OrderProgress.processing;

      case 'siap':
      case 'selesai':
        return OrderProgress.completed;

      default:
        return null;
    }
  }

  // =====================================
  // SINKRONISASI SATU PESANAN
  // =====================================

  Future<bool> synchronizeOrder(String orderNumber) async {
    final order = findOrder(orderNumber);

    if (order == null) {
      return false;
    }

    final normalized = _normalizeNumber(orderNumber);

    if (normalized.isEmpty) {
      return false;
    }

    final uri = Uri.parse(
      '${ApiConfig.ordersUrl}/'
      '${Uri.encodeComponent(normalized)}',
    );

    try {
      final response = await http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'HTTP ${response.statusCode}: '
          '${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Format respons API tidak valid.');
      }

      if (decoded['success'] != true) {
        throw Exception(
          decoded['message']?.toString() ?? 'Gagal mengambil pesanan.',
        );
      }

      final data = decoded['data'];

      if (data is! Map<String, dynamic>) {
        throw const FormatException('Data pesanan tidak valid.');
      }

      final returnedNumber = _normalizeNumber(
        data['orderNumber']?.toString() ?? '',
      );

      if (returnedNumber != normalized) {
        throw const FormatException('Nomor pesanan tidak sesuai.');
      }

      final backendStatus = data['status']?.toString() ?? '';

      final nextProgress = _mapBackendStatus(backendStatus);

      if (nextProgress == null) {
        throw FormatException('Status tidak dikenal: $backendStatus');
      }

      var changed = false;

      if (order.backendStatus != backendStatus) {
        order.backendStatus = backendStatus;
        changed = true;
      }

      if (!order.isPickedUp && order.progress != nextProgress) {
        order.progress = nextProgress;
        changed = true;
      }

      final paymentStatus = data['paymentStatus'];

      if (paymentStatus is String && order.paymentStatus != paymentStatus) {
        order.paymentStatus = paymentStatus;
        changed = true;
      }

      if (changed) {
        _persistChanges();
      }

      return true;
    } catch (error) {
      debugPrint('Gagal sinkronisasi $normalized: $error');

      return false;
    }
  }

  // =====================================
  // SINKRONISASI PESANAN AKTIF
  // =====================================

  Future<void> synchronizeActiveOrders() async {
    if (_isSynchronizing) {
      return;
    }

    final pendingOrders = List<SessionOrder>.from(activeOrders);

    if (pendingOrders.isEmpty) {
      if (_lastSyncError != null) {
        _lastSyncError = null;
        notifyListeners();
      }

      return;
    }

    _isSynchronizing = true;
    _lastSyncError = null;
    notifyListeners();

    try {
      final results = await Future.wait(
        pendingOrders.map((order) => synchronizeOrder(order.id)),
      );

      final failedCount = results.where((success) => !success).length;

      if (failedCount > 0) {
        _lastSyncError =
            '$failedCount pesanan belum berhasil '
            'disinkronkan dengan server.';
      }
    } catch (error) {
      _lastSyncError = 'Gagal menyinkronkan pesanan: $error';
    } finally {
      _isSynchronizing = false;
      notifyListeners();
    }
  }

  // =====================================
  // KOMPATIBILITAS METODE LAMA
  // =====================================

  void startProcessing(String id) {
    final order = findOrder(id);

    if (order == null || order.progress != OrderProgress.received) {
      return;
    }

    order.progress = OrderProgress.processing;
    _persistChanges();
  }

  void completeOrder(String id) {
    final order = findOrder(id);

    if (order == null || order.progress != OrderProgress.processing) {
      return;
    }

    order.progress = OrderProgress.completed;
    _persistChanges();
  }

  // Konfirmasi pengambilan hanya lokal.
  // Backend belum memiliki endpoint pengambilan
  // dengan otorisasi pelanggan.
  void pickUpOrder(String id) {
    final order = findOrder(id);

    if (order == null || order.progress != OrderProgress.completed) {
      return;
    }

    order.progress = OrderProgress.pickedUp;
    order.pickedUpAt = DateTime.now();

    _persistChanges();
  }

  // =====================================
  // MENGHAPUS SESI LOKAL
  // =====================================

  void clearSession() {
    if (_orders.isEmpty) {
      return;
    }

    _orders.clear();
    _lastSyncError = null;

    _persistChanges();
  }
}
