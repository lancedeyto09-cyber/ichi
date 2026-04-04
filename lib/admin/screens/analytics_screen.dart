import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../models/dashboard_stats_model.dart';
import '../providers/analytics_provider.dart';
import '../utils/admin_responsive.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, _) {
        final isMobile = AdminResponsive.isMobile(context);
        final stats = provider.stats;
        final trend = provider.getSalesTrend();

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF7F2FF),
                Color(0xFFF3EDFF),
                Color(0xFFEEE6FF),
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: provider.isLoading && stats == null
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : stats == null
                    ? _emptyState()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _header(provider, isMobile),
                          const SizedBox(height: 20),
                          if (isMobile)
                            Column(
                              children: [
                                _statCard(
                                  title: 'Total Sales',
                                  value:
                                      '₱${stats.totalSales.toStringAsFixed(0)}',
                                  subtitle: 'Revenue generated',
                                  icon: Icons.payments_rounded,
                                  color: AppColors.primaryDark,
                                  fullWidth: true,
                                ),
                                const SizedBox(height: 12),
                                _statCard(
                                  title: 'Orders',
                                  value: '${stats.totalOrders}',
                                  subtitle: '${stats.pendingOrders} pending',
                                  icon: Icons.receipt_long_rounded,
                                  color: AppColors.successColor,
                                  fullWidth: true,
                                ),
                                const SizedBox(height: 12),
                                _statCard(
                                  title: 'Customers',
                                  value: '${stats.totalCustomers}',
                                  subtitle: 'Registered buyers',
                                  icon: Icons.group_rounded,
                                  color: AppColors.accentColor,
                                  fullWidth: true,
                                ),
                                const SizedBox(height: 12),
                                _statCard(
                                  title: 'AOV',
                                  value:
                                      '₱${stats.averageOrderValue.toStringAsFixed(0)}',
                                  subtitle: 'Average order value',
                                  icon: Icons.trending_up_rounded,
                                  color: AppColors.warningColor,
                                  fullWidth: true,
                                ),
                              ],
                            )
                          else
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                _statCard(
                                  title: 'Total Sales',
                                  value:
                                      '₱${stats.totalSales.toStringAsFixed(0)}',
                                  subtitle: 'Revenue generated',
                                  icon: Icons.payments_rounded,
                                  color: AppColors.primaryDark,
                                ),
                                _statCard(
                                  title: 'Orders',
                                  value: '${stats.totalOrders}',
                                  subtitle: '${stats.pendingOrders} pending',
                                  icon: Icons.receipt_long_rounded,
                                  color: AppColors.successColor,
                                ),
                                _statCard(
                                  title: 'Customers',
                                  value: '${stats.totalCustomers}',
                                  subtitle: 'Registered buyers',
                                  icon: Icons.group_rounded,
                                  color: AppColors.accentColor,
                                ),
                                _statCard(
                                  title: 'AOV',
                                  value:
                                      '₱${stats.averageOrderValue.toStringAsFixed(0)}',
                                  subtitle: 'Average order value',
                                  icon: Icons.trending_up_rounded,
                                  color: AppColors.warningColor,
                                ),
                              ],
                            ),
                          const SizedBox(height: 22),
                          if (isMobile) ...[
                            _glassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sales Trend',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Performance over the selected period',
                                    style: TextStyle(
                                      color: AppColors.textMedium,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    height: 190,
                                    child: _SalesChart(trend: trend),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _glassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Operational Summary',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _metricRow(
                                    label: 'Products in Catalog',
                                    value: '${stats.totalProducts}',
                                  ),
                                  _metricRow(
                                    label: 'Low Stock Items',
                                    value: '${stats.lowStockItems}',
                                    valueColor: AppColors.warningColor,
                                  ),
                                  _metricRow(
                                    label: 'Pending Orders',
                                    value: '${stats.pendingOrders}',
                                    valueColor: AppColors.errorColor,
                                  ),
                                  _metricRow(
                                    label: 'Top Revenue Source',
                                    value: stats.topCategories.isNotEmpty
                                        ? stats.topCategories.first.categoryName
                                        : '-',
                                    valueColor: AppColors.primaryDark,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _glassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Top Categories',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...stats.topCategories.take(5).map(
                                        (category) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 14),
                                          child: _categoryBar(category),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ] else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _glassCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Sales Trend',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          'Performance over the selected period',
                                          style: TextStyle(
                                            color: AppColors.textMedium,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 22),
                                        SizedBox(
                                          height: 260,
                                          child: _SalesChart(trend: trend),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    children: [
                                      _glassCard(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Operational Summary',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            _metricRow(
                                              label: 'Products in Catalog',
                                              value: '${stats.totalProducts}',
                                            ),
                                            _metricRow(
                                              label: 'Low Stock Items',
                                              value: '${stats.lowStockItems}',
                                              valueColor:
                                                  AppColors.warningColor,
                                            ),
                                            _metricRow(
                                              label: 'Pending Orders',
                                              value: '${stats.pendingOrders}',
                                              valueColor: AppColors.errorColor,
                                            ),
                                            _metricRow(
                                              label: 'Top Revenue Source',
                                              value:
                                                  stats.topCategories.isNotEmpty
                                                      ? stats.topCategories
                                                          .first.categoryName
                                                      : '-',
                                              valueColor: AppColors.primaryDark,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _glassCard(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Top Categories',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            ...stats.topCategories.take(5).map(
                                                  (category) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 14),
                                                    child:
                                                        _categoryBar(category),
                                                  ),
                                                ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 22),
                          if (isMobile) ...[
                            _glassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Top Products',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...stats.topProducts.take(5).map(_productRow),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _glassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Insights',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _insightCard(
                                    icon: Icons.auto_graph_rounded,
                                    color: AppColors.primaryDark,
                                    title: 'Revenue Opportunity',
                                    text:
                                        'High-performing categories can be expanded with bundles or upsell offers.',
                                  ),
                                  const SizedBox(height: 12),
                                  _insightCard(
                                    icon: Icons.inventory_rounded,
                                    color: AppColors.warningColor,
                                    title: 'Inventory Attention',
                                    text:
                                        '${stats.lowStockItems} items are close to depletion and should be reviewed.',
                                  ),
                                  const SizedBox(height: 12),
                                  _insightCard(
                                    icon: Icons.people_alt_rounded,
                                    color: AppColors.successColor,
                                    title: 'Customer Growth',
                                    text:
                                        'Customer base is large enough to support segmented campaigns and loyalty offers.',
                                  ),
                                ],
                              ),
                            ),
                          ] else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _glassCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Top Products',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ...stats.topProducts
                                            .take(5)
                                            .map(_productRow),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _glassCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Insights',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _insightCard(
                                          icon: Icons.auto_graph_rounded,
                                          color: AppColors.primaryDark,
                                          title: 'Revenue Opportunity',
                                          text:
                                              'High-performing categories can be expanded with bundles or upsell offers.',
                                        ),
                                        const SizedBox(height: 12),
                                        _insightCard(
                                          icon: Icons.inventory_rounded,
                                          color: AppColors.warningColor,
                                          title: 'Inventory Attention',
                                          text:
                                              '${stats.lowStockItems} items are close to depletion and should be reviewed.',
                                        ),
                                        const SizedBox(height: 12),
                                        _insightCard(
                                          icon: Icons.people_alt_rounded,
                                          color: AppColors.successColor,
                                          title: 'Customer Growth',
                                          text:
                                              'Customer base is large enough to support segmented campaigns and loyalty offers.',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
          ),
        );
      },
    );
  }

  Widget _header(AnalyticsProvider provider, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track revenue, orders, category performance, and overall store health.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryLight.withOpacity(0.28),
              ),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              value: provider.timeRange,
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(16),
              items: const [
                DropdownMenuItem(value: '7days', child: Text('Last 7 Days')),
                DropdownMenuItem(value: '30days', child: Text('Last 30 Days')),
                DropdownMenuItem(value: '90days', child: Text('Last 90 Days')),
                DropdownMenuItem(value: '1year', child: Text('Last Year')),
              ],
              onChanged: (value) {
                if (value != null) {
                  provider.setTimeRange(value);
                }
              },
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analytics',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Track revenue, orders, category performance, and overall store health.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryLight.withOpacity(0.28),
            ),
          ),
          child: DropdownButton<String>(
            value: provider.timeRange,
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(16),
            items: const [
              DropdownMenuItem(value: '7days', child: Text('Last 7 Days')),
              DropdownMenuItem(value: '30days', child: Text('Last 30 Days')),
              DropdownMenuItem(value: '90days', child: Text('Last 90 Days')),
              DropdownMenuItem(value: '1year', child: Text('Last Year')),
            ],
            onChanged: (value) {
              if (value != null) {
                provider.setTimeRange(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: _glassCard(
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 30),
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: AppColors.textLight,
              ),
              SizedBox(height: 16),
              Text(
                'No analytics available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try reloading after data becomes available.',
                style: TextStyle(color: AppColors.textMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
  }) {
    final card = _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const Spacer(),
              Icon(Icons.insights_rounded, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );

    if (fullWidth) return SizedBox(width: double.infinity, child: card);
    return SizedBox(width: 255, child: card);
  }

  Widget _metricRow({
    required String label,
    required String value,
    Color valueColor = AppColors.textDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryBar(CategorySales category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                category.categoryName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Text(
              '${category.percentage}%',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: (category.percentage / 100).clamp(0.0, 1.0),
            minHeight: 9,
            backgroundColor: AppColors.primaryLight.withOpacity(0.20),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryDark,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '₱${category.amount.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMedium,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _productRow(ProductSales product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight.withOpacity(0.85),
                  AppColors.primaryDark.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.quantitySold} sold',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₱${product.revenue.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightCard({
    required IconData icon,
    required Color color,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  final List<DailySales> trend;

  const _SalesChart({required this.trend});

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) {
      return const Center(
        child: Text(
          'No chart data available',
          style: TextStyle(color: AppColors.textMedium),
        ),
      );
    }

    final maxAmount = trend
        .map((e) => e.amount)
        .fold<double>(0, (prev, next) => math.max(prev, next));

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = constraints.maxHeight - 36;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: trend.map((point) {
            final height =
                maxAmount == 0 ? 0.0 : (point.amount / maxAmount) * chartHeight;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      point.amount.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      height: height.clamp(12, chartHeight),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryMid,
                            AppColors.primaryDark,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withOpacity(0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _shortLabel(point.date),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  static String _shortLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${months[date.month - 1]} ${date.day}';
  }
}
