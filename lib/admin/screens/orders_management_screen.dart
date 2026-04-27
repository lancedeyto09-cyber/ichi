import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../models/order_analytics_model.dart';
import '../providers/order_management_provider.dart';
import '../utils/admin_responsive.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderManagementProvider>().loadOrders();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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

  bool _isCancelled(AdminOrder order) =>
      order.status.toLowerCase() == 'cancelled';

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderManagementProvider>(
      builder: (context, provider, _) {
        final isMobile = AdminResponsive.isMobile(context);
        final orders = provider.orders;
        final totalOrders = orders.length;
        final pendingOrders =
            orders.where((o) => o.status.toLowerCase() == 'pending').length;
        final processingOrders =
            orders.where((o) => o.status.toLowerCase() == 'processing').length;
        final cancelledOrders =
            orders.where((o) => o.status.toLowerCase() == 'cancelled').length;

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
                const SizedBox(height: 20),
                if (isMobile)
                  Column(
                    children: [
                      _statCard(
                        title: 'Total Orders',
                        value: '$totalOrders',
                        subtitle: 'All visible orders',
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.primaryDark,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        title: 'Pending',
                        value: '$pendingOrders',
                        subtitle: 'Awaiting action',
                        icon: Icons.schedule_rounded,
                        color: Colors.orange,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        title: 'Processing',
                        value: '$processingOrders',
                        subtitle: 'Being handled',
                        icon: Icons.sync_rounded,
                        color: Colors.blue,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        title: 'Cancelled',
                        value: '$cancelledOrders',
                        subtitle: 'Stopped orders',
                        icon: Icons.cancel_rounded,
                        color: Colors.red,
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
                        title: 'Total Orders',
                        value: '$totalOrders',
                        subtitle: 'All visible orders',
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.primaryDark,
                      ),
                      _statCard(
                        title: 'Pending',
                        value: '$pendingOrders',
                        subtitle: 'Awaiting action',
                        icon: Icons.schedule_rounded,
                        color: Colors.orange,
                      ),
                      _statCard(
                        title: 'Processing',
                        value: '$processingOrders',
                        subtitle: 'Being handled',
                        icon: Icons.sync_rounded,
                        color: Colors.blue,
                      ),
                      _statCard(
                        title: 'Cancelled',
                        value: '$cancelledOrders',
                        subtitle: 'Stopped orders',
                        icon: Icons.cancel_rounded,
                        color: Colors.red,
                      ),
                    ],
                  ),
                const SizedBox(height: 22),
                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isMobile) ...[
                        TextField(
                          controller: _searchCtrl,
                          onChanged: provider.searchOrders,
                          decoration: _inputDecoration(
                            hint: 'Search by order ID, name, email...',
                            prefixIcon: const Icon(Icons.search_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: _dropdownShell(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedFilter,
                              underline: const SizedBox(),
                              borderRadius: BorderRadius.circular(16),
                              icon:
                                  const Icon(Icons.keyboard_arrow_down_rounded),
                              items: provider.statuses
                                  .map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status == 'All'
                                          ? 'All Orders'
                                          : status[0].toUpperCase() +
                                              status.substring(1)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedFilter = value);
                                  provider.filterByStatus(value);
                                }
                              },
                            ),
                          ),
                        ),
                      ] else ...[
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SizedBox(
                              width: 340,
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: provider.searchOrders,
                                decoration: _inputDecoration(
                                  hint: 'Search by order ID, name, email...',
                                  prefixIcon: const Icon(Icons.search_rounded),
                                ),
                              ),
                            ),
                            _dropdownShell(
                              child: DropdownButton<String>(
                                value: _selectedFilter,
                                underline: const SizedBox(),
                                borderRadius: BorderRadius.circular(16),
                                icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded),
                                items: provider.statuses
                                    .map(
                                      (status) => DropdownMenuItem(
                                        value: status,
                                        child: Text(status == 'All'
                                            ? 'All Orders'
                                            : status[0].toUpperCase() +
                                                status.substring(1)),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedFilter = value);
                                    provider.filterByStatus(value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                if (provider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (orders.isEmpty)
                  _glassCard(
                    child: const SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 42),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 58,
                              color: AppColors.textLight,
                            ),
                            SizedBox(height: 14),
                            Text(
                              'No orders found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Try changing the search or filter.',
                              style: TextStyle(color: AppColors.textMedium),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: orders
                        .map(
                          (order) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _orderCard(
                              order: order,
                              isMobile: isMobile,
                              onView: () => _showOrderDetails(context, order),
                              onUpdateStatus: _isCancelled(order)
                                  ? null
                                  : () =>
                                      _showUpdateStatusDialog(context, order),
                              onUpdateTracking: _isCancelled(order)
                                  ? null
                                  : () => _showTrackingDialog(context, order),
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Orders',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Review orders, monitor their status, and handle fulfilment updates.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textMedium,
            ),
          ),
        ],
      );
    }

    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Orders',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Review orders, monitor their status, and handle fulfilment updates.',
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _orderCard({
    required AdminOrder order,
    required bool isMobile,
    required VoidCallback onView,
    required VoidCallback? onUpdateStatus,
    required VoidCallback? onUpdateTracking,
  }) {
    final statusColor = _statusColor(order.status);
    final cancelled = _isCancelled(order);

    return _glassCard(
      padding: EdgeInsets.all(isMobile ? 16 : 18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_statusIcon(order.status), color: statusColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.customerEmail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMobile) ...[
                _smallBadge(
                  label: order.status.toUpperCase(),
                  color: statusColor,
                ),
              ],
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _smallBadge(
                    label: order.status.toUpperCase(),
                    color: statusColor,
                  ),
                  if (cancelled)
                    _smallBadge(
                      label: 'Cancelled by customer',
                      color: Colors.red,
                    ),
                ],
              ),
            ),
          ] else if (cancelled) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: _smallBadge(
                label: 'Cancelled by customer',
                color: Colors.red,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (isMobile) ...[
            Row(
              children: [
                Expanded(
                  child: _miniInfo(
                    title: 'Total',
                    value: '₱${order.totalAmount.toStringAsFixed(2)}',
                    valueColor: AppColors.primaryDark,
                  ),
                ),
                Expanded(
                  child: _miniInfo(
                    title: 'Payment',
                    value: order.paymentStatus,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _miniInfo(
                    title: 'Items',
                    value: '${order.items.length}',
                  ),
                ),
                Expanded(
                  child: _miniInfo(
                    title: 'Tracking',
                    value: (order.trackingNumber == null ||
                            order.trackingNumber!.trim().isEmpty)
                        ? 'Not set'
                        : order.trackingNumber!,
                  ),
                ),
              ],
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _miniInfo(
                    title: 'Total',
                    value: '₱${order.totalAmount.toStringAsFixed(2)}',
                    valueColor: AppColors.primaryDark,
                  ),
                ),
                Expanded(
                  child: _miniInfo(
                    title: 'Payment',
                    value: order.paymentStatus,
                  ),
                ),
                Expanded(
                  child: _miniInfo(
                    title: 'Items',
                    value: '${order.items.length}',
                  ),
                ),
                Expanded(
                  child: _miniInfo(
                    title: 'Tracking',
                    value: (order.trackingNumber == null ||
                            order.trackingNumber!.trim().isEmpty)
                        ? 'Not set'
                        : order.trackingNumber!,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Placed: ${_formatDate(order.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: onView,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    side: BorderSide(
                      color: AppColors.primaryDark.withOpacity(0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: const Text(
                    'View Details',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: onUpdateStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: onUpdateStatus == null
                        ? AppColors.textLight
                        : AppColors.warningColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: Text(
                    onUpdateStatus == null ? 'Status Locked' : 'Update Status',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: onUpdateTracking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: onUpdateTracking == null
                        ? AppColors.textLight
                        : AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.local_shipping_rounded, size: 18),
                  label: Text(
                    onUpdateTracking == null
                        ? 'Tracking Locked'
                        : 'Update Tracking',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onView,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      side: BorderSide(
                        color: AppColors.primaryDark.withOpacity(0.25),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.visibility_rounded, size: 18),
                    label: const Text(
                      'View Details',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onUpdateStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: onUpdateStatus == null
                          ? AppColors.textLight
                          : AppColors.warningColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: Text(
                      onUpdateStatus == null
                          ? 'Status Locked'
                          : 'Update Status',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onUpdateTracking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: onUpdateTracking == null
                          ? AppColors.textLight
                          : AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.local_shipping_rounded, size: 18),
                    label: Text(
                      onUpdateTracking == null
                          ? 'Tracking Locked'
                          : 'Update Tracking',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _showUpdateStatusDialog(
    BuildContext context,
    AdminOrder order,
  ) async {
    final provider = context.read<OrderManagementProvider>();
    String selectedStatus = order.status;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update Status - ${order.id}'),
        content: DropdownButtonFormField<String>(
          value: selectedStatus,
          items: provider.statuses
              .where((e) => e != 'All')
              .map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(status[0].toUpperCase() + status.substring(1)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) selectedStatus = value;
          },
          decoration: const InputDecoration(
            labelText: 'Order Status',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateOrderStatus(order.id, selectedStatus);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order status updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTrackingDialog(
    BuildContext context,
    AdminOrder order,
  ) async {
    final provider = context.read<OrderManagementProvider>();
    final controller = TextEditingController(text: order.trackingNumber ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Tracking - ${order.id}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tracking Number',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateTrackingNumber(order.id, controller.text.trim());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tracking number updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showOrderDetails(
    BuildContext context,
    AdminOrder order,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: _glassCard(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.id,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _detailRow('Customer', order.customerName),
                _detailRow('Email', order.customerEmail),
                _detailRow('Status', order.status),
                _detailRow('Payment', order.paymentStatus),
                _detailRow(
                  'Total',
                  '₱${order.totalAmount.toStringAsFixed(2)}',
                  valueColor: AppColors.primaryDark,
                ),
                _detailRow(
                  'Tracking',
                  (order.trackingNumber == null ||
                          order.trackingNumber!.isEmpty)
                      ? 'Not set'
                      : order.trackingNumber!,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                ...order.items.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shopping_bag_rounded,
                            color: AppColors.primaryDark),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        Text(
                          'x${item.quantity}',
                          style: const TextStyle(
                            color: AppColors.textMedium,
                            fontWeight: FontWeight.w700,
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
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    Color valueColor = AppColors.textDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: valueColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInfo({
    required String title,
    required String value,
    Color valueColor = AppColors.textDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMedium,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: valueColor,
            fontWeight: FontWeight.w900,
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
              Icon(Icons.auto_awesome_rounded, color: color, size: 18),
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

  Widget _dropdownShell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.28),
        ),
      ),
      child: child,
    );
  }

  Widget _smallBadge({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.textLight,
        fontSize: 13,
      ),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.88),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.primaryLight.withOpacity(0.32),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primaryDark,
          width: 1.4,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
