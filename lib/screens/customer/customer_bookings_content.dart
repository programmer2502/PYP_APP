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
            Text('Initiating secure Razorpay checkout...'),
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
        onSuccess: (response) async {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent),
                  ),
                  SizedBox(width: 12),
                  Text('Verifying payment signature on backend...'),
                ],
              ),
              duration: Duration(seconds: 3),
            ),
          );

          try {
            final paymentId = response.paymentId ?? '';
            final returnedOrderId = response.orderId ?? orderId;
            final signature = response.signature ?? 'sig_${DateTime.now().millisecondsSinceEpoch}';

            // 1. Mandatory Backend Verification Step
            final verificationResult = await _paymentService.verifyPaymentWithBackend(
              bookingId: booking.id,
              orderId: returnedOrderId,
              paymentId: paymentId,
              signature: signature,
            );

            final conversationId = verificationResult['conversationId']?.toString() ??
                'convo_bk_${booking.id.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')}';

            // 2. Update Firestore and Store after verified confirmation
            await widget.store.updateBookingPayment(
              booking,
              paymentStatus: PaymentStatus.paid,
              paymentId: paymentId,
              orderId: returnedOrderId,
              chatEnabled: true,
              conversationId: conversationId,
              signature: signature,
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Payment Verified! Chat unlocked with ${booking.photographerName}.',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.card,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          } catch (verifyError) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('Payment verification failed: $verifyError. Chat remains locked.'),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        },
        onError: (response) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment Cancelled / Failed: ${response.message ?? "Checkout closed."}'),
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
                  'Your photography bookings & chat status.',
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
                    final isPaid = booking.paymentStatus == PaymentStatus.paid;
                    final isChatEnabled = isPaid && booking.chatEnabled;

                    return BookingCard(
                      booking: booking,
                      onPay: (isAccepted && !isPaid)
                          ? () => _handlePayForBooking(booking)
                          : null,
                      onMessage: isChatEnabled
                          ? () async {
                              final identifiers = widget.store.currentUserChatIdentifiers;
                              final currentUserId = identifiers.first;
                              final userName = widget.store.user.name.isNotEmpty &&
                                      widget.store.user.name != 'PYP User'
                                  ? widget.store.user.name
                                  : 'Client';

                              final convoId = await widget.store.chatProvider.openBookingConversation(
                                booking: booking,
                                currentUserId: currentUserId,
                                currentUserName: userName,
                                userAliases: identifiers,
                              );

                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatRoomScreen(
                                      conversationId: convoId,
                                      bookingId: booking.id,
                                      recipientName: booking.photographerName,
                                      recipientId: booking.photographerId,
                                      currentUserId: currentUserId,
                                      chatProvider: widget.store.chatProvider,
                                      store: widget.store,
                                    ),
                                  ),
                                );
                              }
                            }
                          : null,
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
