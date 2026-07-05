import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';

class PawsSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const PawsSearchBar({
    super.key,
    this.hintText = 'Search',
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : PawsBaseTokens.surfaceDim,
        borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadiusPill),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            color: isDark ? colorScheme.onSurfaceVariant : PawsBaseTokens.neutral,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  color: isDark ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6) : PawsBaseTokens.onSurfaceVariant,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
