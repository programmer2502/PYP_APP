import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/photographer/quick_action_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/primary_button.dart';
import 'photographer_edit_profile_screen.dart';
import 'photographer_onboarding_screen.dart';
import 'portfolio_manager_screen.dart';

class PhotographerDashboard extends StatelessWidget {
  final PypStore store;

  const PhotographerDashboard({
    super.key,
    required this.store,
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
                    title: 'Welcome to Photographer Mode',
                    subtitle: 'Create your profile to start receiving customer shoot requests and bookings.',
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    title: 'Set up Photographer Profile',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PhotographerOnboardingScreen(
                            store: store,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: store.switchToCustomer,
                    child: const Text(
                      'Return to Customer Home',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final requests = store.photographerRequests;
        final pending =
            requests.where((booking) => booking.status == 'Pending').length;
        final accepted =
            requests.where((booking) => booking.status == 'Accepted').length;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Welcome, ${account.name}',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: account.acceptingBookings
                        ? AppColors.card
                        : AppColors.badgeInactive,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.borderLight,
                    ),
                  ),
                  child: Text(
                    account.acceptingBookings ? 'Available' : 'Unavailable',
                    style: TextStyle(
                      fontSize: 11,
                      color: account.acceptingBookings
                          ? Colors.white
                          : AppColors.textTertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.borderSubtle,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking requests',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$pending',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Pending requests',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textFaint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Accepted',
                    value: '$accepted',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Portfolio',
                    value: '${account.portfolio.length}',
                    icon: Icons.photo_library_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Quick actions',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            QuickActionCard(
              icon: Icons.edit_outlined,
              title: 'Edit profile',
              subtitle: 'Update your public photographer profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PhotographerEditProfile(
                      store: store,
                    ),
                  ),
                );
              },
            ),
            QuickActionCard(
              icon: Icons.photo_library_outlined,
              title: 'Manage portfolio',
              subtitle: 'Add or remove portfolio entries',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PortfolioManager(store: store),
                  ),
                );
              },
            ),
            QuickActionCard(
              icon: Icons.event_available_outlined,
              title: 'Availability',
              subtitle: account.acceptingBookings
                  ? 'You are accepting bookings'
                  : 'You are currently unavailable',
              onTap: () {
                store.setAcceptingBookings(!account.acceptingBookings);
              },
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}
