import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/custom_app_bar.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isRepairTeam;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onProfilePressed;

  const DashboardAppBar({
    Key? key,
    required this.title,
    this.isRepairTeam = false,
    this.onMenuPressed,
    this.onProfilePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      backgroundColor: const Color.fromARGB(255, 14, 175, 22),
      showBackButton: false, // Remove back button
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onMenuPressed ?? () {
          // Default behavior: open the drawer if no custom onMenuPressed is provided
          if (Scaffold.of(context).hasDrawer) {
            Scaffold.of(context).openDrawer();
          }
        },
        tooltip: 'Menu',
      ),
      actions: [
        // Only show profile button if callback is provided
        if (onProfilePressed != null)
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: onProfilePressed,
            tooltip: 'Profile',
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 