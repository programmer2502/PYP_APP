import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/booking_model.dart';
import '../../providers/pyp_store.dart';
import '../../services/payment_service.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/customer/booking_card.dart';
import '../chat/chat_room_screen.dart';

class BookingsContent extends StatefulWidget {
  final PypStore store;

  const BookingsContent({
    super.key,
    required this.store,
  });

  @override
  State<BookingsContent> createState() => _BookingsContentState();
}

class _BookingsContentState extends State<BookingsContent> {
  final PaymentService _paymentService = RazorpayPaymentServiceImpl();

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _handlePayForBooking(BookingModel booking) async {
    final amount = booking.amount > 0 ? booking.amount : 300.0;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Initiating Razorpay checkout...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final orderId = await _paymentService.createRazorpayOrder(
        bookingId: booking.id,
        amount: amount,
      );

      final userEmail = widget.store.user.email;
      final userPhone = widget.store.user.phone;
      final userName = widget.store.user.name.isNotEmpty && widget.store.user.name != 'PYP User'
          ? widget.store.user.name
          : 'PYP Client';

      _paymentService.openCheckout(
        orderId: orderId,
        amount: amount,
        description: 'PYP Booking - ${booking.photographerName} (${booking.category})',
        userEmail: userEmail,
        userPhone: userPhone,
        userName: userName,
        onSuccess: (response) {
          if (mounted) {
            widget.store.updateBookingPayment(
              booking,
              paymentStatus: PaymentStatus.paid,
              paymentId: response.paymentId,
              orderId: response.orderId ?? orderId,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Payment Successful! ID: ${response.paymentId ?? ""}'),
                    ),
                  ],
                ),
                backgroundColor: AppColors.card,
              ),
            );
          }
        },
        onError: (response) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment Failed: ${response.message ?? "Cancelled"}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        onExternalWallet: (response) {},
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not start payment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final bookings = widget.store.customerBookings;

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
                  (booking) {
                    final isAccepted = booking.status.toLowerCase() == 'accepted' ||
                        booking.status.toLowerCase() == 'confirmed';
                    final isUnpaid = booking.paymentStatus != PaymentStatus.paid;

                    return BookingCard(
                      booking: booking,
                      onPay: (isAccepted && isUnpaid)
                          ? () => _handlePayForBooking(booking)
                          : null,
                    onMessage: () async {
                      final identifiers = widget.store.currentUserChatIdentifiers;
                      final currentUserId = identifiers.first;
                      final photoId = booking.photographerId.isNotEmpty
                          ? booking.photographerId
                          : booking.photographerName;

                      final safeCust = currentUserId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
                      final safePhoto = photoId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
                      final convoId = 'convo_${safeCust}_$safePhoto';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatRoomScreen(
                            conversationId: convoId,
                            recipientName: booking.photographerName,
                            recipientId: booking.photographerId,
                            currentUserId: currentUserId,
                            chatProvider: widget.store.chatProvider,
                            store: widget.store,
                          ),
                        ),
                      );
                    },
                    onCancel: booking.status == 'Pending'
                        ? () {
                            widget.store.updateBookingStatus(booking, 'Cancelled');
                          }
                        : null,
                  );
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
