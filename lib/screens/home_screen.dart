import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../widgets/app_logo.dart';
import 'detail_product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Semua';
  String searchText = '';

  // Keranjang awal kosong
  int cartCount = 0;

  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    'Semua',
    'Kopi',
    'Non Kopi',
    'Makanan',
  ];

  final List<Map<String, String>> products = [
    {
      'name': 'Bakmie Jaya',
      'description': 'Mie kenyal dengan topping ayam gurih',
      'price': 'Rp 28.182',
      'category': 'Makanan',
      'image': 'assets/images/bakmie_jaya.png',
    },
    {
      'name': 'Kopi Susu Berjaya di Bali',
      'description': 'Perpaduan espresso dan susu creamy',
      'price': 'Mulai Rp 24.545',
      'category': 'Kopi',
      'image': 'assets/images/kopi_susu_bali.png',
    },
    {
      'name': 'Milkshake Sweet Mango',
      'description': 'Perpaduan susu mangga segar',
      'price': 'Rp 24.545',
      'category': 'Non Kopi',
      'image': 'assets/images/milkshake_sweet_mango.png',
    },
    {
      'name': 'Cireng',
      'description': 'Aci digoreng garing dengan cocolan sambal',
      'price': 'Rp 15.455',
      'category': 'Makanan',
      'image': 'assets/images/cireng.png',
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get filteredProducts {
    return products.where((product) {
      final matchesCategory =
          selectedCategory == 'Semua' ||
          product['category'] == selectedCategory;

      final query = searchText.toLowerCase();

      final matchesSearch =
          product['name']!.toLowerCase().contains(query) ||
          product['description']!.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void addToCartFromDetail(int quantity) {
    setState(() {
      cartCount += quantity;
    });
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
                padding: const EdgeInsets.fromLTRB(
                  18,
                  14,
                  18,
                  18,
                ),
                child: Column(
                  children: [
                    _buildSearch(),

                    const SizedBox(height: 12),

                    _buildCategories(),

                    const SizedBox(height: 18),

                    if (filteredProducts.isEmpty)
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
                          return _buildProductCard(
                            filteredProducts[index],
                          );
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
    return Container(
      width: double.infinity,
      color: AppColors.dark,
      padding: const EdgeInsets.fromLTRB(
        18,
        15,
        18,
        15,
      ),
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
            child: const AppLogo(
              width: 38,
            ),
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

          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 28,
              ),

              // Badge hanya muncul kalau keranjang ada isinya
              if (cartCount > 0)
                Positioned(
                  right: -8,
                  top: -9,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
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
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.dark,
        ),
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
            borderSide: const BorderSide(
              color: Color(0xFFE6E3DF),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(
              color: Color(0xFFE6E3DF),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(
              color: AppColors.dark,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((category) {
        final bool active = selectedCategory == category;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCategory = category;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.dark
                  : const Color(0xFFF5EDE5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: active
                    ? Colors.white
                    : AppColors.dark,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductCard(
    Map<String, String> product,
  ) {
    return InkWell(
      onTap: () {
        if (product['name'] == 'Kopi Susu Berjaya di Bali') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailProductScreen(
                onAddToCart: addToCartFromDetail,
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFDEDAD5),
            width: 1,
          ),
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
              active: true,
            ),
            _buildNavItem(
              icon: Icons.receipt_long_outlined,
              label: 'Status & Riwayat',
              active: false,
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
  }) {
    return Expanded(
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
    );
  }
}