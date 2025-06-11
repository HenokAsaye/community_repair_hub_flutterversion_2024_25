import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/screens/citizen_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/Detail/Citizen_Detail.dart';
import '../../features/dashboard/presentation/screens/Detail/Repair_Team_Detail.dart';
import '../../shared/models/report.dart' as shared_models; // For Issue model
import '../../features/reports/presentation/screens/update_status_screen.dart';
import '../../features/dashboard/presentation/screens/team_dashboard_screen.dart'; // Import RepairTeamDashboard
import '../../features/auth/presentation/screens/AuthScreen.dart'; // Import AuthScreen
import '../../features/auth/presentation/screens/login_screen.dart'; // Import LoginScreen
import '../../features/auth/presentation/screens/register_screen.dart'; // Import RegisterScreen

// Define route names as constants for easier reference
class AppRoutes {
  static const String home = '/';
  static const String reportDetails = '/report-details';
  static const String updateStatus = '/reports/update-status';
  static const String repairTeamReportDetails = '/repair-team/report-details'; // New route
  static const String repairTeamDashboard = '/repair-team-dashboard'; // Route for RepairTeamDashboard
  static const String auth = '/auth'; // Route for AuthScreen
  static const String login = '/login'; // Route for LoginScreen
  static const String signup = '/signup'; // Route for RegisterScreen

  // Helper method to generate the citizen report details path with ID
  static String reportDetailsPath(String reportId) => '$reportDetails/$reportId';

  // Helper method to generate the repair team report details path with ID
  static String repairTeamReportDetailsPath(String reportId) => '$repairTeamReportDetails/$reportId';
}

// Configure the router
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.auth, // Set AuthScreen as initial route
  debugLogDiagnostics: true, // Enable debug logging for router
  routes: [
    // Update Status Route
    GoRoute(
      path: AppRoutes.updateStatus,
      name: 'updateStatus',
      builder: (context, state) {
        final issue = state.extra as Map<String, dynamic>? ?? {};
        return UpdateStatusScreen(issue: issue);
      },
    ),
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
            // Pass the ID directly to the CitizenDetailScreen
            // The screen will use the ID to fetch the full issue details
            final reportData = {
              'id': reportId,
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
    // Repair Team Report Detail Route
    GoRoute(
      path: '${AppRoutes.repairTeamReportDetails}/:reportId',
      name: 'repairTeamReportDetails',
      builder: (context, state) {
        final issue = state.extra as shared_models.Issue?;
        if (issue == null) {
          // Handle missing issue data, perhaps navigate to an error page or back
          // For now, returning a placeholder or an error widget
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Issue data not provided.')),
          );
        }
        return RepairTeamDetailScreen(issue: issue);
      },
    ),
    // Auth Screen Route
    GoRoute(
      path: AppRoutes.auth,
      name: 'auth',
      builder: (context, state) => const AuthScreen(),
    ),
    // Login Screen Route
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    // Signup Screen Route
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => const RegisterScreen(),
    ),
    // Repair Team Dashboard Route
    GoRoute(
      path: AppRoutes.repairTeamDashboard,
      name: 'repairTeamDashboard',
      builder: (context, state) => const RepairTeamDashboard(),
      // If RepairTeamDetailScreen is a sub-route of RepairTeamDashboard, define it here
      // Otherwise, ensure its path is unique and correctly defined as a top-level route (as it is now)
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