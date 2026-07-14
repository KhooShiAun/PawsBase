import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : PawsBaseTokens.surface,
      appBar: AppBar(
        backgroundColor: isDark ? colorScheme.surface : PawsBaseTokens.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About PawsBase',
          style: TextStyle(
            fontFamily: PawsBaseTokens.fontFamily,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Circular Brand Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: PawsBaseTokens.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: PawsBaseTokens.primary,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.pets_rounded,
                    color: PawsBaseTokens.primaryDark,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),

                // App Title & Version
                Text(
                  'PawsBase',
                  style: TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? PawsBaseTokens.primary : PawsBaseTokens.primaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Version 0.1.0 (Build 1)',
                  style: TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 14,
                    color: PawsBaseTokens.neutral,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),

                // Mission Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Our Mission',
                        style: TextStyle(
                          fontFamily: PawsBaseTokens.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Empowering pet parents to keep their furry friends healthy, happy, and trained, all in one centralized ecosystem. Track pet profiles, veterinary health logs, vaccination histories, and training progress with ease.',
                        style: TextStyle(
                          fontFamily: PawsBaseTokens.fontFamily,
                          fontSize: 14,
                          color: PawsBaseTokens.neutral,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Links section
                _buildLinkRow(
                  isDark: isDark,
                  colorScheme: colorScheme,
                  icon: Icons.public_rounded,
                  title: 'Visit our Website',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Navigating to https://pawsbase.com...')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildLinkRow(
                  isDark: isDark,
                  colorScheme: colorScheme,
                  icon: Icons.code_rounded,
                  title: 'Open Source Repository',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Navigating to GitHub repository...')),
                    );
                  },
                ),
                const SizedBox(height: 48),

                // Copy details
                Text(
                  '© 2026 PawsBase Team. All rights reserved.',
                  style: TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 12,
                    color: PawsBaseTokens.neutral.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkRow({
    required bool isDark,
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: PawsBaseTokens.primaryDark, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
