import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/customer/booking_card.dart';

class BookingsContent extends StatelessWidget {
  final PypStore store;

  const BookingsContent({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final bookings = store.customerBookings;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bookings',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your photography bookings.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 30),
                if (bookings.isEmpty)
                  const EmptyState(
                    icon: Icons.calendar_month_outlined,
                    title: 'No bookings yet',
                    subtitle: 'Your upcoming and past bookings will appear here.',
                  ),
                ...bookings.reversed.map(
                  (booking) => BookingCard(
                    booking: booking,
                    onCancel: booking.status == 'Pending'
                        ? () {
                            store.updateBookingStatus(booking, 'Cancelled');
                          }
                        : null,
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

