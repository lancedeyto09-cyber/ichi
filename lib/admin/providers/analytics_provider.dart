import 'package:flutter/material.dart';
import '../models/dashboard_stats_model.dart';
import '../services/admin_analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AdminAnalyticsService _analyticsService = AdminAnalyticsService();

  DashboardStats? _stats;
  bool _isLoading = false;
  String? _error;
  String _timeRange = '7days'; // 7days, 30days, 90days, 1year

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get timeRange => _timeRange;

  void loadAnalytics() {
    _isLoading = true;
    notifyListeners();

    try {
      _stats = _analyticsService.getDashboardStats();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTimeRange(String range) {
    _timeRange = range;
    loadAnalytics();
  }

  List<DailySales> getSalesTrend() {
    int days = 7;
    if (_timeRange == '30days') days = 30;
    if (_timeRange == '90days') days = 90;
    if (_timeRange == '1year') days = 365;

    return _analyticsService.getSalesTrendData(days);
  }
}
