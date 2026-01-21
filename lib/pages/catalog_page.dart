import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clayamour/pages/product_details_page.dart';
import 'package:clayamour/services/firebase_service.dart';
import 'package:clayamour/theme/app_theme.dart';

class CatalogPage extends StatefulWidget {
  final String? initialCategory;

  const CatalogPage({super.key, this.initialCategory});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String _imageFromProduct(Map<String, dynamic> product) {
    final name = product['name'].toString().toLowerCase();
    final category = product['category'];

    final fileName = name
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(' ', '_');

    if (category == 'Flowers') {
      return 'assets/flowers/$fileName.png';
    }

    if (category == 'Characters') {
      return 'assets/characters/$fileName.png';
    }

    if (category == 'Add-Ons') {
      return 'assets/add_ons/$fileName.png';
    }

    // fallback
    return 'assets/flowers/$fileName.png';
  }

  // ClayAmour palette
  static const Color primary = AppColors.primary;
  static const Color background = AppColors.background;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  final TextEditingController _searchCtrl = TextEditingController();

  late String selectedCategory;
  String sortBy = 'name'; // 'name', 'price_low', 'price_high'
  RangeValues priceRange = const RangeValues(0, 500);
  bool showFilters = false;

  final List<String> categories = ["All", "Flowers", "Characters", "Add-Ons"];

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory ?? "All";
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
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
        title: const Text(
          "Catalog",
          style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(
              showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: textPrimary,
            ),
            onPressed: () => setState(() => showFilters = !showFilters),
          ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text("Please sign in to view catalog."))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseService.userSubcollection(
                uid,
                'favorites',
              ).snapshots(),
              builder: (context, favSnap) {
                final favIds =
                    favSnap.data?.docs.map((d) => d.id).toSet() ?? <String>{};
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: "Search bouquets...",
                            prefixIcon: const Icon(
                              Icons.search,
                              color: primary,
                            ),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showFilters) _filterPanel(),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final c = categories[i];
                          final active = selectedCategory == c;

                          return ChoiceChip(
                            label: Text(c),
                            selected: active,
                            selectedColor: primary.withAlpha(
                              (0.18 * 255).round(),
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: active ? primary : textPrimary,
                            ),
                            onSelected: (_) =>
                                setState(() => selectedCategory = c),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseService.products().snapshots(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final products =
                              snap.data?.docs.map((d) {
                                final data = d.data();
                                return {'id': d.id, ...data};
                              }).toList() ??
                              <Map<String, dynamic>>[];

                          final filtered = products.where((p) {
                            final matchesCategory =
                                selectedCategory == "All" ||
                                p["category"] == selectedCategory;
                            final matchesSearch = p["name"]
                                .toString()
                                .toLowerCase()
                                .contains(_searchCtrl.text.toLowerCase());
                            final price = (p['price'] as num?)?.toDouble() ?? 0;
                            final matchesPrice =
                                price >= priceRange.start &&
                                price <= priceRange.end;
                            return matchesCategory &&
                                matchesSearch &&
                                matchesPrice;
                          }).toList();

                          // Sort filtered products
                          if (sortBy == 'price_low') {
                            filtered.sort((a, b) {
                              final priceA =
                                  (a['price'] as num?)?.toDouble() ?? 0;
                              final priceB =
                                  (b['price'] as num?)?.toDouble() ?? 0;
                              return priceA.compareTo(priceB);
                            });
                          } else if (sortBy == 'price_high') {
                            filtered.sort((a, b) {
                              final priceA =
                                  (a['price'] as num?)?.toDouble() ?? 0;
                              final priceB =
                                  (b['price'] as num?)?.toDouble() ?? 0;
                              return priceB.compareTo(priceA);
                            });
                          } else {
                            // Sort by name
                            filtered.sort(
                              (a, b) => (a['name'] ?? '').toString().compareTo(
                                (b['name'] ?? '').toString(),
                              ),
                            );
                          }

                          if (filtered.isEmpty) {
                            return RefreshIndicator(
                              onRefresh: () async {
                                setState(() {});
                                await Future.delayed(
                                  const Duration(milliseconds: 500),
                                );
                              },
                              child: CustomScrollView(
                                slivers: [
                                  SliverFillRemaining(
                                    child: const Center(
                                      child: Text("No products found."),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              setState(() {});
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                            },
                            child: GridView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                16,
                              ),
                              itemCount: filtered.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.78,
                                  ),
                              itemBuilder: (_, i) {
                                final p = filtered[i];
                                return _productCard(
                                  p,
                                  favIds.contains(p['id']),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
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
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: Image.asset(
                      _imageFromProduct(product),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: AppColors.softAccent,
                          child: const Center(
                            child: Icon(
                              Icons.local_florist,
                              size: 48,
                              color: AppColors.accent,
                            ),
                          ),
                        );
                      },
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
                    product["name"].toString(),
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
                      "From RM${product["price"]}",
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

  Widget _filterPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sort, size: 20, color: primary),
              SizedBox(width: 8),
              Text(
                'Sort By',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _sortChip('Name', 'name'),
              _sortChip('Price: Low to High', 'price_low'),
              _sortChip('Price: High to Low', 'price_high'),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Icon(Icons.tune, size: 20, color: primary),
              SizedBox(width: 8),
              Text(
                'Price Range',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'RM${priceRange.start.round()}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
              ),
              Expanded(
                child: RangeSlider(
                  values: priceRange,
                  min: 0,
                  max: 500,
                  divisions: 50,
                  activeColor: primary,
                  onChanged: (values) {
                    setState(() => priceRange = values);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'RM${priceRange.end.round()}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sortChip(String label, String value) {
    final isSelected = sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: primary.withAlpha((0.2 * 255).round()),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected ? primary : textPrimary,
      ),
      onSelected: (_) => setState(() => sortBy = value),
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
