import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';

class PawsProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? color;

  const PawsProgressBar({
    super.key,
    required this.progress,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? PawsBaseTokens.primaryDark;
    
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: PawsBaseTokens.surfaceDim.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadiusPill),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: constraints.maxWidth * progress.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(PawsBaseTokens.borderRadiusPill),
              ),
            ),
          );
        },
      ),
    );
  }
}
