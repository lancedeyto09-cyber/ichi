import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';

  ProductProvider() {
    _loadProducts();
  }

  void _loadProducts() {
    _products = _productService.getAllProducts();
    _filteredProducts = _products;
  }

  List<Product> get products => _filteredProducts;
  List<Product> get featuredProducts => _productService.getFeaturedProducts();
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  List<String> get categories => ['All', ..._productService.getCategories()];

  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredProducts = _products;

    if (_searchQuery.isNotEmpty) {
      _filteredProducts = _productService.searchProducts(_searchQuery);
    }

    if (_selectedCategory != 'All') {
      _filteredProducts = _filteredProducts
          .where((p) => p.category == _selectedCategory)
          .toList();
    }

    notifyListeners();
  }

  void toggleFavorite(String productId) {
    _productService.toggleFavorite(productId);
    _loadProducts();
    notifyListeners();
  }
}
