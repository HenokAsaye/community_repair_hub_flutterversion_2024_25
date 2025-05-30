import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/screens/citizen_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/Detail/Citizen_Detail.dart';

// Define route names as constants for easier reference
class AppRoutes {
  static const String home = '/';
  static const String reportDetails = '/report-details';
  
  // Helper method to generate the report details path with ID
  static String reportDetailsPath(String reportId) => '$reportDetails/$reportId';
}

// Configure the router
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true, // Enable debug logging for router
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const CitizenDashboard(),
      routes: [
        GoRoute(
          path: 'report-details/:reportId',
          name: 'reportDetails',
          builder: (context, state) {
            final reportId = state.pathParameters['reportId'] ?? '';
            // Create a dummy report map for CitizenDetailScreen
            final reportData = {
              'imageUrl': '',
              'title': 'Loading...',
              'location': 'Loading...',
              'status': 'pending',
              'date': DateTime.now(),
              'description': 'Loading report details...',
            };
            return CitizenDetailScreen(report: reportData);
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Page Not Found',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('The path ${state.uri.path} does not exist'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);