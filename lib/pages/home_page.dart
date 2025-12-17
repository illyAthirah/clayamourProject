import 'package:clayamour/pages/product_details_page.dart';
import 'package:clayamour/pages/customize_bouquet_page.dart';
import 'package:clayamour/pages/favourite_product.dart';

import 'package:flutter/material.dart';

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
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
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
        elevation: 0,
        backgroundColor: background,
        title: const Text(
          'ClayAmour',
          style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            color: textPrimary,
            onPressed: () {},
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
              child: SlideTransition(position: _slideUp, child: _heroText()),
            ),
            const SizedBox(height: 28),
            FadeTransition(
              opacity: _fade,
              child: SlideTransition(position: _slideUp, child: _primaryCTA()),
            ),
            const SizedBox(height: 36),
            _browseText(),
            const SizedBox(height: 14),
            _categories(),
            const SizedBox(height: 36),
            FadeTransition(opacity: _fade, child: _curatedGrid()),
          ],
        ),
      ),
    );
  }

  // 🖋 Hero text
  Widget _heroText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Design a bouquet\nas unique as them",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.2,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Text(
          "Handcrafted clay bouquets, made to order with care and meaning.",
          style: TextStyle(fontSize: 15, color: textSecondary),
        ),
      ],
    );
  }

  // ✨ Primary CTA
  Widget _primaryCTA() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CustomizeBouquetPage()),
          );
        },
        borderRadius: BorderRadius.circular(24),
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
          child: Row(
            children: const [
              Icon(Icons.auto_awesome, color: Colors.white, size: 34),
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Choose flowers, characters & colors",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // 🧠 Micro-copy
  Widget _browseText() {
    return const Text(
      "Or browse our designs",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    );
  }

  // 📂 Categories
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          // later: filter by category
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🛍 Curated grid
  Widget _curatedGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (_, __) => _productCard(),
    );
  }

  Widget _productCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductDetailsPage()),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
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
              // 🔝 Image + Favourite
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
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

                    // ❤️ Favourite button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 3,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            setState(() {
                              FavouriteProductStore.toggleFavourite(
                                FavouriteProduct(
                                  id: "rose_bloom",
                                  name: "Rose Bloom",
                                  price: 89,
                                ),
                              );
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              FavouriteProductStore.isFavourite("rose_bloom")
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 18,
                              color: const Color(0xFFE57373),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 📄 Product info
              const Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rose Bloom",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),

                    // ⭐ Rating
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                        SizedBox(width: 4),
                        Text(
                          "4.8",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: textPrimary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          "(126)",
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),

                    SizedBox(height: 6),
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
      ),
    );
  }
}
