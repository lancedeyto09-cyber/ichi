import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_order_model.dart';
import '../services/user_order_service.dart';

class UserOrderProvider extends ChangeNotifier {
  final UserOrderService _service = UserOrderService();

  List<UserOrder> _orders = [];
  bool _isLoading = false;
  bool _initialized = false;
  String? _error;
  bool _isCancelling = false;

  StreamSubscription<List<UserOrder>>? _subscription;

  List<UserOrder> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get initialized => _initialized;
  String? get error => _error;
  bool get isCancelling => _isCancelling;

  void listenOrders() {
    if (_initialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.getUserOrders().listen(
      (data) {
        _orders = data;
        _isLoading = false;
        _initialized = true;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        _initialized = true;
        notifyListeners();
      },
    );
  }

  Future<void> refreshOrders() async {
    _subscription?.cancel();
    _initialized = false;
    listenOrders();
  }

  Future<void> cancelOrder(UserOrder order) async {
    try {
      _isCancelling = true;
      _error = null;
      notifyListeners();

      await _service.cancelOrder(order);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isCancelling = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
