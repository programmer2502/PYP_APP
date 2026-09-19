import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/common/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  final PypStore store;

  const NotificationsScreen({
    super.key,
    required this.store,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final allNotifications = widget.store.notifications;

        final filteredNotifications = allNotifications.where((n) {
          if (_selectedFilter == 'Bookings') {
            return n.type == AppNotificationType.bookingRequest ||
                n.type == AppNotificationType.bookingAccepted ||
                n.type == AppNotificationType.bookingRejected ||
                n.type == AppNotificationType.bookingCancelled;
          }
          if (_selectedFilter == 'Messages') {
            return n.type == AppNotificationType.chatMessage;
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Stay updated with bookings & chats',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (allNotifications.any((n) => !n.isRead))
                        TextButton(
                          onPressed: () {
                            widget.store.markAllNotificationsRead();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text(
                            'Mark all read',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                ),

                // Filter Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: ['All', 'Bookings', 'Messages'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.black : AppColors.textSecondary,
                          ),
                          backgroundColor: AppColors.card,
                          selectedColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? Colors.white : AppColors.borderLight,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // Notifications List
                Expanded(
                  child: filteredNotifications.isEmpty
                      ? const EmptyState(
                          icon: Icons.notifications_off_outlined,
                          title: 'No notifications',
                          subtitle: 'You are all caught up! Updates will appear here.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                          itemCount: filteredNotifications.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final notification = filteredNotifications[index];
                            return _buildNotificationCard(notification);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(AppNotificationModel notification) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (notification.type) {
      case AppNotificationType.bookingRequest:
        icon = Icons.calendar_today_rounded;
        iconColor = const Color(0xFFFBBF24);
        iconBg = const Color(0xFF78350F).withValues(alpha: 0.3);
        break;
      case AppNotificationType.bookingAccepted:
        icon = Icons.check_circle_rounded;
        iconColor = const Color(0xFF4ADE80);
        iconBg = const Color(0xFF14532D).withValues(alpha: 0.3);
        break;
      case AppNotificationType.bookingRejected:
        icon = Icons.cancel_rounded;
        iconColor = const Color(0xFFF87171);
        iconBg = const Color(0xFF7F1D1D).withValues(alpha: 0.3);
        break;
      case AppNotificationType.bookingCancelled:
        icon = Icons.event_busy_rounded;
        iconColor = const Color(0xFFFB923C);
        iconBg = const Color(0xFF7C2D12).withValues(alpha: 0.3);
        break;
      case AppNotificationType.chatMessage:
        icon = Icons.chat_bubble_rounded;
        iconColor = const Color(0xFF60A5FA);
        iconBg = const Color(0xFF1E3A8A).withValues(alpha: 0.3);
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = Colors.white70;
        iconBg = AppColors.cardElevated;
    }

    final timeStr = _formatTimestamp(notification.createdAt);

    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          widget.store.markNotificationRead(notification.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.surface : AppColors.cardElevated,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: notification.isRead
                ? AppColors.borderSubtle
                : iconColor.withValues(alpha: 0.35),
            width: notification.isRead ? 1 : 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iconColor.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            color: iconColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: notification.isRead
                          ? AppColors.textTertiary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (timeStr.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
