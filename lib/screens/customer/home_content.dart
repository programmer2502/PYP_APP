import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/customer/category_card.dart';
import '../../widgets/customer/photographer_card.dart';
import '../../widgets/customer/search_box.dart';
import 'photographer_details_screen.dart';
import 'search_screen.dart';

class HomeContent extends StatelessWidget {
  final PypStore store;

  const HomeContent({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/pyp_logo.png',
                  width: 58,
                  height: 58,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.camera_alt_rounded,
                    size: 38,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.borderLight,
                    ),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Find the perfect',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w300,
                letterSpacing: -1,
              ),
            ),
            const Text(
              'photographer.',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 22),
            SearchBox(
              hint: 'Search photographers...',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchScreen(store: store),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'What are you shooting?',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 105,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  CategoryCard(
                    icon: Icons.favorite_rounded,
                    title: 'Weddings',
                  ),
                  CategoryCard(
                    icon: Icons.person_rounded,
                    title: 'Portraits',
                  ),
                  CategoryCard(
                    icon: Icons.business_center_rounded,
                    title: 'Business',
                  ),
                  CategoryCard(
                    icon: Icons.celebration_rounded,
                    title: 'Events',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Featured photographers',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchScreen(store: store),
                      ),
                    );
                  },
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (store.photographers.isNotEmpty)
              PhotographerCard(
                name: store.photographers[0].name,
                specialty: store.photographers[0].specialty,
                rating: store.photographers[0].rating,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotographerDetailsScreen(
                        photographer: store.photographers[0],
                        store: store,
                      ),
                    ),
                  );
                },
              )
            else
              const PhotographerCard(
                name: 'Featured Photographer',
                specialty: 'Portrait • Wedding • Events',
                rating: '4.9',
              ),
            const SizedBox(height: 16),
            if (store.photographers.length > 1)
              PhotographerCard(
                name: store.photographers[1].name,
                specialty: store.photographers[1].specialty,
                rating: store.photographers[1].rating,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotographerDetailsScreen(
                        photographer: store.photographers[1],
                        store: store,
                      ),
                    ),
                  );
                },
              )
            else
              const PhotographerCard(
                name: 'Creative Studio',
                specialty: 'Fashion • Portrait • Brand',
                rating: '4.8',
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
