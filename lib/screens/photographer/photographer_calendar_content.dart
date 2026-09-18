import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/customer/booking_card.dart';

class PhotographerCalendar extends StatefulWidget {
  final PypStore store;

  const PhotographerCalendar({
    super.key,
    required this.store,
  });

  @override
  State<PhotographerCalendar> createState() => _PhotographerCalendarState();
}

class _PhotographerCalendarState extends State<PhotographerCalendar> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final allBookings = widget.store.photographerRequests
            .where((booking) => booking.status != 'Cancelled')
            .toList();

        final filteredBookings = allBookings.where((booking) {
          if (_selectedFilter == 'Accepted') {
            return booking.status == 'Accepted';
          }
          if (_selectedFilter == 'Pending') {
            return booking.status == 'Pending';
          }
          return true;
        }).toList();

        final isAccepting =
            widget.store.photographerAccount?.acceptingBookings ?? true;

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
                      children: const [
                        Text(
                          'Calendar',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Your schedule & shoot availability.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.borderSubtle,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isAccepting
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isAccepting
                              ? Icons.event_available_rounded
                              : Icons.event_busy_rounded,
                          color: isAccepting
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAccepting
                                  ? 'Accepting New Bookings'
                                  : 'Schedule Paused',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isAccepting
                                  ? 'Clients can request date slots'
                                  : 'Slots are temporarily hidden',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: isAccepting,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppColors.success,
                        onChanged: (val) {
                          widget.store.setAcceptingBookings(val);
                        },
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildFilterChip('All', allBookings.length),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Accepted',
                      allBookings
                          .where((b) => b.status == 'Accepted')
                          .length,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Pending',
                      allBookings
                          .where((b) => b.status == 'Pending')
                          .length,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (filteredBookings.isEmpty)
                  const EmptyState(
                    icon: Icons.calendar_month_outlined,
                    title: 'Calendar is clear',
                    subtitle: 'Confirmed shoots will appear here.',
                  ),
                ...filteredBookings.map(
                  (booking) => BookingCard(
                    booking: booking,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.black : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.black12
                    : AppColors.cardElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.black : Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
