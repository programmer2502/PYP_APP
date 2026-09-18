import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/customer/discover_chip.dart';
import '../../widgets/customer/photographer_list_card.dart';

class DiscoverContent extends StatefulWidget {
  final PypStore store;

  const DiscoverContent({
    super.key,
    required this.store,
  });

  @override
  State<DiscoverContent> createState() => _DiscoverContentState();
}

class _DiscoverContentState extends State<DiscoverContent> {
  String selectedCategory = 'All';
  String search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.store.photographers.where((photo) {
      final categoryMatches = selectedCategory == 'All' ||
          photo.category == selectedCategory;

      final text =
          '${photo.name} ${photo.specialty} ${photo.location}'.toLowerCase();

      return categoryMatches && text.contains(search.toLowerCase());
    }).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Discover',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Find photographers that match your style.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search photographers...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.borderLight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Explore',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final category in [
                    'All',
                    'Weddings',
                    'Portraits',
                    'Events',
                    'Business',
                  ])
                    DiscoverChip(
                      title: category,
                      selected: selectedCategory == category,
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Photographers',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${filtered.length} found',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textFaint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'No photographers found',
                subtitle: 'Try another search or category.',
              ),
            ...filtered.map(
              (photo) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: PhotographerListCard(
                  photographer: photo,
                  store: widget.store,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
