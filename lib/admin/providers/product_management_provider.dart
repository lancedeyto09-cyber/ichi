import 'package:flutter/material.dart';
import '../models/admin_product_model.dart';
import '../services/admin_product_service.dart';

class ProductManagementProvider extends ChangeNotifier {
  final AdminProductService _productService = AdminProductService();

  List<AdminProduct> _products = [];
  List<AdminProduct> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'name';

  // Getters
  List<AdminProduct> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  List<String> get categories => ['All', ..._productService.getAllCategories()];

  ProductManagementProvider() {
    loadProducts();
  }

  void loadProducts() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = _productService.getAllProducts();
      _applyFiltersAndSort();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFiltersAndSort();
  }

  void sortProducts(String sortBy) {
    _sortBy = sortBy;
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    _filteredProducts = List.from(_products);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredProducts = _productService.searchProducts(_searchQuery);
    }

    // Apply category filter
    if (_selectedCategory != 'All') {
      _filteredProducts = _filteredProducts
          .where((p) => p.category == _selectedCategory)
          .toList();
    }

    // Apply sorting
    _sortBy = _sortBy;
    switch (_sortBy) {
      case 'name':
        _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price':
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'stock':
        _filteredProducts.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case 'rating':
        _filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    notifyListeners();
  }

  void addProduct(AdminProduct product) {
    _productService.addProduct(product);
    loadProducts();
  }

  void updateProduct(AdminProduct product) {
    _productService.updateProduct(product);
    loadProducts();
  }

  void deleteProduct(String productId) {
    _productService.deleteProduct(productId);
    loadProducts();
  }

  AdminProduct? getProductById(String id) {
    return _productService.getProductById(id);
  }

  List<AdminProduct> getLowStockProducts() {
    return _productService.getLowStockProducts(5);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
