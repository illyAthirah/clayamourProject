import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clayamour/pages/product_details_page.dart';
import 'package:clayamour/pages/customize_bouquet_page.dart';
import 'package:clayamour/pages/catalog_page.dart';
import 'package:clayamour/pages/cart_page.dart';
import 'package:clayamour/services/firebase_service.dart';
import 'package:clayamour/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // ClayAmour palette
  static const Color primary = AppColors.primary;
  static const Color background = AppColors.background;
  static const Color accent = AppColors.accent;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

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
    final uid = FirebaseService.uid;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Image.asset(
          'assets/logo.png',
          height: 40,
          fit: BoxFit.contain,
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
      body: uid == null
          ? const Center(child: Text("Please sign in to continue."))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseService.userSubcollection(
                uid,
                'favorites',
              ).snapshots(),
              builder: (context, favSnap) {
                final favIds =
                    favSnap.data?.docs.map((d) => d.id).toSet() ?? <String>{};
                return RefreshIndicator(
                  onRefresh: () async {
                    // Trigger refresh by forcing stream rebuild
                    setState(() {});
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeTransition(
                          opacity: _fade,
                          child: SlideTransition(
                            position: _slideUp,
                            child: _heroSection(),
                          ),
                        ),
                        const SizedBox(height: 26),
                        FadeTransition(
                          opacity: _fade,
                          child: SlideTransition(
                            position: _slideUp,
                            child: _primaryCTA(),
                          ),
                        ),
                        const SizedBox(height: 36),
                        _sectionHeader(
                          title: "Browse our designs",
                          action: "View all",
                          onActionTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CatalogPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _categories(),
                        const SizedBox(height: 28),
                        const Text(
                          "Featured Bouquets",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeTransition(
                          opacity: _fade,
                          child: _featuredGrid(favIds),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

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

  Widget _primaryCTA() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, accent],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomizeBouquetPage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            child: const Row(
              children: [
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
                          fontSize: 17,
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
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
        TextButton(onPressed: onActionTap, child: Text(action)),
      ],
    );
  }

  Widget _categories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _categoryChip(Icons.local_florist, "Flowers"),
          _categoryChip(Icons.emoji_emotions, "Characters"),
          _categoryChip(Icons.add_circle_outline, "Add-Ons"),
        ],
      ),
    );
  }

  Widget _categoryChip(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _featuredGrid(Set<String> favIds) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseService.products().snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final products =
            snap.data?.docs.map((d) {
              final data = d.data();
              return {'id': d.id, ...data};
            }).toList() ??
            <Map<String, dynamic>>[];

        final featured = products.where((p) => p['featured'] == true).toList();
        final visible = featured.isNotEmpty
            ? featured
            : products.take(4).toList();

        if (visible.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text("No featured products yet."),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visible.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (_, i) =>
              _productCard(visible[i], favIds.contains(visible[i]['id'])),
        );
      },
    );
  }

  Widget _productCard(Map<String, dynamic> product, bool isFav) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsPage(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.softAccent,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_florist,
                        size: 48,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Material(
                      elevation: 3,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _toggleFavorite(product, isFav),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 18,
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isFav ? Colors.red : textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'].toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "From RM${product['price']}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
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

  Future<void> _toggleFavorite(Map<String, dynamic> product, bool isFav) async {
    final uid = FirebaseService.uid;
    if (uid == null) return;
    final ref = FirebaseService.userSubcollection(
      uid,
      'favorites',
    ).doc(product['id'].toString());
    if (isFav) {
      await ref.delete();
    } else {
      await ref.set({
        'name': product['name'],
        'price': product['price'],
        'category': product['category'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
