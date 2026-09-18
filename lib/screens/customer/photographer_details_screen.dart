import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/photographer_model.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/common/empty_state.dart';
import '../chat/chat_room_screen.dart';
import 'booking_screen.dart';

class PhotographerDetailsScreen extends StatelessWidget {
  final PhotographerModel photographer;
  final PypStore store;

  const PhotographerDetailsScreen({
    super.key,
    required this.photographer,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Photographer',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatRoomScreen(
                    conversationId:
                        'convo_${store.user.email}_${photographer.id}',
                    recipientName: photographer.name,
                    currentUserId: store.user.email.isNotEmpty
                        ? store.user.email
                        : 'customer_1',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded),
          ),
          IconButton(
            onPressed: () {
              store.savePhotographer(photographer.name);
            },
            icon: Icon(
              store.isSaved(photographer.name)
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.mediaPlaceholder,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 70,
                color: Colors.white24,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    photographer.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        photographer.rating,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              photographer.specialty,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '📍 ${photographer.location}',
              style: const TextStyle(
                color: AppColors.textFaint,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'About',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              photographer.bio,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 26),
            if (photographer.portfolio.isNotEmpty) ...[
              const Text(
                'Portfolio',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 105,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: photographer.portfolio
                      .map(
                        (item) {
                          final isUrl = item.startsWith('http://') ||
                              item.startsWith('https://');
                          return Container(
                            width: 130,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: AppColors.cardElevated,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: isUrl
                                ? Image.network(
                                    item,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.image_outlined,
                                          color: AppColors.textMuted,
                                        ),
                                        SizedBox(height: 7),
                                        Text(
                                          'Portfolio Image',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white60,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.image_outlined,
                                        color: AppColors.textMuted,
                                      ),
                                      const SizedBox(height: 7),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Text(
                                          item,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white60,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          );
                        },
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 28),
            ],
            const Text(
              'Starting price',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textFaint,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              photographer.price,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 30),
            if (!photographer.acceptingBookings)
              const EmptyState(
                icon: Icons.event_busy_rounded,
                title: 'Currently unavailable',
                subtitle: 'This photographer is not accepting bookings.',
              )
            else
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(
                          photographer: photographer,
                          store: store,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Book this photographer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
