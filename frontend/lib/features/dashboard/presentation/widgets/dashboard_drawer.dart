import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_repair_hub/config/routes/app_router.dart';
import 'package:community_repair_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:community_repair_hub/features/reports/presentation/screens/report_form_screen.dart';
import 'package:community_repair_hub/core/network/api_service_provider.dart';

class DashboardDrawer extends ConsumerWidget {
  final String userRole;

  const DashboardDrawer({Key? key, required this.userRole}) : super(key: key);

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final homeRoute =
        userRole == 'repair_team' ? AppRoutes.repairTeamDashboard : AppRoutes.home;

    return Drawer(
      child: Container(
        color: const Color(0xFF66BB6A), // A pleasant green color
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _buildDrawerHeader(
              context,
              ref,
              authState.user?.name ?? 'Anonymous',
              authState.user?.email ?? 'no-email@provided.com',
              authState.user?.profileImageUrl,
            ),
            const SizedBox(height: 20),
            _buildMenuItem(context, Icons.home, 'Home', () {
              Navigator.pop(context);
              context.go(homeRoute);
            }),
            if (userRole == 'citizen')
              _buildMenuItem(context, Icons.report, 'Report a Problem', () {
                Navigator.pop(context); // Close the drawer first
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReportFormScreen()),
                );
              }),
            const Divider(color: Colors.white54),
            _buildMenuItem(context, Icons.logout, 'Logout', () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.auth);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(
    BuildContext context,
    WidgetRef ref,
    String userName,
    String userEmail,
    String? profileImageUrl,
  ) {
    final apiService = ref.read(apiServiceProvider);
    final fullImageUrl = profileImageUrl != null && profileImageUrl.isNotEmpty
        ? (profileImageUrl.startsWith('http')
            ? profileImageUrl
            : apiService.baseUrl + profileImageUrl)
        : null;

    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF388E3C), // A darker green for the header
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: fullImageUrl == null
                ? const Icon(Icons.person, size: 50, color: Color(0xFF388E3C))
                : ClipOval(
                    child: Image.network(
                      fullImageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, size: 50, color: Color(0xFF388E3C));
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            userEmail,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
