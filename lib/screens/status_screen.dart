import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  int selectedTab = 0;

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
              child: selectedTab == 0 ? _buildActiveOrder() : _buildHistory(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // =============================
  // HEADER
  // =============================

  Widget _buildHeader() {
    return Container(
      height: 60,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
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

  // =============================
  // TAB
  // =============================

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
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? AppColors.red : AppColors.lightGrey,
                width: active ? 2.5 : 1,
              ),
            ),
          ),
          alignment: Alignment.center,
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

  // =============================
  // PESANAN AKTIF
  // =============================

  Widget _buildActiveOrder() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pesanan Aktif',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Pantau perkembangan pesananmu di sini',
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.grey),
          ),

          const SizedBox(height: 16),

          _buildOrderInformation(),

          const SizedBox(height: 16),

          _buildStatusProgress(),
        ],
      ),
    );
  }

  Widget _buildOrderInformation() {
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
                      'ORD-20261007-001',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
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
                  color: const Color(0xFFE8F5EB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Sudah Dibayar',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF278A4B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Divider(height: 1, color: AppColors.lightGrey),

          const SizedBox(height: 14),

          _buildInfoRow(label: 'Nama Pelanggan', value: 'Gunawan'),

          const SizedBox(height: 10),

          _buildInfoRow(label: 'Nomor Meja', value: '12'),

          const SizedBox(height: 10),

          _buildInfoRow(label: 'Tipe Pesanan', value: 'Makan di Tempat'),

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

          _buildProductItem(
            image: 'assets/images/milkshake_sweet_mango.png',
            name: 'Milkshake Sweet Mango',
            quantity: '2x',
          ),

          const SizedBox(height: 12),

          _buildProductItem(
            image: 'assets/images/cireng.png',
            name: 'Cireng',
            quantity: '1x',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.grey),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem({
    required String image,
    required String name,
    required String quantity,
  }) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(image, width: 48, height: 48, fit: BoxFit.cover),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.dark,
            ),
          ),
        ),

        Text(
          quantity,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }

  // =============================
  // PROGRESS STATUS
  // =============================

  Widget _buildStatusProgress() {
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

          const SizedBox(height: 18),

          _buildProgressItem(
            title: 'Pesanan Diterima',
            subtitle: 'Pesanan sudah diterima',
            active: true,
            completed: true,
            last: false,
          ),

          _buildProgressItem(
            title: 'Sedang Diproses',
            subtitle: 'Pesanan sedang disiapkan',
            active: true,
            completed: false,
            last: false,
          ),

          _buildProgressItem(
            title: 'Pesanan Siap',
            subtitle: 'Pesanan siap disajikan',
            active: false,
            completed: false,
            last: true,
          ),
        ],
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

  // =============================
  // RIWAYAT PESANAN
  // =============================

  Widget _buildHistory() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

          const SizedBox(height: 16),

          _buildHistoryCard(
            date: '07 Oktober 2026',
            id: 'ORD-20261007-001',
            image: 'assets/images/milkshake_sweet_mango.png',
            itemName: 'Milkshake Sweet Mango',
            quantity: '2 item',
            total: 'Rp 73.000',
          ),

          const SizedBox(height: 14),

          _buildHistoryCard(
            date: '05 Oktober 2026',
            id: 'ORD-20261005-008',
            image: 'assets/images/bakmie_jaya.png',
            itemName: 'Bakmie Jaya',
            quantity: '2 item',
            total: 'Rp 57.000',
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String date,
    required String id,
    required String image,
    required String itemName,
    required String quantity,
    required String total,
  }) {
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
              Text(
                date,
                style: GoogleFonts.poppins(fontSize: 9, color: AppColors.grey),
              ),

              const Spacer(),

              Text(
                'Selesai',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF278A4B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            id,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  image,
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      quantity,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Divider(height: 1, color: AppColors.lightGrey),

          const SizedBox(height: 11),

          Row(
            children: [
              Text(
                'Total Pembayaran',
                style: GoogleFonts.poppins(fontSize: 10, color: AppColors.grey),
              ),

              const Spacer(),

              Text(
                total,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================
  // BOTTOM NAVIGATION
  // =============================

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
              onTap: () {
                Navigator.pop(context);
              },
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
