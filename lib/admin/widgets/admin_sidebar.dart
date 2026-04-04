import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'admin_ui.dart';

class AdminSidebar extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AdminUI.radiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.70),
              borderRadius: BorderRadius.circular(AdminUI.radiusLg),
              border: Border.all(
                color: Colors.white.withOpacity(0.55),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AdminUI.purpleGradient,
                      borderRadius: BorderRadius.circular(AdminUI.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ICHI Admin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Elegant store control',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(14),
                    children: [
                      _sectionLabel('OVERVIEW'),
                      const SizedBox(height: 10),
                      _navItem(
                        icon: Icons.space_dashboard_rounded,
                        label: 'Dashboard',
                        route: '/admin-dashboard',
                      ),
                      _navItem(
                        icon: Icons.inventory_2_rounded,
                        label: 'Products',
                        route: '/admin-products',
                      ),
                      _navItem(
                        icon: Icons.receipt_long_rounded,
                        label: 'Orders',
                        route: '/admin-orders',
                      ),
                      _navItem(
                        icon: Icons.group_rounded,
                        label: 'Customers',
                        route: '/admin-users',
                      ),
                      _navItem(
                        icon: Icons.bar_chart_rounded,
                        label: 'Analytics',
                        route: '/admin-analytics',
                      ),
                      _navItem(
                        icon: Icons.settings_rounded,
                        label: 'Settings',
                        route: '/admin-settings',
                      ),
                      _navItem(
                        icon: Icons.admin_panel_settings_rounded,
                        label: 'Admin Staff',
                        route: '/admin-staff',
                      ),
                      const SizedBox(height: 16),
                      _sectionLabel('QUICK STATUS'),
                      const SizedBox(height: 10),
                      _miniStatusCard(
                        title: 'Pending Orders',
                        value: '12',
                        color: AppColors.warningColor,
                        icon: Icons.schedule_rounded,
                      ),
                      const SizedBox(height: 12),
                      _miniStatusCard(
                        title: 'Low Stock Items',
                        value: '5',
                        color: AppColors.errorColor,
                        icon: Icons.warning_amber_rounded,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryDark.withOpacity(0.12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0x227D57D7),
                          child: Icon(
                            Icons.person,
                            color: AppColors.primaryDark,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Admin User',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'admin@ichi.com',
                                style: TextStyle(
                                  color: AppColors.textMedium,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        )
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

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isActive = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onNavigate(route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            gradient: isActive ? AdminUI.purpleGradient : null,
            color: isActive ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? Colors.transparent
                  : AppColors.primaryLight.withOpacity(0.18),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? Colors.white : AppColors.textMedium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.textDark,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isActive)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStatusCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
