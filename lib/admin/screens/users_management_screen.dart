import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../models/admin_user_management_model.dart';
import '../providers/user_management_provider.dart';
import '../utils/admin_responsive.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementProvider>().loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagementProvider>(
      builder: (context, provider, _) {
        final isMobile = AdminResponsive.isMobile(context);
        final customers = provider.customers;
        final totalCustomers = provider.totalCustomers;
        final activeCustomers = provider.activeCustomers;
        final suspendedCustomers = totalCustomers - activeCustomers;
        final totalSpent = customers.fold<double>(
          0,
          (sum, customer) => sum + customer.totalSpent,
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
                const SizedBox(height: 20),
                if (isMobile)
                  Column(
                    children: [
                      _statCard(
                        title: 'Total Customers',
                        value: '$totalCustomers',
                        subtitle: 'Registered accounts',
                        icon: Icons.group_rounded,
                        color: AppColors.primaryDark,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        title: 'Active',
                        value: '$activeCustomers',
                        subtitle: 'Currently active',
                        icon: Icons.verified_user_rounded,
                        color: AppColors.successColor,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        title: 'Suspended',
                        value: '$suspendedCustomers',
                        subtitle: 'Restricted accounts',
                        icon: Icons.block_rounded,
                        color: AppColors.warningColor,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        title: 'Customer Value',
                        value: '₱${totalSpent.toStringAsFixed(0)}',
                        subtitle: 'Combined visible spend',
                        icon: Icons.payments_rounded,
                        color: AppColors.accentColor,
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
                        title: 'Total Customers',
                        value: '$totalCustomers',
                        subtitle: 'Registered accounts',
                        icon: Icons.group_rounded,
                        color: AppColors.primaryDark,
                      ),
                      _statCard(
                        title: 'Active',
                        value: '$activeCustomers',
                        subtitle: 'Currently active',
                        icon: Icons.verified_user_rounded,
                        color: AppColors.successColor,
                      ),
                      _statCard(
                        title: 'Suspended',
                        value: '$suspendedCustomers',
                        subtitle: 'Restricted accounts',
                        icon: Icons.block_rounded,
                        color: AppColors.warningColor,
                      ),
                      _statCard(
                        title: 'Customer Value',
                        value: '₱${totalSpent.toStringAsFixed(0)}',
                        subtitle: 'Combined visible spend',
                        icon: Icons.payments_rounded,
                        color: AppColors.accentColor,
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
                          onChanged: provider.searchCustomers,
                          decoration: _inputDecoration(
                            hint: 'Search by name or email...',
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
                              items: const [
                                DropdownMenuItem(
                                  value: 'All',
                                  child: Text('All Customers'),
                                ),
                                DropdownMenuItem(
                                  value: 'Active',
                                  child: Text('Active'),
                                ),
                                DropdownMenuItem(
                                  value: 'Suspended',
                                  child: Text('Suspended'),
                                ),
                              ],
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
                              width: 320,
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: provider.searchCustomers,
                                decoration: _inputDecoration(
                                  hint: 'Search by name or email...',
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
                                items: const [
                                  DropdownMenuItem(
                                    value: 'All',
                                    child: Text('All Customers'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Active',
                                    child: Text('Active'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Suspended',
                                    child: Text('Suspended'),
                                  ),
                                ],
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
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _chip(
                            label: '${customers.length} shown',
                            color: AppColors.primaryDark,
                            icon: Icons.filter_alt_rounded,
                          ),
                          _chip(
                            label: '$activeCustomers active',
                            color: AppColors.successColor,
                            icon: Icons.check_circle_rounded,
                          ),
                        ],
                      ),
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
                else if (customers.isEmpty)
                  _glassCard(
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 42),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 58,
                              color: AppColors.textLight,
                            ),
                            SizedBox(height: 14),
                            Text(
                              'No customers found',
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
                    children: customers
                        .map(
                          (customer) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _customerCard(
                              customer: customer,
                              isMobile: isMobile,
                              onView: () =>
                                  _showCustomerDetails(context, customer),
                              onToggleStatus: () {
                                if (customer.isActive) {
                                  provider.suspendCustomer(customer.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Customer suspended'),
                                    ),
                                  );
                                } else {
                                  provider.activateCustomer(customer.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Customer activated'),
                                    ),
                                  );
                                }
                              },
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
            'Customers',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'View customer profiles, spending behavior, account status, and profile history.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textMedium,
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
                  color: AppColors.primaryDark.withOpacity(0.20),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_search_rounded,
                    color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Customer Control',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
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
                'Customers',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'View customer profiles, spending behavior, account status, and profile history.',
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primaryMid],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.20),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_search_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Customer Control',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _customerCard({
    required AdminCustomerUser customer,
    required bool isMobile,
    required VoidCallback onView,
    required VoidCallback onToggleStatus,
  }) {
    final statusColor =
        customer.isActive ? AppColors.successColor : AppColors.warningColor;

    return _glassCard(
      padding: EdgeInsets.all(isMobile ? 16 : 18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryDark.withOpacity(0.14),
                child: Text(
                  customer.name.isNotEmpty
                      ? customer.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customer.phone ?? 'No phone number',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMobile)
                _smallBadge(
                  label: customer.isActive ? 'Active' : 'Suspended',
                  color: statusColor,
                ),
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: _smallBadge(
                label: customer.isActive ? 'Active' : 'Suspended',
                color: statusColor,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (isMobile) ...[
            Row(
              children: [
                Expanded(
                  child: _miniInfo(
                    title: 'Orders',
                    value: '${customer.totalOrders}',
                  ),
                ),
                Expanded(
                  child: _miniInfo(
                    title: 'Spent',
                    value: '₱${customer.totalSpent.toStringAsFixed(2)}',
                    valueColor: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _miniInfo(
                    title: 'Joined',
                    value: _formatDate(customer.registeredDate),
                  ),
                ),
                Expanded(
                  child: _miniInfo(
                    title: 'Favorites',
                    value: '${customer.favoriteProducts.length}',
                    valueColor: AppColors.accentColor,
                  ),
                ),
              ],
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _miniInfo(
                    title: 'Orders',
                    value: '${customer.totalOrders}',
                  ),
                ),
                Expanded(
                  child: _miniInfo(
                    title: 'Spent',
                    value: '₱${customer.totalSpent.toStringAsFixed(2)}',
                    valueColor: AppColors.primaryDark,
                  ),
                ),
                Expanded(
                  child: _miniInfo(
                    title: 'Joined',
                    value: _formatDate(customer.registeredDate),
                  ),
                ),
                Expanded(
                  child: _miniInfo(
                    title: 'Favorites',
                    value: '${customer.favoriteProducts.length}',
                    valueColor: AppColors.accentColor,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Account ID: ${customer.id}',
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
                    'View Profile',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: onToggleStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: customer.isActive
                        ? AppColors.warningColor
                        : AppColors.successColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: Icon(
                    customer.isActive
                        ? Icons.block_rounded
                        : Icons.check_circle_rounded,
                    size: 18,
                  ),
                  label: Text(
                    customer.isActive ? 'Suspend' : 'Activate',
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
                      'View Profile',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onToggleStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customer.isActive
                          ? AppColors.warningColor
                          : AppColors.successColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: Icon(
                      customer.isActive
                          ? Icons.block_rounded
                          : Icons.check_circle_rounded,
                      size: 18,
                    ),
                    label: Text(
                      customer.isActive ? 'Suspend' : 'Activate',
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

  Future<void> _showCustomerDetails(
    BuildContext context,
    AdminCustomerUser customer,
  ) async {
    final provider = context.read<UserManagementProvider>();
    final isMobile = AdminResponsive.isMobile(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(isMobile ? 12 : 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 860,
                ),
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.55),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              customer.name,
                              style: TextStyle(
                                fontSize: isMobile ? 20 : 24,
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
                      const SizedBox(height: 6),
                      const Text(
                        'Review customer identity, spending, favorites, and account activity.',
                        style: TextStyle(
                          color: AppColors.textMedium,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (isMobile) ...[
                        _sectionCard(
                          title: 'Profile',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _detailRow('Customer ID', customer.id),
                              _detailRow('Name', customer.name),
                              _detailRow('Email', customer.email),
                              _detailRow(
                                'Phone',
                                customer.phone ?? 'Not available',
                              ),
                              _detailRow(
                                'Status',
                                customer.accountStatus,
                                valueColor: customer.isActive
                                    ? AppColors.successColor
                                    : AppColors.warningColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _sectionCard(
                          title: 'Account Summary',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _detailRow(
                                'Joined',
                                _formatDate(customer.registeredDate),
                              ),
                              _detailRow(
                                'Total Orders',
                                '${customer.totalOrders}',
                              ),
                              _detailRow(
                                'Total Spent',
                                '₱${customer.totalSpent.toStringAsFixed(2)}',
                                valueColor: AppColors.primaryDark,
                              ),
                              _detailRow(
                                'Favorites',
                                '${customer.favoriteProducts.length}',
                                valueColor: AppColors.accentColor,
                              ),
                            ],
                          ),
                        ),
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _sectionCard(
                                title: 'Profile',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _detailRow('Customer ID', customer.id),
                                    _detailRow('Name', customer.name),
                                    _detailRow('Email', customer.email),
                                    _detailRow(
                                      'Phone',
                                      customer.phone ?? 'Not available',
                                    ),
                                    _detailRow(
                                      'Status',
                                      customer.accountStatus,
                                      valueColor: customer.isActive
                                          ? AppColors.successColor
                                          : AppColors.warningColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _sectionCard(
                                title: 'Account Summary',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _detailRow(
                                      'Joined',
                                      _formatDate(customer.registeredDate),
                                    ),
                                    _detailRow(
                                      'Total Orders',
                                      '${customer.totalOrders}',
                                    ),
                                    _detailRow(
                                      'Total Spent',
                                      '₱${customer.totalSpent.toStringAsFixed(2)}',
                                      valueColor: AppColors.primaryDark,
                                    ),
                                    _detailRow(
                                      'Favorites',
                                      '${customer.favoriteProducts.length}',
                                      valueColor: AppColors.accentColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 14),
                      _sectionCard(
                        title: 'Favorite Products',
                        child: customer.favoriteProducts.isEmpty
                            ? const Text(
                                'No favorite products yet.',
                                style: TextStyle(
                                  color: AppColors.textMedium,
                                ),
                              )
                            : Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: customer.favoriteProducts
                                    .map(
                                      (productId) => _smallBadge(
                                        label: 'Product $productId',
                                        color: AppColors.primaryDark,
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                      const SizedBox(height: 14),
                      _sectionCard(
                        title: 'Customer Insights',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _insightPanel(
                              icon: Icons.shopping_bag_rounded,
                              color: AppColors.primaryDark,
                              title: 'Purchase Activity',
                              text:
                                  '${customer.name} has completed ${customer.totalOrders} order(s).',
                            ),
                            const SizedBox(height: 12),
                            _insightPanel(
                              icon: Icons.payments_rounded,
                              color: AppColors.successColor,
                              title: 'Spending Level',
                              text:
                                  'Customer lifetime value is ₱${customer.totalSpent.toStringAsFixed(2)}.',
                            ),
                            const SizedBox(height: 12),
                            _insightPanel(
                              icon: Icons.favorite_rounded,
                              color: AppColors.accentColor,
                              title: 'Interest Pattern',
                              text:
                                  '${customer.favoriteProducts.length} favorite product(s) saved in profile data.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (isMobile)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: customer.isActive
                                    ? AppColors.warningColor
                                    : AppColors.successColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                if (customer.isActive) {
                                  provider.suspendCustomer(customer.id);
                                } else {
                                  provider.activateCustomer(customer.id);
                                }
                                Navigator.pop(context);
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      customer.isActive
                                          ? 'Customer suspended'
                                          : 'Customer activated',
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                customer.isActive
                                    ? Icons.block_rounded
                                    : Icons.check_circle_rounded,
                              ),
                              label: Text(
                                customer.isActive
                                    ? 'Suspend Account'
                                    : 'Activate Account',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: customer.isActive
                                    ? AppColors.warningColor
                                    : AppColors.successColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                if (customer.isActive) {
                                  provider.suspendCustomer(customer.id);
                                } else {
                                  provider.activateCustomer(customer.id);
                                }
                                Navigator.pop(context);
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      customer.isActive
                                          ? 'Customer suspended'
                                          : 'Customer activated',
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                customer.isActive
                                    ? Icons.block_rounded
                                    : Icons.check_circle_rounded,
                              ),
                              label: Text(
                                customer.isActive
                                    ? 'Suspend Account'
                                    : 'Activate Account',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.74),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
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
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightPanel({
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
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
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
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                    height: 1.35,
                  ),
                ),
              ],
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

  Widget _chip({
    required String label,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
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
