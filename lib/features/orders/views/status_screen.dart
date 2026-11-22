import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tap_jaya_mobile/core/constants/app_colors.dart';
import 'package:tap_jaya_mobile/features/orders/viewmodels/order_session_store.dart';
import 'package:tap_jaya_mobile/features/menu/views/home_screen.dart';
import 'package:tap_jaya_mobile/features/menu/views/info_cafe_screen.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen>
    with WidgetsBindingObserver {
  int selectedTab = 0;

  final OrderSessionStore orderStore = OrderSessionStore.instance;

  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    orderStore.addListener(_refresh);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _synchronizeOrders();
      _startStatusTimer();
    });
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void _synchronizeOrders() {
    if (!mounted) return;

    orderStore.synchronizeActiveOrders();
  }

  void _startStatusTimer() {
    _statusTimer?.cancel();

    _statusTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _synchronizeOrders(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _synchronizeOrders();
      _startStatusTimer();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _statusTimer?.cancel();
      _statusTimer = null;
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    orderStore.removeListener(_refresh);
    super.dispose();
  }

  Route<void> _noAnimationRoute(Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  void _goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      _noAnimationRoute(const HomeScreen()),
      (route) => false,
    );
  }

  void _goToInfoCafe() {
    Navigator.pushReplacement(
      context,
      _noAnimationRoute(const InfoCafeScreen()),
    );
  }

  String formatPrice(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  String formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  String formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '${formatDate(date)}, $hour:$minute';
  }

  bool _isPaymentVerified(SessionOrder order) {
    final status = order.paymentStatus?.trim().toLowerCase();

    return status == 'paid' || status == 'success' || status == 'settlement';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: selectedTab == 0 ? _buildActiveOrders() : _buildHistory(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ===================================================
  // HEADER
  // ===================================================

  Widget _buildHeader() {
    return Container(
      height: 60,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goToHome,
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 19,
              color: AppColors.dark,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Status & Riwayat',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 19),
        ],
      ),
    );
  }

  // ===================================================
  // TAB PESANAN AKTIF DAN RIWAYAT
  // ===================================================

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildTab(title: 'Pesanan Aktif', index: 0),
          _buildTab(title: 'Riwayat Pesanan', index: 1),
        ],
      ),
    );
  }

  Widget _buildTab({required String title, required int index}) {
    final bool active = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            selectedTab = index;
          });

          if (index == 0) {
            _synchronizeOrders();
          }
        },
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.red : AppColors.lightGrey,
                width: active ? 2.5 : 1,
              ),
            ),
          ),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? AppColors.red : AppColors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // ===================================================
  // PESANAN AKTIF
  // ===================================================

  Widget _buildActiveOrders() {
    final orders = orderStore.activeOrders;

    return RefreshIndicator(
      color: AppColors.red,
      onRefresh: () => orderStore.synchronizeActiveOrders(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pesanan Aktif',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
              ),
              if (orderStore.isSynchronizing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.red,
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Perbarui status pesanan',
                onPressed: orderStore.isSynchronizing
                    ? null
                    : _synchronizeOrders,
                icon: const Icon(Icons.refresh, size: 21, color: AppColors.red),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Pantau perkembangan pesananmu di sini',
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.grey),
          ),
          const SizedBox(height: 12),
          if (orderStore.lastSyncError != null)
            _buildSyncWarning(orderStore.lastSyncError!),
          const SizedBox(height: 6),
          if (orders.isEmpty)
            _buildEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Belum ada pesanan aktif',
              subtitle: 'Pesanan yang sudah dibuat akan muncul di sini.',
            )
          else
            ...orders.map(
              (order) => Padding(
                key: ValueKey(order.id),
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  children: [
                    _buildOrderInformation(order),
                    const SizedBox(height: 14),
                    _buildStatusProgress(order),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSyncWarning(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1D6A5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_outlined,
            color: Color(0xFF9A691C),
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '$message Tarik layar ke bawah untuk mencoba lagi.',
              style: GoogleFonts.poppins(fontSize: 10, color: AppColors.dark),
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================
  // INFORMASI PESANAN
  // ===================================================

  Widget _buildOrderInformation(SessionOrder order) {
    final verified = _isPaymentVerified(order);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nomor Pesanan',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.id,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: verified
                      ? const Color(0xFFE8F5EB)
                      : const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  verified ? 'Sudah Dibayar' : 'Belum Terverifikasi',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: verified ? const Color(0xFF278A4B) : AppColors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.lightGrey),
          const SizedBox(height: 14),
          _buildInfoRow(label: 'Nama Pelanggan', value: order.customerName),
          if (order.tableNumber.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoRow(label: 'Nomor Meja', value: order.tableNumber),
          ],
          const SizedBox(height: 10),
          _buildInfoRow(label: 'Tipe Pesanan', value: order.orderType),
          const SizedBox(height: 10),
          _buildInfoRow(
            label: 'Metode Pembayaran',
            value: order.paymentMethod == 'online' ? 'QRIS' : 'Bayar di Kasir',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(label: 'Status Pesanan', value: order.backendStatus),
          const SizedBox(height: 16),
          Text(
            'Detail Pesanan',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildProductItem(item),
            ),
          ),
          const Divider(height: 18, color: AppColors.lightGrey),
          _buildInfoRow(
            label: 'Total Pembayaran',
            value: formatPrice(order.totalPayment),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.grey),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(SessionOrderItem item) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            item.imagePath,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.restaurant_outlined),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.dark,
                ),
              ),
              if (item.size.isNotEmpty)
                Text(
                  item.size,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: AppColors.grey,
                  ),
                ),
              if (item.note.isNotEmpty)
                Text(
                  item.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: AppColors.grey,
                  ),
                ),
            ],
          ),
        ),
        Text(
          '${item.quantity}x',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }

  // ===================================================
  // PROGRES PESANAN DARI BACKEND
  // ===================================================

  Widget _buildStatusProgress(SessionOrder order) {
    final progress = order.progress;

    final received = progress.index >= OrderProgress.received.index;

    final processing = progress.index >= OrderProgress.processing.index;

    final completed = progress.index >= OrderProgress.completed.index;

    final isReady = order.backendStatus == 'Siap';

    final isFinished = order.backendStatus == 'Selesai';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Pesanan',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Status diperbarui otomatis dari sistem cafe.',
            style: GoogleFonts.poppins(fontSize: 9, color: AppColors.grey),
          ),
          const SizedBox(height: 18),
          _buildProgressItem(
            title: 'Pesanan Diterima',
            subtitle: 'Pesanan sudah diterima',
            active: received,
            completed: received,
            last: false,
          ),
          _buildProgressItem(
            title: 'Sedang Diproses',
            subtitle: 'Barista sedang menyiapkan pesanan',
            active: processing,
            completed: processing,
            last: false,
          ),
          _buildProgressItem(
            title: 'Pesanan Selesai',
            subtitle: completed
                ? 'Pesanan sudah selesai disiapkan'
                : 'Menunggu pesanan selesai dibuat',
            active: completed,
            completed: completed,
            last: true,
          ),
          const SizedBox(height: 14),
          if (isReady || isFinished) ...[
            _buildReadyNotice(isFinished: isFinished),
            const SizedBox(height: 12),
            _buildPickupButton(order),
          ],
        ],
      ),
    );
  }

  Widget _buildReadyNotice({required bool isFinished}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBDE2C6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF278A4B),
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              isFinished
                  ? 'Pesanan telah ditandai selesai '
                        'oleh pihak cafe. '
                        'Silakan konfirmasi jika pesanan '
                        'sudah diterima.'
                  : 'Pesanan sudah selesai disiapkan '
                        'dan siap diambil. '
                        'Konfirmasikan setelah pesanan '
                        'benar-benar diterima.',
              style: GoogleFonts.poppins(
                fontSize: 10,
                height: 1.5,
                color: AppColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupButton(SessionOrder order) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          orderStore.pickUpOrder(order.id);

          if (mounted) {
            setState(() {
              selectedTab = 1;
            });
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dark,
          side: const BorderSide(color: AppColors.lightGrey),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Konfirmasi Pesanan Sudah Diambil',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildProgressItem({
    required String title,
    required String subtitle,
    required bool active,
    required bool completed,
    required bool last,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? AppColors.red : Colors.white,
                border: Border.all(
                  color: active ? AppColors.red : AppColors.lightGrey,
                  width: 2,
                ),
              ),
              child: completed
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : active
                  ? const Center(
                      child: CircleAvatar(
                        radius: 3,
                        backgroundColor: Colors.white,
                      ),
                    )
                  : null,
            ),
            if (!last)
              Container(
                width: 2,
                height: 45,
                color: active ? AppColors.red : AppColors.lightGrey,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.dark : AppColors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===================================================
  // RIWAYAT PESANAN
  // ===================================================

  Widget _buildHistory() {
    final orders = orderStore.historyOrders;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        Text(
          'Riwayat Pesanan',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Lihat kembali transaksi yang pernah dilakukan',
          style: GoogleFonts.poppins(fontSize: 10, color: AppColors.grey),
        ),
        const SizedBox(height: 18),
        if (orders.isEmpty)
          _buildEmptyState(
            icon: Icons.history,
            title: 'Belum ada riwayat pesanan',
            subtitle: 'Pesanan yang sudah diambil akan muncul di sini.',
          )
        else
          ...orders.map(
            (order) => Padding(
              key: ValueKey(order.id),
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildHistoryCard(order),
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryCard(SessionOrder order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatDate(order.createdAt),
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: AppColors.grey,
                  ),
                ),
              ),
              Text(
                'Selesai & Diambil',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF278A4B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            order.id,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 10),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildProductItem(item),
            ),
          ),
          const Divider(height: 20, color: AppColors.lightGrey),
          _buildInfoRow(
            label: 'Total Pembayaran',
            value: formatPrice(order.totalPayment),
          ),
          if (order.pickedUpAt != null) ...[
            const SizedBox(height: 10),
            _buildInfoRow(
              label: 'Diambil Pada',
              value: formatDateTime(order.pickedUpAt!),
            ),
          ],
        ],
      ),
    );
  }

  // ===================================================
  // EMPTY STATE
  // ===================================================

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 38),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        children: [
          Icon(icon, size: 44, color: AppColors.grey),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  // ===================================================
  // NAVIGASI BAWAH
  // ===================================================

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        height: 86,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE7E3DF), width: 1)),
        ),
        child: Row(
          children: [
            _buildNavItem(
              icon: Icons.home_outlined,
              label: 'Beranda',
              active: false,
              onTap: _goToHome,
            ),
            _buildNavItem(
              icon: Icons.receipt_long_outlined,
              label: 'Status & Riwayat',
              active: true,
            ),
            _buildNavItem(
              icon: Icons.info_outline,
              label: 'Info Cafe',
              active: false,
              onTap: _goToInfoCafe,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool active,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 31,
              color: active ? AppColors.red : const Color(0xFF737373),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? AppColors.red : const Color(0xFF737373),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
