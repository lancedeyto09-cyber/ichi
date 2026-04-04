import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'admin/providers/admin_provider.dart';
import 'admin/providers/product_management_provider.dart';
import 'admin/providers/order_management_provider.dart';
import 'admin/providers/user_management_provider.dart';
import 'admin/providers/analytics_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'admin/screens/admin_login_screen.dart';
import 'admin/screens/admin_home_screen.dart';
import 'constants/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => MockAuthService()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ProductManagementProvider()),
        ChangeNotifierProvider(create: (_) => OrderManagementProvider()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ],
      child: const IchiApp(),
    ),
  );
}

class IchiApp extends StatelessWidget {
  const IchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICHI',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(isAdminMode: false),
        '/admin-login': (_) => const AdminLoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/home': (_) => const HomeScreen(),
        '/admin-home': (_) => const AdminHomeScreen(),
      },
    );
  }
}
