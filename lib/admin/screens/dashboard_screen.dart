import 'dart:ui';

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../utils/admin_responsive.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AdminResponsive.isMobile(context);

    final salesCard = _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Weekly performance snapshot',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: isMobile ? 180 : 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _Bar(day: 'Mon', value: 72),
                _Bar(day: 'Tue', value: 90),
                _Bar(day: 'Wed', value: 64),
                _Bar(day: 'Thu', value: 110),
                _Bar(day: 'Fri', value: 124),
                _Bar(day: 'Sat', value: 98),
                _Bar(day: 'Sun', value: 80),
              ],
            ),
          ),
        ],
      ),
    );

    final quickStatusCard = _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _badge(
            label: '12 Pending Orders',
            color: AppColors.warningColor,
            icon: Icons.schedule_rounded,
          ),
          const SizedBox(height: 12),
          _badge(
            label: '5 Ready to Ship',
            color: AppColors.successColor,
            icon: Icons.local_shipping_rounded,
          ),
          const SizedBox(height: 12),
          _badge(
            label: '3 Payment Issues',
            color: AppColors.errorColor,
            icon: Icons.error_outline_rounded,
          ),
        ],
      ),
    );

    final topCategoryCard = _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Top Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 16),
          _MiniStatRow(label: 'Guitars', value: '42%'),
          _MiniStatRow(label: 'Keyboards', value: '27%'),
          _MiniStatRow(label: 'Audio Gear', value: '18%'),
          _MiniStatRow(label: 'Accessories', value: '13%'),
        ],
      ),
    );

    final recentOrdersCard = _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Recent Orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 16),
          _OrderRow(
            orderId: '#ORD-1024',
            customer: 'Lance D.',
            amount: '₱3,200',
            status: 'Pending',
            statusColor: AppColors.warningColor,
          ),
          _OrderRow(
            orderId: '#ORD-1025',
            customer: 'Maria S.',
            amount: '₱6,850',
            status: 'Paid',
            statusColor: AppColors.successColor,
          ),
          _OrderRow(
            orderId: '#ORD-1026',
            customer: 'John P.',
            amount: '₱1,999',
            status: 'Cancelled',
            statusColor: AppColors.errorColor,
          ),
        ],
      ),
    );

    final lowStockCard = _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Low Stock Alerts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 16),
          _StockRow(
            product: 'Professional Acoustic Guitar',
            stock: '3 left',
          ),
          _StockRow(
            product: 'Digital Synthesizer',
            stock: '5 left',
          ),
          _StockRow(
            product: 'Drum Set Kit',
            stock: '2 left',
          ),
        ],
      ),
    );

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(isMobile),
            const SizedBox(height: 24),
            if (isMobile)
              Column(
                children: const [
                  _KpiCard(
                    title: 'Total Revenue',
                    value: '₱128,400',
                    change: '+12.4%',
                    icon: Icons.payments_rounded,
                    accent: AppColors.primaryDark,
                    fullWidth: true,
                  ),
                  SizedBox(height: 12),
                  _KpiCard(
                    title: 'Orders',
                    value: '248',
                    change: '+8.1%',
                    icon: Icons.receipt_long_rounded,
                    accent: AppColors.successColor,
                    fullWidth: true,
                  ),
                  SizedBox(height: 12),
                  _KpiCard(
                    title: 'Customers',
                    value: '1,024',
                    change: '+5.3%',
                    icon: Icons.group_rounded,
                    accent: AppColors.accentColor,
                    fullWidth: true,
                  ),
                  SizedBox(height: 12),
                  _KpiCard(
                    title: 'Low Stock',
                    value: '7 Items',
                    change: 'Needs action',
                    icon: Icons.warning_amber_rounded,
                    accent: AppColors.warningColor,
                    fullWidth: true,
                  ),
                ],
              )
            else
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: const [
                  _KpiCard(
                    title: 'Total Revenue',
                    value: '₱128,400',
                    change: '+12.4%',
                    icon: Icons.payments_rounded,
                    accent: AppColors.primaryDark,
                  ),
                  _KpiCard(
                    title: 'Orders',
                    value: '248',
                    change: '+8.1%',
                    icon: Icons.receipt_long_rounded,
                    accent: AppColors.successColor,
                  ),
                  _KpiCard(
                    title: 'Customers',
                    value: '1,024',
                    change: '+5.3%',
                    icon: Icons.group_rounded,
                    accent: AppColors.accentColor,
                  ),
                  _KpiCard(
                    title: 'Low Stock',
                    value: '7 Items',
                    change: 'Needs action',
                    icon: Icons.warning_amber_rounded,
                    accent: AppColors.warningColor,
                  ),
                ],
              ),
            const SizedBox(height: 24),
            if (isMobile) ...[
              salesCard,
              const SizedBox(height: 16),
              quickStatusCard,
              const SizedBox(height: 16),
              topCategoryCard,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: salesCard),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        quickStatusCard,
                        const SizedBox(height: 16),
                        topCategoryCard,
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            if (isMobile) ...[
              recentOrdersCard,
              const SizedBox(height: 16),
              lowStockCard,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: recentOrdersCard),
                  const SizedBox(width: 16),
                  Expanded(child: lowStockCard),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _header(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Welcome back! Here’s a quick overview of your store performance.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMedium,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryMid],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_graph_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'This Month',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Welcome back! Here’s a quick overview of your store performance.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMedium,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primaryMid],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_graph_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'This Month',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _badge({
    required String label,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color accent;
  final bool fullWidth;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.accent,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(18),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: accent),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      change,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (fullWidth) return SizedBox(width: double.infinity, child: card);
    return SizedBox(width: 255, child: card);
  }
}

class _Bar extends StatelessWidget {
  final String day;
  final double value;

  const _Bar({
    required this.day,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: value * 1.3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primaryMid],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              day,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatRow extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final String orderId;
  final String customer;
  final String amount;
  final String status;
  final Color statusColor;

  const _OrderRow({
    required this.orderId,
    required this.customer,
    required this.amount,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.68),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customer,
                  style: const TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: statusColor.withOpacity(0.18)),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  final String product;
  final String stock;

  const _StockRow({
    required this.product,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.68),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.warningColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: AppColors.warningColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              product,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            stock,
            style: const TextStyle(
              color: AppColors.errorColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
