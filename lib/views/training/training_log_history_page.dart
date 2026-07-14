import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';
import 'package:pawsbase/views/pets/pet.dart';

class TrainingLogHistoryPage extends StatelessWidget {
  final Pet pet;

  const TrainingLogHistoryPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PawsBaseTokens.surface,
      appBar: AppBar(
        backgroundColor: PawsBaseTokens.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: PawsBaseTokens.onSurfaceVariant),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "${pet.name}'s Training History",
          style: const TextStyle(
            fontFamily: PawsBaseTokens.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: PawsBaseTokens.primaryDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${pet.name}'s Training Log",
              style: const TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: PawsBaseTokens.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "A record of all completed training sessions.",
              style: const TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 16,
                color: PawsBaseTokens.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            _buildSessionCard(
              command: "Sit",
              date: "Jul 5, 2026",
              duration: "10 mins",
              result: "Mastered",
              resultColor: PawsBaseTokens.primaryDark,
              notes: "${pet.name} responded consistently without prompting.",
            ),
            const SizedBox(height: 16),
            _buildSessionCard(
              command: "Stay",
              date: "Jul 3, 2026",
              duration: "15 mins",
              result: "In Progress",
              resultColor: PawsBaseTokens.secondaryDark,
              notes: "Holding position for up to 10 seconds. Needs more distance practice.",
            ),
            const SizedBox(height: 16),
            _buildSessionCard(
              command: "Heel",
              date: "Jun 28, 2026",
              duration: "20 mins",
              result: "In Progress",
              resultColor: PawsBaseTokens.secondaryDark,
              notes: "Loose leash walking improving. Still gets distracted by other dogs.",
            ),
            const SizedBox(height: 16),
            _buildSessionCard(
              command: "Come",
              date: "Jun 20, 2026",
              duration: "10 mins",
              result: "Mastered",
              resultColor: PawsBaseTokens.primaryDark,
              notes: "Reliable recall in both indoor and outdoor environments.",
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard({
    required String command,
    required String date,
    required String duration,
    required String result,
    required Color resultColor,
    required String notes,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PawsBaseTokens.surfaceBright,
        borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadius),
        border: Border.all(color: PawsBaseTokens.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                command,
                style: const TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: PawsBaseTokens.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: resultColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadiusPill),
                ),
                child: Text(
                  result,
                  style: TextStyle(
                    fontFamily: PawsBaseTokens.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: resultColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: PawsBaseTokens.outline),
              const SizedBox(width: 6),
              Text(
                date,
                style: const TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 13,
                  color: PawsBaseTokens.outline,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.timer_outlined, size: 14, color: PawsBaseTokens.outline),
              const SizedBox(width: 6),
              Text(
                duration,
                style: const TextStyle(
                  fontFamily: PawsBaseTokens.fontFamily,
                  fontSize: 13,
                  color: PawsBaseTokens.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notes,
            style: const TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 15,
              color: PawsBaseTokens.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}