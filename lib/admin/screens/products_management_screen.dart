import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../models/admin_product_model.dart';
import '../providers/product_management_provider.dart';
import '../utils/admin_responsive.dart';

class ProductsManagementScreen extends StatefulWidget {
  const ProductsManagementScreen({super.key});

  @override
  State<ProductsManagementScreen> createState() =>
      _ProductsManagementScreenState();
}

class _ProductsManagementScreenState extends State<ProductsManagementScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _sortValue = 'name';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductManagementProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductManagementProvider>(
      builder: (context, provider, _) {
        final isMobile = AdminResponsive.isMobile(context);
        final products = provider.products;
        final lowStock = provider.getLowStockProducts();
        final activeCount = products.where((p) => p.isActive).length;
        final inactiveCount = products.where((p) => !p.isActive).length;
        final totalValue = products.fold<double>(
          0,
          (sum, p) => sum + (p.price * p.stock),
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
                _buildHeader(provider, isMobile),
                const SizedBox(height: 20),
                if (isMobile)
                  Column(
                    children: [
                      _statCard(
                        title: 'Total Products',
                        value: '${products.length}',
                        subtitle: 'Catalog items',
                        icon: Icons.inventory_2_rounded,
                        color: AppColors.primaryDark,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        title: 'Active',
                        value: '$activeCount',
                        subtitle: 'Visible in store',
                        icon: Icons.check_circle_rounded,
                        color: AppColors.successColor,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        title: 'Low Stock',
                        value: '${lowStock.length}',
                        subtitle: 'Need restock',
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.warningColor,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 12),
                      _statCard(
                        title: 'Inventory Value',
                        value: '₱${totalValue.toStringAsFixed(0)}',
                        subtitle: 'Estimated stock value',
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
                        title: 'Total Products',
                        value: '${products.length}',
                        subtitle: 'Catalog items',
                        icon: Icons.inventory_2_rounded,
                        color: AppColors.primaryDark,
                      ),
                      _statCard(
                        title: 'Active',
                        value: '$activeCount',
                        subtitle: 'Visible in store',
                        icon: Icons.check_circle_rounded,
                        color: AppColors.successColor,
                      ),
                      _statCard(
                        title: 'Low Stock',
                        value: '${lowStock.length}',
                        subtitle: 'Need restock',
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.warningColor,
                      ),
                      _statCard(
                        title: 'Inventory Value',
                        value: '₱${totalValue.toStringAsFixed(0)}',
                        subtitle: 'Estimated stock value',
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
                          onChanged: provider.searchProducts,
                          decoration: _inputDecoration(
                            hint: 'Search by name, SKU, or description...',
                            prefixIcon: const Icon(Icons.search_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _dropdownShell(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: provider.selectedCategory,
                                  underline: const SizedBox(),
                                  borderRadius: BorderRadius.circular(16),
                                  icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded),
                                  items: provider.categories
                                      .map(
                                        (category) => DropdownMenuItem(
                                          value: category,
                                          child: Text(
                                            category,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      provider.filterByCategory(value);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _dropdownShell(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _sortValue,
                                  underline: const SizedBox(),
                                  borderRadius: BorderRadius.circular(16),
                                  icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'name',
                                      child: Text('Name'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'price',
                                      child: Text('Price'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'stock',
                                      child: Text('Stock'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'rating',
                                      child: Text('Rating'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _sortValue = value);
                                      provider.sortProducts(value);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _openProductDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text(
                              'Add Product',
                              style: TextStyle(fontWeight: FontWeight.w700),
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
                              width: 300,
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: provider.searchProducts,
                                decoration: _inputDecoration(
                                  hint:
                                      'Search by name, SKU, or description...',
                                  prefixIcon: const Icon(Icons.search_rounded),
                                ),
                              ),
                            ),
                            _dropdownShell(
                              child: DropdownButton<String>(
                                value: provider.selectedCategory,
                                underline: const SizedBox(),
                                borderRadius: BorderRadius.circular(16),
                                icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded),
                                items: provider.categories
                                    .map(
                                      (category) => DropdownMenuItem(
                                        value: category,
                                        child: Text(category),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    provider.filterByCategory(value);
                                  }
                                },
                              ),
                            ),
                            _dropdownShell(
                              child: DropdownButton<String>(
                                value: _sortValue,
                                underline: const SizedBox(),
                                borderRadius: BorderRadius.circular(16),
                                icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'name',
                                    child: Text('Sort: Name'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'price',
                                    child: Text('Sort: Price'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'stock',
                                    child: Text('Sort: Stock'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'rating',
                                    child: Text('Sort: Rating'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _sortValue = value);
                                    provider.sortProducts(value);
                                  }
                                },
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _openProductDialog(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDark,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text(
                                'Add Product',
                                style: TextStyle(fontWeight: FontWeight.w700),
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
                            label: '${products.length} shown',
                            color: AppColors.primaryDark,
                            icon: Icons.grid_view_rounded,
                          ),
                          _chip(
                            label: '$inactiveCount inactive',
                            color: AppColors.textMedium,
                            icon: Icons.visibility_off_rounded,
                          ),
                          if (lowStock.isNotEmpty)
                            _chip(
                              label: '${lowStock.length} low stock',
                              color: AppColors.warningColor,
                              icon: Icons.warning_amber_rounded,
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
                else if (products.isEmpty)
                  _glassCard(
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 42),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 58,
                              color: AppColors.textLight,
                            ),
                            SizedBox(height: 14),
                            Text(
                              'No products found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Try changing your filters or add a new product.',
                              style: TextStyle(
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (isMobile)
                  Column(
                    children: products
                        .map(
                          (product) => _mobileProductCard(
                            product: product,
                            onEdit: () =>
                                _openProductDialog(context, product: product),
                            onDelete: () => _confirmDelete(
                                context, product.id, product.name),
                            onToggleStatus: () {
                              provider.updateProduct(
                                product.copyWith(
                                  isActive: !product.isActive,
                                  updatedAt: DateTime.now(),
                                ),
                              );
                            },
                          ),
                        )
                        .toList(),
                  )
                else
                  _glassCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _tableHeader(),
                        const SizedBox(height: 10),
                        ...products.map(
                          (product) => _productRow(
                            product: product,
                            onEdit: () =>
                                _openProductDialog(context, product: product),
                            onDelete: () => _confirmDelete(
                                context, product.id, product.name),
                            onToggleStatus: () {
                              provider.updateProduct(
                                product.copyWith(
                                  isActive: !product.isActive,
                                  updatedAt: DateTime.now(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ProductManagementProvider provider, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Products',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your catalog, pricing, stock levels, and product visibility.',
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
                Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Catalog Manager',
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
                'Products',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Manage your catalog, pricing, stock levels, and product visibility.',
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
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Catalog Manager',
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

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Expanded(flex: 3, child: _HeaderText('Product')),
          Expanded(flex: 2, child: _HeaderText('Category / SKU')),
          Expanded(flex: 1, child: _HeaderText('Price')),
          Expanded(flex: 1, child: _HeaderText('Stock')),
          Expanded(flex: 1, child: _HeaderText('Rating')),
          Expanded(flex: 2, child: _HeaderText('Status')),
          SizedBox(width: 126, child: _HeaderText('Actions')),
        ],
      ),
    );
  }

  Widget _productRow({
    required AdminProduct product,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onToggleStatus,
  }) {
    final lowStock = product.stock <= 5;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: lowStock
              ? AppColors.warningColor.withOpacity(0.24)
              : AppColors.primaryLight.withOpacity(0.16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryLight.withOpacity(0.9),
                        AppColors.primaryDark.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _smallBadge(
                  label: product.category,
                  color: AppColors.accentColor,
                ),
                const SizedBox(height: 6),
                Text(
                  product.sku,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '₱${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: _smallBadge(
              label: '${product.stock}',
              color: lowStock ? AppColors.warningColor : AppColors.successColor,
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 4),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _smallBadge(
                  label: product.isActive ? 'Active' : 'Inactive',
                  color: product.isActive
                      ? AppColors.successColor
                      : AppColors.textMedium,
                ),
                if (lowStock)
                  _smallBadge(
                    label: 'Low stock',
                    color: AppColors.warningColor,
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 126,
            child: Row(
              children: [
                _actionButton(
                  icon: Icons.edit_rounded,
                  color: AppColors.primaryDark,
                  onTap: onEdit,
                ),
                const SizedBox(width: 8),
                _actionButton(
                  icon: product.isActive
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppColors.accentColor,
                  onTap: onToggleStatus,
                ),
                const SizedBox(width: 8),
                _actionButton(
                  icon: Icons.delete_rounded,
                  color: AppColors.errorColor,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileProductCard({
    required AdminProduct product,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onToggleStatus,
  }) {
    final lowStock = product.stock <= 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryLight.withOpacity(0.9),
                        AppColors.primaryDark.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      const Icon(Icons.music_note_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.sku,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _smallBadge(
                    label: product.category, color: AppColors.accentColor),
                _smallBadge(
                  label: product.isActive ? 'Active' : 'Inactive',
                  color: product.isActive
                      ? AppColors.successColor
                      : AppColors.textMedium,
                ),
                if (lowStock)
                  _smallBadge(
                    label: 'Low stock',
                    color: AppColors.warningColor,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _miniInfo(
                    title: 'Price',
                    value: '₱${product.price.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _miniInfo(
                    title: 'Stock',
                    value: '${product.stock}',
                  ),
                ),
                Expanded(
                  child: _miniInfo(
                    title: 'Rating',
                    value: product.rating.toStringAsFixed(1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              product.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMedium,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Edit'),
                ),
                OutlinedButton.icon(
                  onPressed: onToggleStatus,
                  icon: Icon(
                    product.isActive
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 18,
                  ),
                  label: Text(product.isActive ? 'Hide' : 'Show'),
                ),
                ElevatedButton.icon(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.delete_rounded, size: 18),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String productId,
    String productName,
  ) async {
    final provider = context.read<ProductManagementProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$productName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      provider.deleteProduct(productId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted')),
        );
      }
    }
  }

  Future<void> _openProductDialog(
    BuildContext context, {
    AdminProduct? product,
  }) async {
    final provider = context.read<ProductManagementProvider>();
    final isEdit = product != null;
    final isMobile = AdminResponsive.isMobile(context);

    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final descriptionCtrl =
        TextEditingController(text: product?.description ?? '');
    final priceCtrl = TextEditingController(
      text: product != null ? product.price.toString() : '',
    );
    final stockCtrl = TextEditingController(
      text: product != null ? product.stock.toString() : '',
    );
    final ratingCtrl = TextEditingController(
      text: product != null ? product.rating.toString() : '4.5',
    );
    final reviewsCtrl = TextEditingController(
      text: product != null ? product.reviews.toString() : '0',
    );
    final skuCtrl = TextEditingController(text: product?.sku ?? '');
    final imageCtrl = TextEditingController(text: product?.image ?? '');
    final tagsCtrl = TextEditingController(
      text: product?.tags.join(', ') ?? '',
    );

    String selectedCategory = product?.category ??
        (provider.categories.length > 1 ? provider.categories[1] : 'General');
    bool isActive = product?.isActive ?? true;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(isMobile ? 12 : 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? double.infinity : 760,
                    ),
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.55),
                      ),
                    ),
                    child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isEdit ? 'Edit Product' : 'Add Product',
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
                              'Update catalog details, pricing, visibility, and inventory.',
                              style: TextStyle(color: AppColors.textMedium),
                            ),
                            const SizedBox(height: 20),
                            if (isMobile)
                              Column(
                                children: [
                                  _fieldShell(
                                    child: TextFormField(
                                      controller: nameCtrl,
                                      decoration: _inputDecoration(
                                          hint: 'Product name'),
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                              ? 'Required'
                                              : null,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _fieldShell(
                                    child: DropdownButtonFormField<String>(
                                      value: selectedCategory,
                                      decoration: _inputDecoration(
                                        hint: 'Category',
                                      ),
                                      items: provider.categories
                                          .where((c) => c != 'All')
                                          .map(
                                            (category) => DropdownMenuItem(
                                              value: category,
                                              child: Text(category),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setModalState(
                                            () => selectedCategory = value,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _fieldShell(
                                    child: TextFormField(
                                      controller: skuCtrl,
                                      decoration: _inputDecoration(hint: 'SKU'),
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                              ? 'Required'
                                              : null,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _fieldShell(
                                    child: TextFormField(
                                      controller: priceCtrl,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration:
                                          _inputDecoration(hint: 'Price'),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Invalid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _fieldShell(
                                    child: TextFormField(
                                      controller: stockCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration:
                                          _inputDecoration(hint: 'Stock'),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        if (int.tryParse(value) == null) {
                                          return 'Invalid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _fieldShell(
                                    child: TextFormField(
                                      controller: ratingCtrl,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration:
                                          _inputDecoration(hint: 'Rating'),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _fieldShell(
                                    child: TextFormField(
                                      controller: reviewsCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration:
                                          _inputDecoration(hint: 'Reviews'),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _fieldShell(
                                    child: TextFormField(
                                      controller: imageCtrl,
                                      decoration: _inputDecoration(
                                        hint: 'Image path (optional)',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _fieldShell(
                                    child: TextFormField(
                                      controller: descriptionCtrl,
                                      minLines: 3,
                                      maxLines: 5,
                                      decoration: _inputDecoration(
                                        hint: 'Description',
                                      ),
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                              ? 'Required'
                                              : null,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _fieldShell(
                                    child: TextFormField(
                                      controller: tagsCtrl,
                                      decoration: _inputDecoration(
                                        hint: 'Tags separated by comma',
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Wrap(
                                spacing: 14,
                                runSpacing: 14,
                                children: [
                                  _fieldShell(
                                    width: 340,
                                    child: TextFormField(
                                      controller: nameCtrl,
                                      decoration: _inputDecoration(
                                          hint: 'Product name'),
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                              ? 'Required'
                                              : null,
                                    ),
                                  ),
                                  _fieldShell(
                                    width: 220,
                                    child: DropdownButtonFormField<String>(
                                      value: selectedCategory,
                                      decoration: _inputDecoration(
                                        hint: 'Category',
                                      ),
                                      items: provider.categories
                                          .where((c) => c != 'All')
                                          .map(
                                            (category) => DropdownMenuItem(
                                              value: category,
                                              child: Text(category),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setModalState(
                                            () => selectedCategory = value,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  _fieldShell(
                                    width: 140,
                                    child: TextFormField(
                                      controller: skuCtrl,
                                      decoration: _inputDecoration(hint: 'SKU'),
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                              ? 'Required'
                                              : null,
                                    ),
                                  ),
                                  _fieldShell(
                                    width: 220,
                                    child: TextFormField(
                                      controller: priceCtrl,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration:
                                          _inputDecoration(hint: 'Price'),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Invalid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  _fieldShell(
                                    width: 180,
                                    child: TextFormField(
                                      controller: stockCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration:
                                          _inputDecoration(hint: 'Stock'),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Required';
                                        }
                                        if (int.tryParse(value) == null) {
                                          return 'Invalid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  _fieldShell(
                                    width: 160,
                                    child: TextFormField(
                                      controller: ratingCtrl,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration:
                                          _inputDecoration(hint: 'Rating'),
                                    ),
                                  ),
                                  _fieldShell(
                                    width: 160,
                                    child: TextFormField(
                                      controller: reviewsCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration:
                                          _inputDecoration(hint: 'Reviews'),
                                    ),
                                  ),
                                  _fieldShell(
                                    width: 520,
                                    child: TextFormField(
                                      controller: imageCtrl,
                                      decoration: _inputDecoration(
                                        hint: 'Image path (optional)',
                                      ),
                                    ),
                                  ),
                                  _fieldShell(
                                    width: 700,
                                    child: TextFormField(
                                      controller: descriptionCtrl,
                                      minLines: 3,
                                      maxLines: 5,
                                      decoration: _inputDecoration(
                                        hint: 'Description',
                                      ),
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty
                                              ? 'Required'
                                              : null,
                                    ),
                                  ),
                                  _fieldShell(
                                    width: 700,
                                    child: TextFormField(
                                      controller: tagsCtrl,
                                      decoration: _inputDecoration(
                                        hint: 'Tags separated by comma',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 18),
                            SwitchListTile(
                              value: isActive,
                              contentPadding: EdgeInsets.zero,
                              activeColor: AppColors.primaryDark,
                              title: const Text(
                                'Active product',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: const Text(
                                'When active, this product is visible in the store catalog.',
                              ),
                              onChanged: (value) {
                                setModalState(() => isActive = value);
                              },
                            ),
                            const SizedBox(height: 20),
                            if (isMobile)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryDark,
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
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }

                                      final now = DateTime.now();
                                      final tags = tagsCtrl.text
                                          .split(',')
                                          .map((e) => e.trim())
                                          .where((e) => e.isNotEmpty)
                                          .toList();

                                      final newProduct = AdminProduct(
                                        id: product?.id ??
                                            DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString(),
                                        name: nameCtrl.text.trim(),
                                        description:
                                            descriptionCtrl.text.trim(),
                                        price:
                                            double.parse(priceCtrl.text.trim()),
                                        originalPrice: product?.originalPrice,
                                        category: selectedCategory,
                                        image: imageCtrl.text.trim().isEmpty
                                            ? 'assets/images/product.png'
                                            : imageCtrl.text.trim(),
                                        stock: int.parse(stockCtrl.text.trim()),
                                        rating: double.tryParse(
                                              ratingCtrl.text.trim(),
                                            ) ??
                                            4.5,
                                        reviews: int.tryParse(
                                              reviewsCtrl.text.trim(),
                                            ) ??
                                            0,
                                        isActive: isActive,
                                        createdAt: product?.createdAt ?? now,
                                        updatedAt: now,
                                        tags: tags,
                                        sku: skuCtrl.text.trim(),
                                      );

                                      if (isEdit) {
                                        provider.updateProduct(newProduct);
                                      } else {
                                        provider.addProduct(newProduct);
                                      }

                                      Navigator.pop(context);

                                      ScaffoldMessenger.of(this.context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isEdit
                                                ? 'Product updated'
                                                : 'Product added',
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      isEdit
                                          ? Icons.save_rounded
                                          : Icons.add_rounded,
                                    ),
                                    label: Text(
                                      isEdit
                                          ? 'Save Changes'
                                          : 'Create Product',
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
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryDark,
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
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }

                                      final now = DateTime.now();
                                      final tags = tagsCtrl.text
                                          .split(',')
                                          .map((e) => e.trim())
                                          .where((e) => e.isNotEmpty)
                                          .toList();

                                      final newProduct = AdminProduct(
                                        id: product?.id ??
                                            DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString(),
                                        name: nameCtrl.text.trim(),
                                        description:
                                            descriptionCtrl.text.trim(),
                                        price:
                                            double.parse(priceCtrl.text.trim()),
                                        originalPrice: product?.originalPrice,
                                        category: selectedCategory,
                                        image: imageCtrl.text.trim().isEmpty
                                            ? 'assets/images/product.png'
                                            : imageCtrl.text.trim(),
                                        stock: int.parse(stockCtrl.text.trim()),
                                        rating: double.tryParse(
                                              ratingCtrl.text.trim(),
                                            ) ??
                                            4.5,
                                        reviews: int.tryParse(
                                              reviewsCtrl.text.trim(),
                                            ) ??
                                            0,
                                        isActive: isActive,
                                        createdAt: product?.createdAt ?? now,
                                        updatedAt: now,
                                        tags: tags,
                                        sku: skuCtrl.text.trim(),
                                      );

                                      if (isEdit) {
                                        provider.updateProduct(newProduct);
                                      } else {
                                        provider.addProduct(newProduct);
                                      }

                                      Navigator.pop(context);

                                      ScaffoldMessenger.of(this.context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isEdit
                                                ? 'Product updated'
                                                : 'Product added',
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      isEdit
                                          ? Icons.save_rounded
                                          : Icons.add_rounded,
                                    ),
                                    label: Text(
                                      isEdit
                                          ? 'Save Changes'
                                          : 'Create Product',
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
              ),
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    descriptionCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    ratingCtrl.dispose();
    reviewsCtrl.dispose();
    skuCtrl.dispose();
    imageCtrl.dispose();
    tagsCtrl.dispose();
  }

  Widget _fieldShell({double? width, required Widget child}) {
    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return SizedBox(width: double.infinity, child: child);
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

  Widget _glassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
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
              Icon(Icons.trending_up_rounded, color: color, size: 18),
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

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _miniInfo({
    required String title,
    required String value,
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
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.errorColor,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.errorColor,
          width: 1.4,
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;

  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textMedium,
      ),
    );
  }
}
