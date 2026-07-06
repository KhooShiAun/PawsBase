import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';
import 'package:pawsbase/views/pets/add_pet_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PawsBaseTokens.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 48),
            _buildYourPetsSection(context),
            const SizedBox(height: 48),
            _buildHealthAndTrainingSection(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PawsBaseTokens.surfaceBright,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Good morning, Alex!",
            style: TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: PawsBaseTokens.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Ready for another great day with your furry friends?",
            style: TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 16,
              color: PawsBaseTokens.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildStatItem(Icons.pets, "Active Pets", "2", PawsBaseTokens.primaryContainer.withValues(alpha: 0.3), PawsBaseTokens.primaryDark),
              const SizedBox(width: 32),
              _buildStatItem(Icons.workspace_premium, "Mastered", "12", PawsBaseTokens.secondaryContainer.withValues(alpha: 0.3), PawsBaseTokens.secondaryDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color bgColor, Color iconColor) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: PawsBaseTokens.onSurface,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: PawsBaseTokens.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildYourPetsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Your Pets",
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: PawsBaseTokens.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                "VIEW ALL",
                style: TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: PawsBaseTokens.primaryDark,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildPetCard(
                "Luna",
                "Golden Retriever",
                "https://lh3.googleusercontent.com/aida-public/AB6AXuBHqf6G49FLYBy6dzkMbF1OhAs_G-LIQfMs3wrsSg-LPhkwUr24CIXndyojnn0KD3o5ux267SUFeZLBgqT-R1jDCN0GB43sSo6M-r81I_GwaC8gh9uVIhLKFtemgu9Btn2u_LN2yi0IIjcgp4rXd6-Vv6pXCs8KVdC4oKfosIOGRs_woaugOqyUhzEx6vw0DnXYi8bSMwBnKTCrp5Ucod572tYAAk6obSleNRysjZ3rKwMPTPCtI1u_X9DtZBCaAWwwSMP0MaTg1WYh",
              ),
              const SizedBox(width: 16),
              _buildPetCard(
                "Milo",
                "French Bulldog",
                "https://lh3.googleusercontent.com/aida-public/AB6AXuCFf613eqnR2I6AfbJHlq6L0dGFoGuVCTX7R5fjgTpD8fqP51LOp5uHE-bnqIjqZSPGXWb-Hd8MlAJW7_77U8fFEty5QheUogOkfJ-idZWWL0JaHu4PdkANp4UzNU6xtPH_OZaDq6hOzF67y5NrPburVyDaxnmj0JuGMtwuEnp6cYlSej7w82weDPxzHJxG5M2XHbRuyP2PCm7-ocpShHLhH2GhcmBjDtpVdz8EWMw7xIC4gtZAqBZgLEpzP_Q_LleNZKFGP7epPhEy",
              ),
              const SizedBox(width: 16),
              _buildAddPetCard(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPetCard(String name, String breed, String imageUrl) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PawsBaseTokens.surfaceBright,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: PawsBaseTokens.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            breed.toUpperCase(),
            style: const TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: PawsBaseTokens.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPetCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddPetPage()),
        );
      },
      child: Container(
        width: 120,
        height: 275,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: PawsBaseTokens.outline.withValues(alpha: 0.3),
            width: 2,
          ),
          color: PawsBaseTokens.surface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: PawsBaseTokens.surfaceDim.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: PawsBaseTokens.primaryDark, size: 28),
            ),
            const SizedBox(height: 12),
            const Text(
              "ADD",
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: PawsBaseTokens.onSurfaceVariant,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthAndTrainingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: PawsBaseTokens.surfaceBright,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: PawsBaseTokens.surfaceDim.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.vaccines, color: PawsBaseTokens.neutralDark, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recent Health Entry",
                      style: TextStyle(
                        fontFamily: PawsBaseTokens.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: PawsBaseTokens.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Luna received her Annual DHPP Booster.",
                      style: TextStyle(
                        fontFamily: PawsBaseTokens.fontFamily,
                        fontSize: 16,
                        color: PawsBaseTokens.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "TODAY, 10:00 AM",
                      style: TextStyle(
                        fontFamily: PawsBaseTokens.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: PawsBaseTokens.neutralDark,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: PawsBaseTokens.surfaceBright,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.fitness_center, color: PawsBaseTokens.secondaryDark, size: 28),
                  SizedBox(width: 12),
                  Text(
                    "Training Progress",
                    style: TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: PawsBaseTokens.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Milo is 3 sessions away from\nmastering 'Stay'.",
                    style: TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 16,
                      color: PawsBaseTokens.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    "75%",
                    style: TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: PawsBaseTokens.secondaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: PawsBaseTokens.surfaceDim.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.75,
                  child: Container(
                    decoration: BoxDecoration(
                      color: PawsBaseTokens.secondaryDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PawsBaseTokens.secondaryDark,
                    foregroundColor: PawsBaseTokens.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "CONTINUE TRAINING",
                        style: TextStyle(
                          fontFamily: PawsBaseTokens.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}