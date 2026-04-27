import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_order_model.dart';
import '../constants/app_colors.dart';
import '../providers/user_order_provider.dart';

class UserOrderDetailsScreen extends StatelessWidget {
  final UserOrder order;

  Widget _buildOrderTimeline(String status) {
    final steps = [
      {
        'key': 'pending',
        'label': 'Pending',
        'icon': Icons.schedule_rounded,
      },
      {
        'key': 'processing',
        'label': 'Processing',
        'icon': Icons.sync_rounded,
      },
      {
        'key': 'shipped',
        'label': 'Shipped',
        'icon': Icons.local_shipping_rounded,
      },
      {
        'key': 'delivered',
        'label': 'Delivered',
        'icon': Icons.check_circle_rounded,
      },
    ];

    final normalized = status.toLowerCase();

    if (normalized == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.25)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: Colors.red),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'This order has been cancelled.',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final rawIndex = steps.indexWhere((step) => step['key'] == normalized);
    final currentIndex = rawIndex == -1 ? 0 : rawIndex;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryDark.withOpacity(0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Tracking',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isActive = index <= currentIndex;
            final isCurrent = index == currentIndex;
            final isLast = index == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isCurrent ? 34 : 30,
                      height: isCurrent ? 34 : 30,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryDark
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 3,
                        height: 38,
                        color: isActive
                            ? AppColors.primaryDark
                            : Colors.grey.shade300,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['label'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isActive
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isCurrent
                              ? 'Current status'
                              : isActive
                                  ? 'Completed'
                                  : 'Waiting',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isCurrent
                                ? AppColors.primaryDark
                                : AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  const UserOrderDetailsScreen({
    super.key,
    required this.order,
  });

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

  bool get _canCancel {
    final s = order.status.toLowerCase();
    return s == 'pending' || s == 'processing';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    final provider = context.watch<UserOrderProvider>();

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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [AppColors.mediumShadow],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(14),
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
                                        style: const TextStyle(
                                          fontSize: 16,
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
                                    color: statusColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
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
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildOrderTimeline(order.status),
                            const SizedBox(height: 14),
                            _infoRow('Customer', order.customerName),
                            _infoRow('Email', order.customerEmail),
                            _infoRow('Payment', order.paymentStatus),
                            _infoRow(
                              'Total',
                              '₱${order.totalAmount.toStringAsFixed(2)}',
                              bold: true,
                            ),
                            if (order.trackingNumber != null &&
                                order.trackingNumber!.trim().isNotEmpty)
                              _infoRow('Tracking', order.trackingNumber!),
                            if (_canCancel) ...[
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: provider.isCancelling
                                      ? null
                                      : () async {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                  'Cancel order?',
                                                ),
                                                content: const Text(
                                                  'This will cancel your order and restore the product stock.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                                    child: const Text('No'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                    child: const Text('Yes'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirm != true) return;

                                          try {
                                            await context
                                                .read<UserOrderProvider>()
                                                .cancelOrder(order);

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Order cancelled successfully.',
                                                  ),
                                                  backgroundColor:
                                                      AppColors.successColor,
                                                ),
                                              );
                                              Navigator.pop(context);
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(e.toString()),
                                                  backgroundColor:
                                                      AppColors.errorColor,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.errorColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: provider.isCancelling
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.close_rounded),
                                  label: Text(
                                    provider.isCancelling
                                        ? 'Cancelling...'
                                        : 'Cancel Order',
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [AppColors.mediumShadow],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Items',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ...order.items.map(
                              (item) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.bgLight,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryDark
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.music_note_rounded,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.productName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Qty: ${item.quantity}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '₱${item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [AppColors.mediumShadow],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _infoRow(
                              'Subtotal',
                              '₱${order.totalAmount.toStringAsFixed(2)}',
                            ),
                            _infoRow('Shipping', 'Included'),
                            _infoRow(
                              'Grand Total',
                              '₱${order.totalAmount.toStringAsFixed(2)}',
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                    ],
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
              'Order Details',
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

  Widget _infoRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
