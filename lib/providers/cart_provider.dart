import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void addToCart(Product product, {int quantity = 1}) {
    if (product.stock <= 0) return;

    final safeQuantity = quantity <= 0 ? 1 : quantity;

    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      final currentQty = _items[existingIndex].quantity;
      final newQty = currentQty + safeQuantity;

      _items[existingIndex].quantity =
          newQty > product.stock ? product.stock : newQty;
    } else {
      final initialQty =
          safeQuantity > product.stock ? product.stock : safeQuantity;

      _items.add(
        CartItem(
          product: product,
          quantity: initialQty,
        ),
      );
    }

    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      final maxStock = _items[index].product.stock;

      if (quantity <= 0) {
        removeFromCart(productId);
      } else {
        _items[index].quantity = quantity > maxStock ? maxStock : quantity;
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
