import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_repair_hub/core/network/api_service_provider.dart';
import 'package:community_repair_hub/features/auth/presentation/providers/auth_provider.dart';
import '../../../../core/presentation/widgets/custom_app_bar.dart';

class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final apiService = ref.read(apiServiceProvider);
    final profileImageUrl = authState.user?.profileImageUrl;

    final String? fullImageUrl =
        profileImageUrl != null && profileImageUrl.isNotEmpty
            ? (profileImageUrl.startsWith('http')
                ? profileImageUrl
                : apiService.baseUrl + profileImageUrl)
            : null;
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
        if (fullImageUrl != null)
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 6.0, bottom: 6.0),
            child: InkWell(
              onTap: onProfilePressed,
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200], // Fallback background
                child: ClipOval(
                  child: Image.network(
                    fullImageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Failed to load profile image in AppBar: $error');
                      return const Icon(
                        Icons.person,
                        size: 22,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
            ),
          )
        // If no image URL, but profile action exists, show the icon button
        else if (onProfilePressed != null)
          IconButton(
            icon: const Icon(Icons.person, size: 28), // Slightly larger icon as it's the primary action
            onPressed: onProfilePressed,
            tooltip: 'Profile',
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}