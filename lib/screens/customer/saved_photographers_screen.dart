import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/customer/photographer_list_card.dart';

class SavedPhotographersScreen extends StatelessWidget {
  final PypStore store;

  const SavedPhotographersScreen({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final saved = store.photographers
            .where((photo) =>
                store.savedPhotographers.contains(photo.name) ||
                store.savedPhotographers.contains(photo.id))
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            title: const Text(
              'Saved photographers',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: saved.isEmpty
              ? const EmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'Nothing saved yet',
                  subtitle: 'Save photographers you want to come back to.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  children: saved
                      .map(
                        (photo) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PhotographerListCard(
                            photographer: photo,
                            store: store,
                          ),
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}
