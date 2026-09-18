import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FloatingNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final bool photographerMode;
  final ValueChanged<int> onSelected;

  const FloatingNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.photographerMode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final customerItems = [
      (Icons.home_rounded, 'Home'),
      (Icons.search_rounded, 'Discover'),
      (Icons.calendar_month_rounded, 'Bookings'),
      (Icons.person_rounded, 'Profile'),
    ];

    final photographerItems = [
      (Icons.dashboard_rounded, 'Home'),
      (Icons.inbox_rounded, 'Requests'),
      (Icons.calendar_month_rounded, 'Calendar'),
      (Icons.person_rounded, 'Profile'),
    ];

    final items = photographerMode ? photographerItems : customerItems;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.85),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          items.length,
          (index) {
            final isSelected = selectedIndex == index;
            final item = items[index];

            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.$1,
                        size: 22,
                        color: isSelected ? Colors.black : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$2,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.black : Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
