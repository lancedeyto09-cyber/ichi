import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../utils/admin_responsive.dart';

class AdminSidebar extends StatefulWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const AdminSidebar({
    Key? key,
    required this.currentRoute,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.dashboard,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ICHI Admin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'v1.0',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          // Menu Items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    route: '/admin-dashboard',
                    isActive: widget.currentRoute == '/admin-dashboard',
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Products',
                    route: '/admin-products',
                    isActive: widget.currentRoute == '/admin-products',
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Orders',
                    route: '/admin-orders',
                    isActive: widget.currentRoute == '/admin-orders',
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.people_outline,
                    label: 'Customers',
                    route: '/admin-users',
                    isActive: widget.currentRoute == '/admin-users',
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.analytics_outlined,
                    label: 'Analytics',
                    route: '/admin-analytics',
                    isActive: widget.currentRoute == '/admin-analytics',
                  ),
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    route: '/admin-settings',
                    isActive: widget.currentRoute == '/admin-settings',
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryDark.withOpacity(0.2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 16,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Admin User',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'admin@ichi.com',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onNavigate(route),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryDark.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border.all(
                    color: AppColors.primaryDark.withOpacity(0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? AppColors.primaryDark : AppColors.textMedium,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppColors.primaryDark : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
