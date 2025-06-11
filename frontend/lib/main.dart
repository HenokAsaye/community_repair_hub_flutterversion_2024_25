import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/routes/app_router.dart'; // Use GoRouter
import 'features/auth/presentation/providers/auth_provider.dart'; // Import for sharedPreferencesProvider

// import 'features/dashboard/presentation/screens/team_dashboard_screen.dart'; // No longer needed here if using router
// import 'features/dashboard/presentation/screens/Detail/Repair_Team_Detail.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter bindings are initialized
  final prefs = await SharedPreferences.getInstance(); // Initialize SharedPreferences

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs), // Override the provider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Community Repair Hub',
      debugShowCheckedModeBanner: false,
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
      routerConfig: appRouter, // Use the GoRouter configuration

    );
  }
}
