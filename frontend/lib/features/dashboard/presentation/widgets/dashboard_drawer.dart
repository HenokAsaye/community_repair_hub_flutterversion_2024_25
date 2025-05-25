import 'package:flutter/material.dart';

class DashboardDrawer extends StatelessWidget {
  final String? profileImage;
  final bool isRepairTeam;
  final String userName;
  final String userEmail;

  const DashboardDrawer({
    Key? key,
    this.profileImage,
    this.isRepairTeam = false,
    this.userName = 'User Name',
    this.userEmail = 'user@example.com',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header with user info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            color: const Color(0xFF0EAF16), // Green color from the image
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile image
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: profileImage != null
                        ? ClipOval(
                            child: Image.network(
                              profileImage!,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey[700],
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // User name
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // User email
                Text(
                  userEmail,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(
                      context,
                      isRepairTeam ? '/repair_team_dashboard' : '/citizen_dashboard',
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.report_problem,
                  title: 'Report a Problem',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/report_problem');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.history,
                  title: 'Report History',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/report_history');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/help');
                  },
                ),
                const Divider(height: 1, thickness: 1),
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () {
                    // Handle logout
                    Navigator.pop(context);
                    // Add your logout logic here
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
    );
  }
}
