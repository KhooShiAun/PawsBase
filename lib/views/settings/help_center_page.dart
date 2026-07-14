import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';
import 'package:pawsbase/widgets/paws_search_bar/paws_search_bar.dart';
import 'package:pawsbase/widgets/paws_button/paws_button.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // FAQ Data Structure
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I add a new pet to my family?',
      'answer': 'Navigate to the Home page or the Pets tab, and tap the floating "+" action button on the bottom right. Fill in your pet\'s name, gender, species, and other details to register them.',
    },
    {
      'question': 'Can I track veterinary logs or medical logs?',
      'answer': 'Yes! Go to the Health Log tab from the bottom navigation bar. Tap "Add Log" to record vaccinations, medications, weight updates, or vet visits.',
    },
    {
      'question': 'How do I change my account credentials?',
      'answer': 'Open Settings, go to the Security menu, and fill in the Password or Email change sections. You must confirm your current password to make updates.',
    },
    {
      'question': 'What formats are supported for avatar image URLs?',
      'answer': 'PawsBase supports any standard image URL (PNG, JPEG, WebP, SVG) directly through the profile edit page. Paste the image link to load it instantly.',
    },
    {
      'question': 'How do I log out of other devices?',
      'answer': 'Under Settings > Security, scroll down to Session Management. Tap the "Sign Out of Other Devices" option. This will securely close all sessions except the active one.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredFaqs = _faqs.where((faq) {
      final query = _searchQuery.toLowerCase();
      final questionMatch = faq['question']!.toLowerCase().contains(query);
      final answerMatch = faq['answer']!.toLowerCase().contains(query);
      return questionMatch || answerMatch;
    }).toList();

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
          'Help Center',
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
                  'How can we help today?',
                  style: TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                // Search bar
                PawsSearchBar(
                  controller: _searchController,
                  hintText: 'Search FAQ articles...',
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
                const SizedBox(height: 32),

                // FAQ Header
                Text(
                  'FREQUENTLY ASKED QUESTIONS',
                  style: TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: PawsBaseTokens.neutral,
                  ),
                ),
                const SizedBox(height: 12),

                // FAQ List
                if (filteredFaqs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: PawsBaseTokens.neutral.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No FAQ articles match your query.',
                            style: TextStyle(
                              fontFamily: PawsBaseTokens.fontFamily,
                              fontSize: 15,
                              color: PawsBaseTokens.neutral,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredFaqs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final faq = filteredFaqs[index];
                      return _FaqCard(
                        question: faq['question']!,
                        answer: faq['answer']!,
                        isDark: isDark,
                        colorScheme: colorScheme,
                      );
                    },
                  ),
                const SizedBox(height: 48),

                // Contact Section
                _buildContactCard(isDark, colorScheme),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(bool isDark, ColorScheme colorScheme) {
    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PawsBaseTokens.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: PawsBaseTokens.primaryDark,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Still need help?',
            style: TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'If you couldn\'t find answers in our FAQs, please contact our support team. We\'re available 24/7.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 14,
              color: PawsBaseTokens.neutral,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening Email client (support@pawsbase.com)...')),
                    );
                  },
                  icon: const Icon(Icons.mail_outline_rounded, size: 18),
                  label: const Text('Email Us'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PawsBaseTokens.primaryDark,
                    side: const BorderSide(color: PawsBaseTokens.primaryDark),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PawsButton(
                  text: 'Live Chat',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Starting Live Support session...')),
                    );
                  },
                  type: ButtonType.primary,
                  icon: Icons.chat_bubble_outline_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatefulWidget {
  final String question;
  final String answer;
  final bool isDark;
  final ColorScheme colorScheme;

  const _FaqCard({
    required this.question,
    required this.answer,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDark ? widget.colorScheme.surfaceContainerHighest : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isExpanded
                ? PawsBaseTokens.primary.withValues(alpha: 0.5)
                : widget.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: _isExpanded
              ? [
                  BoxShadow(
                    color: PawsBaseTokens.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: PawsBaseTokens.neutral,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(height: 0),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  widget.answer,
                  style: TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 14,
                    color: PawsBaseTokens.neutral,
                    height: 1.5,
                  ),
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}
