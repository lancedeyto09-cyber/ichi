import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../providers/admin_provider.dart';
import '../utils/admin_responsive.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_app_bar.dart';
import 'dashboard_screen.dart';
import 'products_management_screen.dart';
import 'orders_management_screen.dart';
import 'users_management_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String _currentRoute = '/admin-dashboard';

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        if (!adminProvider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/admin-login');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AdminAppBar(
            title: _getTitleForRoute(_currentRoute),
          ),
          body: Row(
            children: [
              if (!AdminResponsive.isMobile(context))
                AdminSidebar(
                  currentRoute: _currentRoute,
                  onNavigate: (route) {
                    setState(() => _currentRoute = route);
                  },
                ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF5F7FA),
                  child: _buildScreenForRoute(_currentRoute),
                ),
              ),
            ],
          ),
          drawer: AdminResponsive.isMobile(context)
              ? Drawer(
                  child: AdminSidebar(
                    currentRoute: _currentRoute,
                    onNavigate: (route) {
                      setState(() => _currentRoute = route);
                      Navigator.pop(context);
                    },
                  ),
                )
              : null,
        );
      },
    );
  }

  String _getTitleForRoute(String route) {
    switch (route) {
      case '/admin-dashboard':
        return 'Dashboard';
      case '/admin-products':
        return 'Products';
      case '/admin-orders':
        return 'Orders';
      case '/admin-users':
        return 'Customers';
      case '/admin-analytics':
        return 'Analytics';
      case '/admin-settings':
        return 'Settings';
      default:
        return 'Admin';
    }
  }

  Widget _buildScreenForRoute(String route) {
    switch (route) {
      case '/admin-dashboard':
        return DashboardScreen();
      case '/admin-products':
        return ProductsManagementScreen();
      case '/admin-orders':
        return OrdersManagementScreen();
      case '/admin-users':
        return UsersManagementScreen();
      case '/admin-analytics':
        return AnalyticsScreen();
      case '/admin-settings':
        return SettingsScreen();
      default:
        return DashboardScreen();
    }
  }
}
