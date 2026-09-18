import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/common/setting_switch.dart';
import '../../widgets/customer/profile_option.dart';
import '../chat/chat_inbox_screen.dart';
import 'photographer_edit_profile_screen.dart';
import 'portfolio_manager_screen.dart';

class PhotographerProfile extends StatelessWidget {
  final PypStore store;

  const PhotographerProfile({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final account = store.photographerAccount;
    if (account == null) {
      return const SizedBox.shrink();
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
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Messages',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatInboxScreen(
                      currentUserId: account.id.isNotEmpty
                          ? account.id
                          : store.user.email,
                    ),
                  ),
                );
              },
            ),
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
          ],
        ),
      ),
    );
  }
}
