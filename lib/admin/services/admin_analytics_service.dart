import '../models/dashboard_stats_model.dart';
import 'admin_order_service.dart';
import 'admin_product_service.dart';

class AdminAnalyticsService {
  final AdminOrderService orderService = AdminOrderService();
  final AdminProductService productService = AdminProductService();

  DashboardStats getDashboardStats() {
    final orders = orderService.getAllOrders();
    final products = productService.getAllProducts();

    double totalSales = 0;
    int totalOrders = orders.length;
    int pendingOrders = orders.where((o) => o.status == 'pending').length;

    for (var order in orders) {
      if (order.status != 'cancelled') {
        totalSales += order.totalAmount;
      }
    }

    int totalProducts = products.length;
    int lowStockItems = products.where((p) => p.stock <= 5).length;

    // Generate sales trend for last 7 days
    List<DailySales> salesTrend = [];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      // Simulated data
      salesTrend.add(DailySales(
        date: date,
        amount: 1000 + (i * 200).toDouble(),
        orderCount: 5 + i,
      ));
    }

    // Top categories
    final Map<String, double> categoryMap = {};
    for (var product in products) {
      categoryMap[product.category] =
          (categoryMap[product.category] ?? 0) + (product.price * 2);
    }

    List<CategorySales> topCategories = [];
    categoryMap.forEach((key, value) {
      topCategories.add(CategorySales(
        categoryName: key,
        amount: value,
        percentage: ((value / totalSales) * 100).toInt(),
      ));
    });

    // Top products
    List<ProductSales> topProducts = products
        .map((p) => ProductSales(
              productId: p.id,
              productName: p.name,
              quantitySold: (100 - p.stock),
              revenue: p.price * (100 - p.stock),
            ))
        .toList();
    topProducts.sort((a, b) => b.revenue.compareTo(a.revenue));
    topProducts = topProducts.take(5).toList();

    return DashboardStats(
      totalSales: totalSales,
      totalOrders: totalOrders,
      totalCustomers: 1245,
      totalProducts: totalProducts,
      averageOrderValue: totalSales / totalOrders,
      lowStockItems: lowStockItems,
      pendingOrders: pendingOrders,
      salesTrend: salesTrend,
      topCategories: topCategories,
      topProducts: topProducts,
    );
  }

  List<DailySales> getSalesTrendData(int days) {
    List<DailySales> trend = [];
    for (int i = days - 1; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      trend.add(DailySales(
        date: date,
        amount: 1000 + (i * 150).toDouble(),
        orderCount: 10 + (i * 2),
      ));
    }
    return trend;
  }
}
