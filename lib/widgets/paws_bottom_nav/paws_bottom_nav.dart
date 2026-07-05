import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';

class PawsBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PawsBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceVariant : PawsBaseTokens.surface,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : PawsBaseTokens.primaryDark.withOpacity(0.04),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 24, left: 8, right: 8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(context, 0, Icons.home_outlined, Icons.home, 'Home'),
            _buildNavItem(context, 1, Icons.pets, Icons.pets, 'Pets'),
            _buildNavItem(context, 2, Icons.monitor_heart, Icons.monitor_heart, 'Health'),
            _buildNavItem(context, 3, Icons.fitness_center, Icons.fitness_center, 'Training'),
            _buildNavItem(context, 4, Icons.settings_outlined, Icons.settings, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Active container color: sage green
    final activeBgColor = isDark 
        ? colorScheme.primaryContainer 
        : PawsBaseTokens.primaryContainer.withOpacity(0.7);
    final activeTextColor = isDark 
        ? colorScheme.onPrimaryContainer 
        : PawsBaseTokens.primaryDark;

    // Inactive text/icon color: neutral gray-green
    final inactiveColor = isDark 
        ? colorScheme.onSurfaceVariant.withOpacity(0.6) 
        : PawsBaseTokens.neutral;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? activeTextColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? activeTextColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
