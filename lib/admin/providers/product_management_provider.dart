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
  List<String> _categories = ['All'];

  List<AdminProduct> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  List<String> get categories => _categories;

  ProductManagementProvider() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _productService.getAllProducts();
      final fetchedCategories = await _productService.getAllCategories();
      _categories = ['All', ...fetchedCategories];
      _applyFiltersAndSort();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchProducts(String query) {
    _searchQuery = query.trim();
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
    List<AdminProduct> result = List.from(_products);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q);
      }).toList();
    }

    if (_selectedCategory != 'All') {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }

    switch (_sortBy) {
      case 'name':
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'stock':
        result.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case 'rating':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    _filteredProducts = result;
    notifyListeners();
  }

  Future<void> addProduct(AdminProduct product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _productService.addProduct(product);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(AdminProduct product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _productService.updateProduct(product);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _productService.deleteProduct(productId);
      await loadProducts();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  AdminProduct? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<AdminProduct> getLowStockProducts() {
    return _products.where((p) => p.stock <= 5).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
