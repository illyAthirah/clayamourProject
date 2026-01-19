import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clayamour/pages/product_details_page.dart';
import 'package:clayamour/services/firebase_service.dart';

class CatalogPage extends StatefulWidget {
  final String? initialCategory;

  const CatalogPage({super.key, this.initialCategory});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String _imageFromName(String name) {
    return 'assets/flowers/'
        '${name.toLowerCase().replaceAll(' ', '_')}.png';
  }

  // ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

  final TextEditingController _searchCtrl = TextEditingController();

  late String selectedCategory;

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
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: "Search bouquets...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
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
                            return matchesCategory && matchesSearch;
                          }).toList();

                          if (filtered.isEmpty) {
                            return const Center(
                              child: Text("No products found."),
                            );
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                              return _productCard(p, favIds.contains(p['id']));
                            },
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
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.08 * 255).round()),
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
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    child: Image.asset(
                      _imageFromName(product["name"]),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: const Color(0xFFEED6C4),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 36,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: () => _toggleFavorite(product, isFav),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["name"].toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "From RM${product["price"]}",
                    style: const TextStyle(fontSize: 13, color: textSecondary),
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
