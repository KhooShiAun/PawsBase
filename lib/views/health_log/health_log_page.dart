import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

class HealthLogPage extends StatelessWidget {
  const HealthLogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PawsBaseTokens.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "Bella's Health Log",
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: PawsBaseTokens.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChip("Golden Retriever", PawsBaseTokens.secondaryContainer, PawsBaseTokens.onSecondaryContainer),
                const SizedBox(width: 8),
                _buildChip("3 years old", PawsBaseTokens.surfaceDim, PawsBaseTokens.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Medical history and wellness tracking.",
              style: TextStyle(
                fontFamily: PawsBaseTokens.fontFamily,
                fontSize: 18,
                color: PawsBaseTokens.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),

            // Weight Highlight Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: PawsBaseTokens.surfaceBright, 
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PawsBaseTokens.outline.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: PawsBaseTokens.surfaceDim.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.scale, color: PawsBaseTokens.primaryDark, size: 32),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CURRENT WEIGHT",
                          style: TextStyle(
                            fontFamily: PawsBaseTokens.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: PawsBaseTokens.outline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "12.5",
                              style: TextStyle(
                                fontFamily: PawsBaseTokens.fontFamily,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: PawsBaseTokens.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "kg",
                              style: TextStyle(
                                fontFamily: PawsBaseTokens.fontFamily,
                                fontSize: 16,
                                color: PawsBaseTokens.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: PawsBaseTokens.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadiusPill),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.trending_up, color: PawsBaseTokens.primaryDark, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "Stable",
                              style: TextStyle(
                                fontFamily: PawsBaseTokens.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: PawsBaseTokens.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Oct 12",
                        style: TextStyle(
                          fontFamily: PawsBaseTokens.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: PawsBaseTokens.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Timeline Header
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text("Add Entry"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PawsBaseTokens.primaryDark,
                    foregroundColor: PawsBaseTokens.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: PawsBaseTokens.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Timeline Items
            _buildTimelineItem(
              icon: Icons.vaccines,
              iconColor: PawsBaseTokens.primaryDark,
              title: "Annual Vaccination",
              date: "Oct 12, 2023",
              subtitle: "Dr. Smith Clinic",
              description: "Administered DHPP and Rabies booster. Bella was very well behaved. Next due in 1 year.",
              isLast: false,
              child: _buildChipWithIcon(Icons.receipt_long, "Invoice"),
            ),
            _buildTimelineItem(
              icon: Icons.medical_services,
              iconColor: PawsBaseTokens.secondaryDark,
              title: "Routine Checkup",
              date: "Jun 05, 2023",
              subtitle: "General Health",
              description: "Overall health is excellent. Teeth looking good, recommended continuing current dental chews.",
              isLast: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PawsBaseTokens.surfaceDim.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildStatBlock("Weight", "12.4 kg"),
                    const SizedBox(width: 24),
                    _buildStatBlock("Temp", "101.2°F"),
                  ],
                ),
              ),
            ),
            _buildTimelineItem(
              icon: Icons.pest_control,
              iconColor: PawsBaseTokens.neutralDark,
              title: "Flea & Tick Prevention",
              date: "Mar 15, 2023",
              subtitle: "Medication",
              description: "Administered monthly topical treatment. Set reminder for next dose.",
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: PawsBaseTokens.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildChipWithIcon(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: PawsBaseTokens.surfaceDim.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: PawsBaseTokens.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: PawsBaseTokens.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: PawsBaseTokens.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: PawsBaseTokens.outline,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: PawsBaseTokens.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: PawsBaseTokens.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String date,
    required String subtitle,
    required String description,
    required bool isLast,
    Widget? child,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line & icon
          SizedBox(
            width: 48,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: 40,
                    bottom: -40,
                    child: Container(
                      width: 1,
                      color: PawsBaseTokens.outline.withOpacity(0.3),
                    ),
                  ),
                Positioned(
                  top: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: PawsBaseTokens.surfaceBright,
                      shape: BoxShape.circle,
                      border: Border.all(color: PawsBaseTokens.surface, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: PawsBaseTokens.outline.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: PawsBaseTokens.surfaceBright,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PawsBaseTokens.outline.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: PawsBaseTokens.fontFamily,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: PawsBaseTokens.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            fontFamily: PawsBaseTokens.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: PawsBaseTokens.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle.toUpperCase(),
                      style: TextStyle(
                        fontFamily: PawsBaseTokens.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: PawsBaseTokens.outline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: PawsBaseTokens.fontFamily,
                        fontSize: 16,
                        color: PawsBaseTokens.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    if (child != null) ...[
                      const SizedBox(height: 16),
                      child,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
