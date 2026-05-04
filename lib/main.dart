import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/user_order_provider.dart';
import 'admin/providers/admin_provider.dart';
import 'admin/providers/product_management_provider.dart';
import 'admin/providers/order_management_provider.dart';
import 'admin/providers/user_management_provider.dart';
import 'admin/providers/analytics_provider.dart';
import 'auth_gate.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/user_orders_screen.dart';
import 'admin/screens/admin_login_screen.dart';
import 'admin/screens/admin_home_screen.dart';
import 'constants/theme.dart';
import 'screens/user_orders_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/explore_screen.dart';
import 'admin/screens/add_product_screen.dart';
import 'screens/favorites_screen.dart';
import 'admin/providers/dashboard_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const IchiBootstrap());
}

class IchiBootstrap extends StatelessWidget {
  const IchiBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => FirebaseAuthService(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserOrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductManagementProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderManagementProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserManagementProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AnalyticsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
        )
      ],
      child: const IchiApp(),
    );
  }
}

class IchiApp extends StatelessWidget {
  const IchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICHI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
      routes: {
        '/login': (_) => const LoginScreen(isAdminMode: false),
        '/admin-login': (_) => const AdminLoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/home': (_) => const HomeScreen(),
        '/user-orders': (_) => const UserOrdersScreen(),
        '/admin-home': (_) => const AdminHomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/saved': (context) => const SavedScreen(),
        '/explore': (context) => const ExploreScreen(),
        '/admin-add-product': (context) => const AddProductScreen(),
        '/favorites': (context) => const FavoritesScreen(),
      },
    );
  }
}
