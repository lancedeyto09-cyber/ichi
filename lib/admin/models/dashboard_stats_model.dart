class DashboardStats {
  final double totalSales;
  final int totalOrders;
  final int totalCustomers;
  final int totalProducts;
  final double averageOrderValue;
  final int lowStockItems;
  final int pendingOrders;
  final List<DailySales> salesTrend;
  final List<CategorySales> topCategories;
  final List<ProductSales> topProducts;

  DashboardStats({
    required this.totalSales,
    required this.totalOrders,
    required this.totalCustomers,
    required this.totalProducts,
    required this.averageOrderValue,
    required this.lowStockItems,
    required this.pendingOrders,
    required this.salesTrend,
    required this.topCategories,
    required this.topProducts,
  });
}

class DailySales {
  final DateTime date;
  final double amount;
  final int orderCount;

  DailySales({
    required this.date,
    required this.amount,
    required this.orderCount,
  });
}

class CategorySales {
  final String categoryName;
  final double amount;
  final int percentage;

  CategorySales({
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });
}

class ProductSales {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;

  ProductSales({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });
}
