import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/photographer_model.dart';
import '../../providers/pyp_store.dart';
import '../../screens/customer/photographer_details_screen.dart';

class PhotographerListCard extends StatelessWidget {
  final PhotographerModel photographer;
  final PypStore store;

  const PhotographerListCard({
    super.key,
    required this.photographer,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    final images = photographer.displayImages;
    final thumbnail = images.isNotEmpty ? images.first : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotographerDetailsScreen(
              photographer: photographer,
              store: store,
            ),
          ),
        );
      },
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.borderSubtle,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 102,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.mediaPlaceholder,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: thumbnail != null
                  ? Image.network(
                      thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white24,
                          size: 34,
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white24,
                        size: 34,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          photographer.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (photographer.verified) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          size: 15,
                          color: Color(0xFF38BDF8),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (photographer.isVideographer)
                              ? const Color(0xFF818CF8).withValues(alpha: 0.2)
                              : const Color(0xFFFBBF24).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          photographer.serviceType == 'Both'
                              ? 'Photo+Video'
                              : (photographer.isVideographer ? 'Video' : 'Photo'),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: (photographer.isVideographer)
                                ? const Color(0xFF818CF8)
                                : const Color(0xFFFBBF24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    photographer.specialty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textFaint,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFFFC107),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        photographer.rating,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          photographer.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    photographer.price,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                store.savePhotographer(photographer.id.isNotEmpty ? photographer.id : photographer.name);
              },
              icon: Icon(
                store.isPhotographerSaved(photographer)
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 20,
                color: store.isPhotographerSaved(photographer)
                    ? Colors.redAccent
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
