import 'package:flutter/material.dart';
import 'package:pawsbase/theme/tokens.dart';

enum ButtonType { primary, secondary, inverted, outline, labelIcon, squareIcon, circleIcon }

class PawsButton extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isFullWidth;
  final Color? customColor; // Used for the circular icons to specify color

  const PawsButton({
    super.key,
    this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isFullWidth = false,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    BorderSide? borderSide;
    double radius = PawsBaseTokens.borderRadius;
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16);

    switch (type) {
      case ButtonType.primary:
        backgroundColor = PawsBaseTokens.primaryDark;
        textColor = Colors.white;
        break;
      case ButtonType.secondary:
        backgroundColor = PawsBaseTokens.tertiary; // Light beige
        textColor = PawsBaseTokens.neutralDark;
        break;
      case ButtonType.inverted:
        backgroundColor = PawsBaseTokens.neutralDark;
        textColor = Colors.white;
        break;
      case ButtonType.outline:
        backgroundColor = Colors.transparent;
        textColor = PawsBaseTokens.neutralDark;
        borderSide = const BorderSide(color: PawsBaseTokens.outline, width: 1);
        break;
      case ButtonType.labelIcon:
        backgroundColor = PawsBaseTokens.primary;
        textColor = PawsBaseTokens.neutralDark;
        break;
      case ButtonType.squareIcon:
        backgroundColor = PawsBaseTokens.neutral.withOpacity(0.5);
        textColor = PawsBaseTokens.neutralDark;
        padding = const EdgeInsets.all(16);
        break;
      case ButtonType.circleIcon:
        backgroundColor = customColor ?? PawsBaseTokens.primaryDark;
        textColor = Colors.white;
        radius = PawsBaseTokens.borderRadiusPill;
        padding = const EdgeInsets.all(16);
        break;
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          if (text != null) const SizedBox(width: 8),
        ],
        if (text != null)
          Text(
            text!,
            style: const TextStyle(
              fontFamily: PawsBaseTokens.fontFamily,
              fontSize: 16,
            ),
          ),
      ],
    );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: borderSide ?? BorderSide.none,
        ),
        padding: padding,
      ),
      onPressed: onPressed,
      child: content,
    );
  }
}

