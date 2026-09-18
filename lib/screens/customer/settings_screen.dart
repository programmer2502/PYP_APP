import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/common/setting_switch.dart';
import '../../widgets/customer/profile_option.dart';

class SettingsScreen extends StatelessWidget {
  final PypStore store;

  const SettingsScreen({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          SettingSwitch(
            title: 'Push notifications',
            subtitle: 'Booking and account updates',
            value: store.notificationsEnabled,
            onChanged: store.setNotificationsEnabled,
          ),
          SettingSwitch(
            title: 'Email updates',
            subtitle: 'Important updates and reminders',
            value: store.emailUpdates,
            onChanged: store.setEmailUpdates,
          ),
          const SizedBox(height: 20),
          const ProfileOptionStatic(
            icon: Icons.help_outline_rounded,
            title: 'Help & support',
          ),
          const ProfileOptionStatic(
            icon: Icons.description_outlined,
            title: 'Terms & conditions',
          ),
          const ProfileOptionStatic(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy policy',
          ),
        ],
      ),
    );
  }
}
