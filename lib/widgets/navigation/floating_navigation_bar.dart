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
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.search_rounded, Icons.search_rounded, 'Discover'),
      (Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Bookings'),
      (Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded, 'Chat'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];

    final photographerItems = [
      (Icons.dashboard_rounded, Icons.dashboard_outlined, 'Home'),
      (Icons.inbox_rounded, Icons.inbox_outlined, 'Requests'),
      (Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Calendar'),
      (Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded, 'Chat'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];

    final items = photographerMode ? photographerItems : customerItems;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.85),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 10),
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
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? item.$1 : item.$2,
                        size: 21,
                        color: isSelected ? Colors.black : Colors.white60,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.$3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
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
