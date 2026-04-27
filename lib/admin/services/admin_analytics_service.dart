import '../models/dashboard_stats_model.dart';
import 'admin_order_service.dart';
import 'admin_product_service.dart';
import 'admin_user_service.dart';

class AdminAnalyticsService {
  final AdminOrderService orderService = AdminOrderService();
  final AdminProductService productService = AdminProductService();
  final AdminUserService userService = AdminUserService();

  Future<DashboardStats> getDashboardStats() async {
    final orders = await orderService.getAllOrders();
    final products = await productService.getAllProducts();
    final customers = await userService.getAllCustomers();

    double totalSales = 0;
    final int totalOrders = orders.length;
    final int pendingOrders = orders.where((o) => o.status == 'pending').length;

    for (final order in orders) {
      if (order.status != 'cancelled') {
        totalSales += order.totalAmount;
      }
    }

    final int totalProducts = products.length;
    final int lowStockItems = products.where((p) => p.stock <= 5).length;
    final int totalCustomers = customers.length;

    final double averageOrderValue =
        totalOrders == 0 ? 0.0 : totalSales / totalOrders;

    final List<DailySales> salesTrend = _buildSalesTrend(orders);

    final Map<String, double> categoryMap = {};
    final Map<String, int> categoryOrderCount = {};

    for (final order in orders) {
      if (order.status == 'cancelled') continue;

      for (final item in order.items) {
        final product = products.cast<dynamic>().firstWhere(
              (p) => p.id == item.productId,
              orElse: () => null,
            );

        if (product != null) {
          final category = product.category;
          final revenue = item.price * item.quantity;

          categoryMap[category] = (categoryMap[category] ?? 0) + revenue;
          categoryOrderCount[category] =
              (categoryOrderCount[category] ?? 0) + item.quantity;
        }
      }
    }

    final List<CategorySales> topCategories = categoryMap.entries.map((entry) {
      final percentage =
          totalSales > 0 ? ((entry.value / totalSales) * 100).round() : 0;

      return CategorySales(
        categoryName: entry.key,
        amount: entry.value,
        percentage: percentage,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final Map<String, ProductSales> productSalesMap = {};

    for (final order in orders) {
      if (order.status == 'cancelled') continue;

      for (final item in order.items) {
        if (productSalesMap.containsKey(item.productId)) {
          final existing = productSalesMap[item.productId]!;
          productSalesMap[item.productId] = ProductSales(
            productId: existing.productId,
            productName: existing.productName,
            quantitySold: existing.quantitySold + item.quantity,
            revenue: existing.revenue + (item.price * item.quantity),
          );
        } else {
          productSalesMap[item.productId] = ProductSales(
            productId: item.productId,
            productName: item.productName,
            quantitySold: item.quantity,
            revenue: item.price * item.quantity,
          );
        }
      }
    }

    final List<ProductSales> topProducts = productSalesMap.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return DashboardStats(
      totalSales: totalSales,
      totalOrders: totalOrders,
      totalCustomers: totalCustomers,
      totalProducts: totalProducts,
      averageOrderValue: averageOrderValue,
      lowStockItems: lowStockItems,
      pendingOrders: pendingOrders,
      salesTrend: salesTrend,
      topCategories: topCategories.take(5).toList(),
      topProducts: topProducts.take(5).toList(),
    );
  }

  Future<List<DailySales>> getSalesTrendData(int days) async {
    final orders = await orderService.getAllOrders();

    final now = DateTime.now();
    final startDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));

    final List<DailySales> trend = [];

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final nextDate = date.add(const Duration(days: 1));

      final dayOrders = orders.where((o) {
        return !o.createdAt.isBefore(date) && o.createdAt.isBefore(nextDate);
      }).toList();

      final amount = dayOrders
          .where((o) => o.status != 'cancelled')
          .fold<double>(0, (sum, o) => sum + o.totalAmount);

      trend.add(
        DailySales(
          date: date,
          amount: amount,
          orderCount: dayOrders.length,
        ),
      );
    }

    return trend;
  }

  List<DailySales> _buildSalesTrend(List<dynamic> orders) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));

    final List<DailySales> trend = [];

    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      final nextDate = date.add(const Duration(days: 1));

      final dayOrders = orders.where((o) {
        return !o.createdAt.isBefore(date) && o.createdAt.isBefore(nextDate);
      }).toList();

      final amount = dayOrders
          .where((o) => o.status != 'cancelled')
          .fold<double>(0, (sum, o) => sum + o.totalAmount);

      trend.add(
        DailySales(
          date: date,
          amount: amount,
          orderCount: dayOrders.length,
        ),
      );
    }

    return trend;
  }
}
