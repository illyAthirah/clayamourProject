import 'package:flutter/material.dart';
import 'package:clayamour/logic/favourite_product.dart';
import 'package:clayamour/pages/product_details_page.dart';

class CatalogPage extends StatefulWidget {
  final String? initialCategory;

  const CatalogPage({super.key, this.initialCategory});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  // 🎨 ClayAmour palette
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

  final TextEditingController _searchCtrl = TextEditingController();

  late String selectedCategory;

  final List<String> categories = [
    "All",
    "Flowers",
    "Characters",
    "Add-Ons",
  ];

  // 🔹 Dummy catalog data
  final List<Map<String, dynamic>> products = [
    {
      "id": "rose_bloom",
      "name": "Rose Bloom",
      "price": 89,
      "category": "Flowers",
    },
    {
      "id": "sunflower_smile",
      "name": "Sunflower Smile",
      "price": 79,
      "category": "Flowers",
    },
    {
      "id": "graduate_doll",
      "name": "Graduate Doll",
      "price": 49,
      "category": "Characters",
    },
    {
      "id": "bear_charm",
      "name": "Bear Charm",
      "price": 39,
      "category": "Add-Ons",
    },
  ];

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

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((p) {
      final matchesCategory =
          selectedCategory == "All" || p["category"] == selectedCategory;

      final matchesSearch = p["name"]
          .toString()
          .toLowerCase()
          .contains(_searchCtrl.text.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          // 🔍 Search bar
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
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🏷 Category tabs
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
                  selectedColor: primary.withOpacity(0.18),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: active ? primary : textPrimary,
                  ),
                  onSelected: (_) => setState(() => selectedCategory = c),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // 🛍 Product grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (_, i) {
                final p = filteredProducts[i];
                return _productCard(p);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================
  // Product card
  // ===========================
  Widget _productCard(Map<String, dynamic> product) {
    final id = product["id"];

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
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(22)),
                    ),
                    child: const Center(
                      child: Icon(Icons.local_florist, size: 36),
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
                              id: id,
                              name: product["name"],
                              price: product["price"],
                            ),
                          );
                        });
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          FavouriteProductStore.isFavourite(id)
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["name"],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "From RM${product["price"]}",
                    style:
                        const TextStyle(fontSize: 13, color: textSecondary),
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
