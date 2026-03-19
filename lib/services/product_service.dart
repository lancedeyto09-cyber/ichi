import '../models/product_model.dart';

class ProductService {
  static final List<Product> _products = [
    Product(
      id: '1',
      name: 'Professional Acoustic Guitar',
      description: 'High-quality acoustic guitar with warm tone',
      price: 299.99,
      category: 'Guitars',
      image: 'assets/images/guitar1.png',
      rating: 4.8,
      reviews: 128,
      isFavorite: false,
      stock: 15,
    ),
    Product(
      id: '2',
      name: 'Electric Bass Guitar',
      description: 'Perfect for jazz and funk music',
      price: 349.99,
      category: 'Bass',
      image: 'assets/images/bass1.png',
      rating: 4.6,
      reviews: 95,
      isFavorite: false,
      stock: 8,
    ),
    Product(
      id: '3',
      name: 'Digital Synthesizer',
      description: '61-key professional synthesizer',
      price: 599.99,
      category: 'Keyboards',
      image: 'assets/images/synth1.png',
      rating: 4.9,
      reviews: 156,
      isFavorite: false,
      stock: 5,
    ),
    Product(
      id: '4',
      name: 'Studio Microphone',
      description: 'Professional XLR recording microphone',
      price: 199.99,
      category: 'Audio',
      image: 'assets/images/mic1.png',
      rating: 4.7,
      reviews: 203,
      isFavorite: false,
      stock: 20,
    ),
    Product(
      id: '5',
      name: 'Drum Set Kit',
      description: 'Complete 5-piece drum kit with cymbals',
      price: 449.99,
      category: 'Drums',
      image: 'assets/images/drums1.png',
      rating: 4.5,
      reviews: 87,
      isFavorite: false,
      stock: 3,
    ),
    Product(
      id: '6',
      name: 'Portable DJ Controller',
      description: 'Compact DJ mixer with USB connectivity',
      price: 279.99,
      category: 'DJ Equipment',
      image: 'assets/images/dj1.png',
      rating: 4.6,
      reviews: 142,
      isFavorite: false,
      stock: 12,
    ),
    Product(
      id: '7',
      name: 'Violin with Case',
      description: 'Beginner-friendly wooden violin',
      price: 189.99,
      category: 'Strings',
      image: 'assets/images/violin1.png',
      rating: 4.3,
      reviews: 64,
      isFavorite: false,
      stock: 10,
    ),
    Product(
      id: '8',
      name: 'Studio Headphones',
      description: 'Professional audio monitoring headphones',
      price: 249.99,
      category: 'Audio',
      image: 'assets/images/headphones1.png',
      rating: 4.8,
      reviews: 189,
      isFavorite: false,
      stock: 25,
    ),
  ];

  // Get all products
  List<Product> getAllProducts() {
    return _products;
  }

  // Get featured products (top 4)
  List<Product> getFeaturedProducts() {
    return _products.take(4).toList();
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  // Search products
  List<Product> searchProducts(String query) {
    return _products
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Toggle favorite
  Product toggleFavorite(String productId) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        isFavorite: !_products[index].isFavorite,
      );
      return _products[index];
    }
    return _products[0];
  }

  // Get categories
  List<String> getCategories() {
    return _products.map((p) => p.category).toSet().toList();
  }
}
