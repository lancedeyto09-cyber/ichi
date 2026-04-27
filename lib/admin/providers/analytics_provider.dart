import 'package:flutter/material.dart';
import '../models/dashboard_stats_model.dart';
import '../services/admin_analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AdminAnalyticsService _analyticsService = AdminAnalyticsService();

  DashboardStats? _stats;
  bool _isLoading = false;
  String? _error;
  String _timeRange = '7days';

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get timeRange => _timeRange;

  AnalyticsProvider() {
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stats = await _analyticsService.getDashboardStats();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setTimeRange(String range) async {
    _timeRange = range;
    await loadAnalytics();
  }

  Future<List<DailySales>> getSalesTrend() async {
    int days = 7;
    if (_timeRange == '30days') days = 30;
    if (_timeRange == '90days') days = 90;
    if (_timeRange == '1year') days = 365;

    return await _analyticsService.getSalesTrendData(days);
  }
}
