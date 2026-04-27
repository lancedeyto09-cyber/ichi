import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/user_order_provider.dart';
import 'user_order_details_screen.dart';

class UserOrdersScreen extends StatefulWidget {
  const UserOrdersScreen({super.key});

  @override
  State<UserOrdersScreen> createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  String _selectedTab = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<UserOrderProvider>().listenOrders();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.textMedium;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'processing':
        return Icons.sync_rounded;
      case 'shipped':
        return Icons.local_shipping_rounded;
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserOrderProvider>();

    final filteredOrders = _selectedTab == 'all'
        ? provider.orders
        : provider.orders
            .where((o) => o.status.toLowerCase() == _selectedTab)
            .toList();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 10),
              _buildTabs(),
              const SizedBox(height: 10),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.refreshOrders,
                  child: Builder(
                    builder: (context) {
                      if (provider.isLoading && provider.orders.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      }

                      if (provider.error != null && provider.orders.isEmpty) {
                        return ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            const SizedBox(height: 80),
                            _buildMessageCard(
                              icon: Icons.error_outline_rounded,
                              title: 'Unable to load orders',
                              subtitle: provider.error!,
                            ),
                          ],
                        );
                      }

                      if (provider.orders.isEmpty) {
                        return ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            const SizedBox(height: 80),
                            _buildMessageCard(
                              icon: Icons.shopping_bag_outlined,
                              title: 'No orders yet',
                              subtitle: 'Your placed orders will appear here.',
                            ),
                          ],
                        );
                      }

                      if (filteredOrders.isEmpty) {
                        return ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            const SizedBox(height: 80),
                            _buildMessageCard(
                              icon: Icons.filter_alt_off_rounded,
                              title: 'No ${_selectedTab.toUpperCase()} orders',
                              subtitle: 'Try choosing another order status.',
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          final statusColor = _statusColor(order.status);

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      UserOrderDetailsScreen(order: order),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [AppColors.mediumShadow],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            color:
                                                statusColor.withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            _statusIcon(order.status),
                                            color: statusColor,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Order #${order.id}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                order.createdAt
                                                    .toLocal()
                                                    .toString()
                                                    .split('.')
                                                    .first,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textMedium,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                statusColor.withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            order.status.toUpperCase(),
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                          color: AppColors.textLight,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildInfoRow(
                                      'Payment',
                                      order.paymentStatus,
                                    ),
                                    _buildInfoRow(
                                      'Total',
                                      '₱${order.totalAmount.toStringAsFixed(2)}',
                                      isBold: true,
                                    ),
                                    if (order.trackingNumber != null &&
                                        order.trackingNumber!.trim().isNotEmpty)
                                      _buildInfoRow(
                                        'Tracking',
                                        order.trackingNumber!,
                                      ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${order.items.length} item(s)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMedium,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'My Orders',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
              ),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = [
      'all',
      'pending',
      'processing',
      'shipped',
      'delivered',
      'cancelled',
    ];

    return SizedBox(
      height: 42,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isActive = _selectedTab == tab;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedTab = tab);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                tab.toUpperCase(),
                style: TextStyle(
                  color: isActive ? AppColors.primaryDark : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [AppColors.mediumShadow],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 56,
            color: AppColors.primaryDark,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textDark,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
