import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/photographer/photographer_request_card.dart';

import '../chat/chat_room_screen.dart';

class PhotographerRequests extends StatelessWidget {
  final PypStore store;

  const PhotographerRequests({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final requests = store.photographerRequests;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Requests',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage customer booking requests.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 30),
                if (requests.isEmpty)
                  const EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'No requests yet',
                    subtitle: 'New customer booking requests will appear here.',
                  ),
                ...requests.reversed.map(
                  (booking) => PhotographerRequestCard(
                    booking: booking,
                    onAccept: booking.status == 'Pending'
                        ? () {
                            store.updateBookingStatus(booking, 'Accepted');
                          }
                        : null,
                    onReject: booking.status == 'Pending'
                        ? () {
                            store.updateBookingStatus(booking, 'Rejected');
                          }
                        : null,
                    onMessage: () {
                      final identifiers = store.currentUserChatIdentifiers;
                      final currentUserId = identifiers.first;
                      final clientAlias = booking.customerId.isNotEmpty
                          ? booking.customerId
                          : (booking.customerEmail.isNotEmpty
                              ? booking.customerEmail
                              : 'customer');
                      final photoId = booking.photographerId.isNotEmpty
                          ? booking.photographerId
                          : booking.photographerName;

                      final safeCust = clientAlias.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
                      final safePhoto = photoId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
                      final convoId = 'convo_${safeCust}_$safePhoto';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatRoomScreen(
                            conversationId: convoId,
                            recipientName: booking.customerName.isNotEmpty
                                ? booking.customerName
                                : (booking.customerEmail.isNotEmpty
                                    ? booking.customerEmail
                                    : 'Client'),
                            recipientId: clientAlias,
                            currentUserId: currentUserId,
                            chatProvider: store.chatProvider,
                            store: store,
                          ),
                        ),
                      );
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
}

