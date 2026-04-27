import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  Set<String> _favoriteIds = {};

  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _error;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _productSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _favoriteSub;
  StreamSubscription<User?>? _authSub;

  ProductProvider() {
    loadProducts();

    _authSub = _auth.authStateChanges().listen((user) {
      _listenFavorites(user);
    });
  }

  List<Product> get products => _filteredProducts;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Product> get featuredProducts {
    final activeProducts = _products;
    if (activeProducts.length <= 4) return activeProducts;
    return activeProducts.take(4).toList();
  }

  List<String> get categories {
    final categorySet = _products.map((p) => p.category).toSet().toList();
    categorySet.sort();
    return ['All', ...categorySet];
  }

  void loadProducts() {
    _isLoading = true;
    notifyListeners();

    _productSub?.cancel();

    _productSub = _firestore.collection('products').snapshots().listen(
      (snapshot) {
        _products = snapshot.docs.map((doc) {
          final product = Product.fromMap(doc.data(), doc.id);

          return product.copyWith(
            isFavorite: _favoriteIds.contains(product.id),
          );
        }).toList();

        _error = null;
        _isLoading = false;
        _applyFilters();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _listenFavorites(User? user) {
    _favoriteSub?.cancel();

    if (user == null) {
      _favoriteIds = {};
      _refreshFavoriteState();
      return;
    }

    _favoriteSub = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .listen(
      (snapshot) {
        _favoriteIds = snapshot.docs.map((doc) => doc.id).toSet();
        _refreshFavoriteState();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void _refreshFavoriteState() {
    _products = _products.map((product) {
      return product.copyWith(
        isFavorite: _favoriteIds.contains(product.id),
      );
    }).toList();

    _applyFilters();
  }

  Future<void> refreshProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore.collection('products').get();

      _products = snapshot.docs.map((doc) {
        final product = Product.fromMap(doc.data(), doc.id);

        return product.copyWith(
          isFavorite: _favoriteIds.contains(product.id),
        );
      }).toList();

      _error = null;
      _isLoading = false;
      _applyFilters();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchProducts(String query) {
    _searchQuery = query.trim();
    _applyFilters();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    List<Product> result = List.from(_products);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();

      result = result.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.tags.join(' ').contains(q);
      }).toList();
    }

    if (_selectedCategory != 'All') {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }

    _filteredProducts = result;
    notifyListeners();
  }

  Future<void> toggleFavorite(String productId) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception('You must be logged in to save products.');
      }

      final favRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(productId);

      if (_favoriteIds.contains(productId)) {
        await favRef.delete();
      } else {
        await favRef.set({
          'productId': productId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _productSub?.cancel();
    _favoriteSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
