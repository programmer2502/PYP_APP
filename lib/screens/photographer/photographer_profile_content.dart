import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/setting_switch.dart';
import '../../widgets/customer/profile_option.dart';
import 'photographer_edit_profile_screen.dart';
import 'photographer_onboarding_screen.dart';
import 'portfolio_manager_screen.dart';
import '../shared/notifications_screen.dart';

class PhotographerProfile extends StatelessWidget {
  final PypStore store;
  final AuthProvider? authProvider;

  const PhotographerProfile({
    super.key,
    required this.store,
    this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final account = store.photographerAccount;
        if (account == null) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const EmptyState(
                    icon: Icons.camera_alt_outlined,
                    title: 'Photographer Profile Needed',
                    subtitle: 'Set up your photographer profile to begin receiving client bookings.',
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    title: 'Create Profile',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PhotographerOnboardingScreen(
                            store: store,
                            authProvider: authProvider,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: store.switchToCustomer,
                    child: const Text(
                      'Switch to Customer Mode',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My profile',
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
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.borderLight,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 40,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        account.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        account.specialty,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textFaint,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ProfileOption(
                  icon: Icons.edit_outlined,
                  title: 'Edit public profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhotographerEditProfile(store: store),
                      ),
                    );
                  },
                ),
                ProfileOption(
                  icon: Icons.photo_library_outlined,
                  title: 'Portfolio',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PortfolioManager(store: store),
                      ),
                    );
                  },
                ),
                ProfileOption(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotificationsScreen(store: store),
                      ),
                    );
                  },
                ),
                ProfileOption(
                  icon: Icons.swap_horiz_rounded,
                  title: 'Switch to customer',
                  onTap: store.switchToCustomer,
                ),
                ProfileOption(
                  icon: Icons.visibility_outlined,
                  title: 'View customer profile',
                  onTap: store.switchToCustomer,
                ),
                const SizedBox(height: 20),
                SettingSwitch(
                  title: 'Accept new bookings',
                  subtitle: 'Show your profile as available',
                  value: account.acceptingBookings,
                  onChanged: store.setAcceptingBookings,
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
                            'Are you sure you want to sign out?',
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
                                store.resetOnSignOut();
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
      },
    );
  }
}
