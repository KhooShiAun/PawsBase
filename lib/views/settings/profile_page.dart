import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pawsbase/theme/tokens.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? {};
    final displayName = metadata['full_name'] ?? user?.email?.split('@').first ?? 'User';
    final email = user?.email ?? 'No email';

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
          'Profile Information',
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Profile Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PawsBaseTokens.secondaryContainer.withValues(alpha: 0.4),
                    border: Border.all(color: PawsBaseTokens.primary, width: 3),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 48,
                    color: PawsBaseTokens.primaryDark,
                  ),
                ),
                const SizedBox(height: 32),

                // Info Card
                Container(
                  width: double.infinity,
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
                      // Display Name
                      Text(
                        'DISPLAY NAME',
                        style: TextStyle(
                          fontFamily: PawsBaseTokens.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          color: PawsBaseTokens.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 20, color: PawsBaseTokens.primaryDark),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontFamily: PawsBaseTokens.fontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: PawsBaseTokens.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(color: colorScheme.outline.withValues(alpha: 0.1)),
                      const SizedBox(height: 24),

                      // Email
                      Text(
                        'EMAIL',
                        style: TextStyle(
                          fontFamily: PawsBaseTokens.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          color: PawsBaseTokens.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 20, color: PawsBaseTokens.primaryDark),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              email,
                              style: const TextStyle(
                                fontFamily: PawsBaseTokens.fontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: PawsBaseTokens.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
