import '../models/admin_product_model.dart';

class AdminProductService {
  static final List<AdminProduct> _products = [
    AdminProduct(
      id: '1',
      name: 'Professional Acoustic Guitar',
      description: 'High-quality acoustic guitar with warm tone',
      price: 299.99,
      originalPrice: 399.99,
      category: 'Guitars',
      image: 'assets/images/guitar1.png',
      stock: 15,
      rating: 4.8,
      reviews: 128,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      tags: ['acoustic', 'beginner-friendly', 'professional'],
      sku: 'GUITAR-001',
    ),
    AdminProduct(
      id: '2',
      name: 'Electric Bass Guitar',
      description: 'Perfect for jazz and funk music',
      price: 349.99,
      category: 'Bass',
      image: 'assets/images/bass1.png',
      stock: 8,
      rating: 4.6,
      reviews: 95,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
      tags: ['electric', 'bass', 'professional'],
      sku: 'BASS-001',
    ),
    AdminProduct(
      id: '3',
      name: 'Digital Synthesizer',
      description: '61-key professional synthesizer',
      price: 599.99,
      category: 'Keyboards',
      image: 'assets/images/synth1.png',
      stock: 5,
      rating: 4.9,
      reviews: 156,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
      tags: ['keyboard', 'digital', 'professional'],
      sku: 'SYNTH-001',
    ),
    AdminProduct(
      id: '4',
      name: 'Studio Microphone',
      description: 'Professional XLR recording microphone',
      price: 199.99,
      category: 'Audio',
      image: 'assets/images/mic1.png',
      stock: 20,
      rating: 4.7,
      reviews: 203,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
      tags: ['audio', 'recording', 'professional'],
      sku: 'MIC-001',
    ),
    AdminProduct(
      id: '5',
      name: 'Drum Set Kit',
      description: 'Complete 5-piece drum kit with cymbals',
      price: 449.99,
      category: 'Drums',
      image: 'assets/images/drums1.png',
      stock: 3,
      rating: 4.5,
      reviews: 87,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
      tags: ['drums', 'complete-kit', 'beginner'],
      sku: 'DRUM-001',
    ),
  ];

  List<AdminProduct> getAllProducts() {
    return _products;
  }

  List<AdminProduct> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  List<AdminProduct> searchProducts(String query) {
    return _products
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.sku.toLowerCase().contains(query.toLowerCase()) ||
            p.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<AdminProduct> getLowStockProducts(int threshold) {
    return _products.where((p) => p.stock <= threshold).toList();
  }

  AdminProduct? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateProduct(AdminProduct product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
  }

  void addProduct(AdminProduct product) {
    _products.add(product);
  }

  List<String> getAllCategories() {
    return _products.map((p) => p.category).toSet().toList();
  }
}
