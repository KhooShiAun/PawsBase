import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';

class PawsBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PawsBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: PawsBaseTokens.surfaceDim.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadiusPill),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home_filled, Icons.home_outlined),
          _buildNavItem(1, Icons.search, Icons.search),
          _buildNavItem(2, Icons.person, Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? PawsBaseTokens.primaryDark : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? activeIcon : inactiveIcon,
          color: isSelected ? Colors.white : PawsBaseTokens.onSurfaceVariant,
          size: 24,
        ),
      ),
    );
  }
}
