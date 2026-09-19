import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/photographer_model.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/common/empty_state.dart';
import '../chat/chat_room_screen.dart';
import 'booking_screen.dart';

class PhotographerDetailsScreen extends StatefulWidget {
  final PhotographerModel photographer;
  final PypStore store;

  const PhotographerDetailsScreen({
    super.key,
    required this.photographer,
    required this.store,
  });

  @override
  State<PhotographerDetailsScreen> createState() =>
      _PhotographerDetailsScreenState();
}

class _PhotographerDetailsScreenState extends State<PhotographerDetailsScreen> {
  late final PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final isSaved = widget.store.isPhotographerSaved(widget.photographer);
        final identifier = widget.photographer.id.isNotEmpty
            ? widget.photographer.id
            : widget.photographer.name;

        final displayImages = widget.photographer.displayImages;

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
                tooltip: 'Chat with ${widget.photographer.name}',
                onPressed: () async {
                  final identifiers = widget.store.currentUserChatIdentifiers;
                  final currentUserId = identifiers.first;
                  final customerName = widget.store.user.name.isNotEmpty &&
                          widget.store.user.name != 'PYP User'
                      ? widget.store.user.name
                      : 'Customer';

                  final convoId = await widget.store.chatProvider.startConversationWithPhotographer(
                    customerId: currentUserId,
                    customerName: customerName,
                    photographer: widget.photographer,
                    customerAliases: identifiers,
                  );

                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(
                          conversationId: convoId,
                          recipientName: widget.photographer.name,
                          recipientId: widget.photographer.id.isNotEmpty
                              ? widget.photographer.id
                              : widget.photographer.name,
                          recipientPhoto: widget.photographer.profileImageUrl,
                          currentUserId: currentUserId,
                          chatProvider: widget.store.chatProvider,
                          store: widget.store,
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded),
              ),
              IconButton(
                onPressed: () {
                  widget.store.savePhotographer(identifier);
                },
                icon: Icon(
                  isSaved
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isSaved ? Colors.redAccent : Colors.white,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Swipeable Header Hero Image Carousel
                Container(
                  height: 290,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.mediaPlaceholder,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: displayImages.length,
                          onPageChanged: (idx) {
                            setState(() {
                              _currentImageIndex = idx;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              displayImages[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  size: 70,
                                  color: Colors.white24,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Gradient overlay for smooth contrast
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 70,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Page indicator dots
                      if (displayImages.length > 1)
                        Positioned(
                          bottom: 14,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  displayImages.length,
                                  (i) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                    width: _currentImageIndex == i ? 16 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _currentImageIndex == i
                                          ? Colors.white
                                          : Colors.white38,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.photographer.name,
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
                          const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFC107)),
                          const SizedBox(width: 5),
                          Text(
                            widget.photographer.rating,
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
                  widget.photographer.specialty,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '📍 ${widget.photographer.location}',
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
                  widget.photographer.bio,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Portfolio Gallery',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 115,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: displayImages.map(
                      (item) {
                        return GestureDetector(
                          onTap: () {
                            final idx = displayImages.indexOf(item);
                            if (idx != -1) {
                              _pageController.animateToPage(
                                idx,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: AppColors.cardElevated,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: displayImages.indexOf(item) == _currentImageIndex
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              item,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Starting price',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textFaint,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.photographer.price,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 30),
                if (!widget.photographer.acceptingBookings)
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
                              photographer: widget.photographer,
                              store: widget.store,
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
      },
    );
  }
}
