import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          'Privacy Policy',
          style: TextStyle(
            fontFamily: PawsBaseTokens.fontFamily,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Policy & Terms',
                  style: TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last Updated: July 14, 2026',
                  style: TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 13,
                    color: PawsBaseTokens.neutral,
                  ),
                ),
                const SizedBox(height: 24),

                _buildPolicyCard(
                  isDark: isDark,
                  colorScheme: colorScheme,
                  number: '1',
                  title: 'Information We Collect',
                  body: 'We collect account-related information (such as your email address and custom user display name) to enable profile synchronization. Additionally, we store pet-specific information (such as pet names, species, breeds, weights, birthdates, vaccination statuses, and training records) that you explicitly input into the application.',
                ),
                const SizedBox(height: 16),

                _buildPolicyCard(
                  isDark: isDark,
                  colorScheme: colorScheme,
                  number: '2',
                  title: 'How We Use and Store Data',
                  body: 'Your profile and pet logs are synchronized to our cloud servers via secure database storage managed by Supabase. This data is used solely to provide dashboard stats, pet health logs, and checkmarks. We use transport-level encryption and do not distribute or sell user profile records.',
                ),
                const SizedBox(height: 16),

                _buildPolicyCard(
                  isDark: isDark,
                  colorScheme: colorScheme,
                  number: '3',
                  title: 'Data Retention and Account Deletion',
                  body: 'You retain full control over your data. All pet logs, vaccination activities, checklists, and user profiles are retained as long as your account remains active. You can clear your profile at any time or permanently delete your account through the dangerous zone in Security settings.',
                ),
                const SizedBox(height: 16),

                _buildPolicyCard(
                  isDark: isDark,
                  colorScheme: colorScheme,
                  number: '4',
                  title: 'Updates and Contact Details',
                  body: 'PawsBase may occasionally update this Privacy Policy to reflect app updates. When changes are made, the "Last Updated" timestamp will be modified. If you have any inquiries regarding data usage or privacy compliance, please reach out to privacy@pawsbase.com.',
                ),
                const SizedBox(height: 48),

                Center(
                  child: Text(
                    'Thank you for trusting PawsBase with your pets.',
                    style: TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: PawsBaseTokens.neutral,
                    ),
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

  Widget _buildPolicyCard({
    required bool isDark,
    required ColorScheme colorScheme,
    required String number,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: PawsBaseTokens.primaryDark,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 14,
              color: PawsBaseTokens.neutral,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
