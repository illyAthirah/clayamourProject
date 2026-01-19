import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:clayamour/pages/product_details_page.dart';
import 'package:clayamour/services/firebase_service.dart';

class FavouritePage extends StatelessWidget {
  const FavouritePage({super.key});

  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseService.uid;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          "Favourites",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ),
      body: uid == null
          ? const Center(child: Text("Please sign in to view favourites."))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseService.userSubcollection(uid, 'favorites').snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snap.data?.docs ?? [];
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      "No favourites yet",
                      style: TextStyle(color: textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final doc = items[index];
                    final data = doc.data();
                    final product = {
                      'id': doc.id,
                      ...data,
                    };
                    return _favCard(context, product);
                  },
                );
              },
            ),
    );
  }

  Widget _favCard(BuildContext context, Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: primary.withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.local_florist, color: primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: InkWell(
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
                  Text(
                    product['name']?.toString() ?? 'Product',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "From RM${product['price'] ?? 0}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () => _removeFavourite(product),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFavourite(Map<String, dynamic> product) async {
    final uid = FirebaseService.uid;
    if (uid == null) return;
    await FirebaseService.userSubcollection(uid, 'favorites')
        .doc(product['id'].toString())
        .delete();
  }
}

