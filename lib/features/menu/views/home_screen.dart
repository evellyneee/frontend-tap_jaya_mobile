import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'detail_official_screen.dart';

import 'package:tap_jaya_mobile/features/recommendations/views/menu_recommendation_screen.dart';

import '../models/official_menu_catalog.dart';
import '../viewmodels/menu_viewmodel.dart';

import 'package:tap_jaya_mobile/core/constants/app_colors.dart';

import 'package:tap_jaya_mobile/features/cart/viewmodels/cart_viewmodel.dart';

import 'package:tap_jaya_mobile/features/menu/widgets/app_logo.dart';

import 'package:tap_jaya_mobile/features/cart/views/cart_screen.dart';

import 'info_cafe_screen.dart';

import 'package:tap_jaya_mobile/features/orders/views/status_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Semua';
  String searchText = '';

  final TextEditingController searchController = TextEditingController();

  final CartViewModel cartViewModel = CartViewModel.instance;

  final MenuViewModel menuViewModel = MenuViewModel();

  final List<String> categories = OfficialMenuCatalog.categories;

  List<Map<String, String>> get products => menuViewModel.products;

  @override
  void initState() {
    super.initState();

    CartViewModel.instance.addListener(_refreshCart);
    menuViewModel.addListener(_refreshMenu);

    menuViewModel.loadProducts();
  }

  void _refreshCart() {
    if (!mounted) return;
    setState(() {});
  }

  void _refreshMenu() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    CartViewModel.instance.removeListener(_refreshCart);
    menuViewModel.removeListener(_refreshMenu);
    menuViewModel.dispose();
    searchController.dispose();
    super.dispose();
  }

  // Route tanpa animasi khusus navigasi bawah.
  Route<void> _noAnimationRoute(Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  void _openStatus() {
    Navigator.push(context, _noAnimationRoute(const StatusScreen()));
  }

  void _openInfoCafe() {
    Navigator.push(context, _noAnimationRoute(const InfoCafeScreen()));
  }

  List<Map<String, String>> get filteredProducts {
    final query = searchText.trim().toLowerCase();

    return products.where((product) {
      final matchesCategory =
          selectedCategory == 'Semua' ||
          product['category'] == selectedCategory;

      final matchesSearch =
          query.isEmpty ||
          (product['name'] ?? '').toLowerCase().contains(query) ||
          (product['description'] ?? '').toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openProductDetail(Map<String, String> product) {
    final menu = OfficialMenuCatalog.byName(product['name'] ?? '');

    if (menu == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailOfficialScreen(menu: menu)),
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
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Column(
                  children: [
                    _buildSearch(),
                    const SizedBox(height: 12),
                    _buildCategories(),
                    _buildRecommendationBanner(),
                    const SizedBox(height: 18),

                    if (menuViewModel.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (menuViewModel.hasError)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              menuViewModel.errorMessage ??
                                  'Gagal mengambil menu',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.red,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                menuViewModel.loadProducts();
                              },
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    else if (filteredProducts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text(
                          'Menu tidak ditemukan',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.grey,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredProducts.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 14);
                        },
                        itemBuilder: (context, index) {
                          return _buildProductCard(filteredProducts[index]);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    final int cartCount = CartViewModel.instance.totalQuantity;

    return Container(
      width: double.infinity,
      color: AppColors.dark,
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.warmWhite,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const AppLogo(width: 38),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, Selamat Datang!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mau pesan apa hari ini?',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                if (cartCount > 0)
                  Positioned(
                    right: -8,
                    top: -9,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$cartCount',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },
        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.dark),
        decoration: InputDecoration(
          hintText: 'Cari menu...',
          hintStyle: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFFADADAD),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color(0xFFE6E3DF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color(0xFFE6E3DF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.dark, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final active = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => selectedCategory = category),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.dark : const Color(0xFFF5EDE5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: active ? Colors.white : AppColors.dark,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecommendationBanner() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Material(
        color: const Color(0xFFF5EDE5),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const MenuRecommendationScreen(),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bingung pilih menu?',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                        ),
                      ),
                      Text(
                        'Rekomendasi sesuai selera dan anggaranmu',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.red),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, String> product) {
    return InkWell(
      onTap: () => _openProductDetail(product),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFDEDAD5), width: 1),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(
                product['image']!,
                width: 92,
                height: 92,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  width: 92,
                  height: 92,
                  child: Icon(Icons.local_cafe_outlined),
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name']!,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product['description']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8F8F8F),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    product['price']!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              active: true,
            ),
            _buildNavItem(
              icon: Icons.receipt_long_outlined,
              label: 'Status & Riwayat',
              active: false,
              onTap: _openStatus,
            ),
            _buildNavItem(
              icon: Icons.info_outline,
              label: 'Info Cafe',
              active: false,
              onTap: _openInfoCafe,
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
