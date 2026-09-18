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
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white24,
                size: 34,
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
                      if (photographer.verified)
                        const Icon(
                          Icons.verified_rounded,
                          size: 15,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    photographer.specialty,
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
                      Text(
                        photographer.location,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
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
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                store.savePhotographer(photographer.name);
              },
              icon: Icon(
                store.isSaved(photographer.name)
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 20,
                color: store.isSaved(photographer.name)
                    ? Colors.white
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
