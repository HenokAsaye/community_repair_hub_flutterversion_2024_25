import 'package:flutter/material.dart';
import 'features/reports/presentation/screens/assigned_issues_screen.dart';
// import 'package:community_repair_hub/features/reports/presentation/screens/report_form_screen.dart';
// import 'package:community_repair_hub/features/reports/presentation/screens/update_status_screen.dart';
// import 'features/dashboard/presentation/screens/citizen_dashboard_screen.dart';
// import 'features/dashboard/presentation/screens/Detail/Repair_Team_Detail.dart';
// import './features/dashboard/presentation/screens/team_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const AssignedIssuesScreen(),
    );
  }
}

