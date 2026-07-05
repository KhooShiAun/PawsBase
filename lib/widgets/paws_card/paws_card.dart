import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';

class PawsCard extends StatelessWidget {
  final String name;
  final String species;
  final String? breed;
  final String? imageUrl;
  final VoidCallback? onTap;

  const PawsCard({
    super.key,
    required this.name,
    required this.species,
    this.breed,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Background color: pure white in light mode, dark surface container in dark mode.
    final backgroundColor = isDark 
        ? colorScheme.surfaceContainerHighest 
        : PawsBaseTokens.surfaceBright;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(28.0),
          border: Border.all(
            color: isDark 
                ? colorScheme.outline.withValues(alpha: 0.2) 
                : colorScheme.onSurface.withValues(alpha: 0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withValues(alpha: 0.2) 
                  : colorScheme.onSurface.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark 
                      ? colorScheme.outline.withValues(alpha: 0.2) 
                      : colorScheme.onSurface.withValues(alpha: 0.04),
                  width: 1,
                ),
              ),
              child: CircleAvatar(
                radius: 56,
                backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.2),
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                child: imageUrl == null
                    ? Icon(Icons.pets, size: 40, color: colorScheme.primary)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              breed ?? species,
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 14,
                color: isDark ? colorScheme.onSurfaceVariant : PawsBaseTokens.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
