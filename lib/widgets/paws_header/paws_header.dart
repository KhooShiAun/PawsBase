import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';

class PawsHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const PawsHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: colorScheme.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ]
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
