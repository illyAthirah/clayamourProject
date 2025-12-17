class FavouriteProductStore {
  static final List<FavouriteProduct> favourites = [];

  static bool isFavourite(String id) {
    return favourites.any((item) => item.id == id);
  }

  static void toggleFavourite(FavouriteProduct product) {
    if (isFavourite(product.id)) {
      favourites.removeWhere((item) => item.id == product.id);
    } else {
      favourites.add(product);
    }
  }
}

class FavouriteProduct {
  final String id;
  final String name;
  final int price;

  FavouriteProduct({
    required this.id,
    required this.name,
    required this.price,
  });
}
