
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../widgets/app_logo.dart';

import 'home_screen.dart';
import 'status_screen.dart';

class InfoCafeScreen extends StatelessWidget {
  const InfoCafeScreen({super.key});

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Route<void> _noAnimationRoute(Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return page;
      },
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  void _goToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      _noAnimationRoute(const HomeScreen()),
      (route) => false,
    );
  }

  void _goToStatus(BuildContext context) {
    Navigator.pushReplacement(
      context,
      _noAnimationRoute(const StatusScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 28),

            Text(
              'Info Cafe',
              style: GoogleFonts.poppins(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),

            const SizedBox(height: 32),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo dan nama kafe
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: const Color(0xFFE7E3DF),
                            ),
                          ),
                          child: const AppLogo(width: 48),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Text(
                            'Toko Kopi Jaya,\nBegawan',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Nikmati sajian kopi pilihan dan suasana '
                      'nyaman untuk bersantai maupun bekerja '
                      'di Begawan.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        height: 1.5,
                        color: const Color(0xFF555555),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Informasi operasional
                    _buildInfoCard(
                      title: 'Layanan & Jam Operasional',
                      children: [
                        _buildInfoRow(
                          Icons.access_time,
                          'Jam Buka: 08.30 - 22.30 WIB\n'
                          '(Pemesanan Terakhir pukul 22.00)',
                        ),

                        const SizedBox(height: 14),

                        _buildInfoRow(
                          Icons.location_on_outlined,
                          'Jl. Raya Tlogomas No. 9, '
                          'Begawan, Malang',
                        ),

                        const SizedBox(height: 18),

                        _buildButton(
                          label:
                              'Beri rating & ulasan di Google Maps',
                          dark: false,
                          onPressed: () {
                            _showMessage(
                              context,
                              'Tautan Google Maps belum dihubungkan.',
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Informasi layanan pelanggan
                    _buildInfoCard(
                      title: 'Layanan Pelanggan',
                      children: [
                        _buildInfoRow(
                          Icons.phone_outlined,
                          'Saluran Bantuan: +62 812-3456-7890',
                        ),

                        const SizedBox(height: 14),

                        _buildInfoRow(
                          Icons.email_outlined,
                          'Email: support@tapjaya.com',
                        ),

                        const SizedBox(height: 18),

                        _buildButton(
                          label: 'Chat dengan AI Assistant',
                          dark: true,
                          onPressed: () {
                            _showMessage(
                              context,
                              'AI Assistant belum dihubungkan.',
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          _buildBottomNavigation(context),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE0DDD9),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),

          const SizedBox(height: 15),

          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String information,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF666666),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            information,
            style: GoogleFonts.poppins(
              fontSize: 11,
              height: 1.5,
              color: const Color(0xFF555555),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
    required bool dark,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 38,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: dark
              ? AppColors.dark
              : const Color(0xFFF1F1F1),
          foregroundColor: dark
              ? Colors.white
              : AppColors.dark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
  ) {
    return SafeArea(
      top: false,
      child: Container(
        height: 86,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFE7E3DF),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            _buildNavItem(
              icon: Icons.home_outlined,
              label: 'Beranda',
              active: false,
              onTap: () => _goToHome(context),
            ),

            _buildNavItem(
              icon: Icons.receipt_long_outlined,
              label: 'Status & Riwayat',
              active: false,
              onTap: () => _goToStatus(context),
            ),

            _buildNavItem(
              icon: Icons.info_outline,
              label: 'Info Cafe',
              active: true,
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 31,
              color: active
                  ? AppColors.red
                  : const Color(0xFF737373),
            ),

            const SizedBox(height: 5),

            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: active
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: active
                    ? AppColors.red
                    : const Color(0xFF737373),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
