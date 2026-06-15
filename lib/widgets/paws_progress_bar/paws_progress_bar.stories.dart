import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:pawsbase/theme/tokens.dart';
import 'paws_progress_bar.dart';

@widgetbook.UseCase(
  name: 'All Bars',
  type: PawsProgressBar,
)
Widget allProgressBars(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PawsProgressBar(progress: 0.7, color: PawsBaseTokens.primaryDark),
          const SizedBox(height: 16),
          PawsProgressBar(progress: 0.85, color: PawsBaseTokens.secondaryDark),
          const SizedBox(height: 16),
          PawsProgressBar(progress: 0.55, color: PawsBaseTokens.neutral),
        ],
      ),
    ),
  );
}
