import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    Provider<AuthService>(
      create: (_) => MockAuthService(),
      child: const IchiApp(),
    ),
  );
}

class IchiApp extends StatelessWidget {
  const IchiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = const Color.fromARGB(255, 198, 179, 250);
    return MaterialApp(
      title: 'ICHI',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(isAdminMode: false),
        '/admin-login': (_) => const LoginScreen(isAdminMode: true),
        '/signup': (_) => const SignupScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
