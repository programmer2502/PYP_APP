import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/pyp_store.dart';
import '../../widgets/customer/photographer_list_card.dart';

class SearchScreen extends StatefulWidget {
  final PypStore store;

  const SearchScreen({
    super.key,
    required this.store,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controller = TextEditingController();
  String query = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.store.photographers.where((photographer) {
      final value =
          '${photographer.name} ${photographer.category} ${photographer.specialty} ${photographer.location}'
              .toLowerCase();
      return value.contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Photographer, style or location',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            '${results.length} photographers found',
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          ...results.map(
            (photographer) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PhotographerListCard(
                photographer: photographer,
                store: widget.store,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
