import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class DiscoverChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const DiscoverChip({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? Colors.white : AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.borderLight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.black : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
