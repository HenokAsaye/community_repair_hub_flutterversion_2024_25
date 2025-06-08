import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Screens with prefix to avoid naming conflicts
import 'features/auth/presentation/screens/login_screen.dart' as login_screen;
import 'features/auth/presentation/screens/register_screen.dart'
    as register_screen;
import 'features/auth/presentation/screens/splash_screen.dart' as splash_screen;
import 'features/dashboard/presentation/screens/citizen_dashboard_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Community Repair Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20), // Dark green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white,
        ),
      ),
      home: const splash_screen.SplashScreen(),
      routes: {
        '/login': (_) => const login_screen.LoginScreen(),
        '/register': (_) => const register_screen.RegisterScreen(),
        '/home': (_) => const CitizenDashboard(),
      },
    );
  }
}
