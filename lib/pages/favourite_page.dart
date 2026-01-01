import 'package:flutter/material.dart';
import 'package:clayamour/logic/favourite_product.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  static const Color primary = Color(0xFFE8A0BF);
  static const Color background = Color(0xFFFAF7F5);
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6F6F6F);

  @override
  Widget build(BuildContext context) {
    final favourites = FavouriteProductStore.favourites;

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
      body: favourites.isEmpty
          ? const Center(
              child: Text(
                "No favourites yet",
                style: TextStyle(color: textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favourites.length,
              itemBuilder: (_, index) {
                final item = favourites[index];
                return _favCard(item);
              },
            ),
    );
  }

  Widget _favCard(FavouriteProduct item) {
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
              color: primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.local_florist, color: primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "From RM${item.price}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () {
              setState(() {
                FavouriteProductStore.toggleFavourite(item);
              });
            },
          ),
        ],
      ),
    );
  }
}
