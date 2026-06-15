import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:pawsbase/theme/tokens.dart';

import 'paws_button.dart';

@widgetbook.UseCase(name: 'All Buttons', type: PawsButton)
Widget allButtons(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PawsButton(text: 'Primary', type: ButtonType.primary, onPressed: () {}),
            const SizedBox(width: 16),
            PawsButton(text: 'Secondary', type: ButtonType.secondary, onPressed: () {}),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PawsButton(text: 'Inverted', type: ButtonType.inverted, onPressed: () {}),
            const SizedBox(width: 16),
            PawsButton(text: 'Outlined', type: ButtonType.outline, onPressed: () {}),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PawsButton(type: ButtonType.squareIcon, icon: Icons.edit, onPressed: () {}),
            const SizedBox(width: 16),
            PawsButton(text: 'Label', type: ButtonType.labelIcon, icon: Icons.edit, onPressed: () {}),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PawsButton(type: ButtonType.circleIcon, icon: Icons.auto_fix_high, customColor: PawsBaseTokens.primaryDark, onPressed: () {}),
            const SizedBox(width: 8),
            PawsButton(type: ButtonType.circleIcon, icon: Icons.category, customColor: PawsBaseTokens.secondaryDark, onPressed: () {}),
            const SizedBox(width: 8),
            PawsButton(type: ButtonType.circleIcon, icon: Icons.sell, customColor: PawsBaseTokens.neutral, onPressed: () {}),
            const SizedBox(width: 8),
            PawsButton(type: ButtonType.circleIcon, icon: Icons.delete, customColor: PawsBaseTokens.error, onPressed: () {}),
          ],
        )
      ],
    ),
  );
}

