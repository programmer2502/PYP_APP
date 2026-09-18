import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/customer/profile_option.dart';
import '../chat/chat_inbox_screen.dart';
import '../photographer/photographer_onboarding_screen.dart';
import 'personal_details_screen.dart';
import 'saved_photographers_screen.dart';
import 'settings_screen.dart';

class ProfileContent extends StatelessWidget {
  final PypStore store;
  final AuthProvider? authProvider;

  const ProfileContent({
    super.key,
    required this.store,
    this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderLight,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 38,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    store.user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    store.user.email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textFaint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            ProfileOption(
              icon: Icons.person_outline_rounded,
              title: 'Personal details',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PersonalDetailsScreen(
                      store: store,
                      authProvider: authProvider,
                    ),
                  ),
                );
              },
            ),
            ProfileOption(
              icon: Icons.favorite_border_rounded,
              title: 'Saved photographers',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SavedPhotographersScreen(store: store),
                  ),
                );
              },
            ),
            ProfileOption(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Messages',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatInboxScreen(
                      currentUserId: store.user.email.isNotEmpty
                          ? store.user.email
                          : 'customer_1',
                    ),
                  ),
                );
              },
            ),
            ProfileOption(
              icon: Icons.camera_alt_outlined,
              title: store.photographerAccount == null
                  ? 'Create photographer account'
                  : 'Photographer mode',
              onTap: () {
                if (store.photographerAccount == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotographerOnboardingScreen(
                        store: store,
                      ),
                    ),
                  );
                } else {
                  store.switchToPhotographer();
                }
              },
            ),
            ProfileOption(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(store: store),
                  ),
                );
              },
            ),
            ProfileOption(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(store: store),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.card,
                      title: const Text('Sign out?'),
                      content: const Text(
                        'This prototype keeps account data locally while the app is running.',
                        style: TextStyle(color: Colors.white60),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            if (authProvider != null) {
                              await authProvider!.logout();
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Signed out.'),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Sign out',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
