import 'package:flutter/material.dart';
import 'package:clayamour/pages/product_details_page.dart';
import 'package:clayamour/pages/customize_bouquet_page.dart';
import 'package:clayamour/pages/catalog_page.dart';
import 'package:clayamour/pages/cart_page.dart';
import 'package:clayamour/logic/favourite_product.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // 🎨 ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color accent = Color(0xFFC97C5D);
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          "ClayAmour",
          style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            color: textPrimary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: _fade,
              child: SlideTransition(position: _slideUp, child: _heroSection()),
            ),

            const SizedBox(height: 26),

            FadeTransition(
              opacity: _fade,
              child: SlideTransition(position: _slideUp, child: _primaryCTA()),
            ),

            const SizedBox(height: 36),

            // 🔹 Browse section
            _sectionHeader(
              title: "Browse our designs",
              action: "View all",
              onActionTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CatalogPage()),
                );
              },
            ),

            const SizedBox(height: 14),

            _categories(),

            const SizedBox(height: 28),

            // 🔹 Featured section
            const Text(
              "Featured Bouquets",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            FadeTransition(opacity: _fade, child: _featuredGrid()),
          ],
        ),
      ),
    );
  }

  // ===========================
  // Hero
  // ===========================
  Widget _heroSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Design a bouquet\nas unique as them",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.2,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Text(
          "Handcrafted clay bouquets, made with care and meaning.",
          style: TextStyle(fontSize: 15, color: textSecondary),
        ),
      ],
    );
  }

  // ===========================
  // CTA
  // ===========================
  Widget _primaryCTA() {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomizeBouquetPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, accent],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white, size: 32),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Start Custom Bouquet",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Choose flowers, characters & theme",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  // ===========================
  // Section Header
  // ===========================
  Widget _sectionHeader({
    required String title,
    required String action,
    required VoidCallback onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        TextButton(onPressed: onActionTap, child: const Text("View all")),
      ],
    );
  }

  // ===========================
  // Categories
  // ===========================
  Widget _categories() {
    return Row(
      children: [
        _categoryChip(Icons.local_florist, "Flowers"),
        _categoryChip(Icons.emoji_emotions, "Characters"),
        _categoryChip(Icons.add_circle_outline, "Add-Ons"),
      ],
    );
  }

  Widget _categoryChip(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CatalogPage(initialCategory: label),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================
  // Featured Products
  // ===========================
  Widget _featuredGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (_, __) => _productCard(),
    );
  }

  Widget _productCard() {
    const productId = "rose_bloom";

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductDetailsPage()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFEED6C4),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.local_florist, size: 38),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          FavouriteProductStore.toggleFavourite(
                            FavouriteProduct(
                              id: productId,
                              name: "Rose Bloom",
                              price: 89,
                            ),
                          );
                        });
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          FavouriteProductStore.isFavourite(productId)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rose Bloom",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "From RM89",
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
