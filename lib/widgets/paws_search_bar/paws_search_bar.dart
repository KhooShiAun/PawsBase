import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';

class PawsSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const PawsSearchBar({
    super.key,
    this.hintText = 'Search',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PawsBaseTokens.surfaceDim.withValues(alpha: 0.5), // Light beige/gray background
        borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadius),
        border: Border.all(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: PawsBaseTokens.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 16,
                color: PawsBaseTokens.onSurface,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  color: PawsBaseTokens.onSurfaceVariant,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
