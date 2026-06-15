import 'package:flutter/material.dart';

class PawsBaseTokens {
  // Surface Colors
  static const Color surface = Color(0xFFFCFAEF);
  static const Color surfaceDim = Color(0xFFDCDAD0);
  static const Color surfaceBright = Color(0xFFFCFAEF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F4E9);
  static const Color surfaceContainer = Color(0xFFF0EEE3);
  static const Color surfaceContainerHigh = Color(0xFFEAE8DE);
  static const Color surfaceContainerHighest = Color(0xFFE5E2D8);

  // Brand / Primary Colors (Sage Green)
  static const Color primary = Color(0xFF4C644E); // Deep Sage
  static const Color primaryContainer = Color(0xFF8FA98F); // Soft Sage
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF1B2C1C);

  // Secondary / Accent Colors (Sand/Earth)
  static const Color secondary = Color(0xFF7D7767);
  static const Color secondaryContainer = Color(0xFFDED9C9);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF2B261A);

  // Text / Typography Colors
  static const Color onSurface = Color(0xFF1C1C18);
  static const Color onSurfaceVariant = Color(0xFF49483E);
  static const Color outline = Color(0xFF7A796C);

  // Functional Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF4C644E); // Using brand green for success states

  // Design System Metadata
  static const String fontFamily = 'Quicksand';
  static const double borderRadius = 8.0;
}

// Example usage of a Zen-themed ColorScheme
final ColorScheme pawsBaseColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: PawsBaseTokens.primary,
  onPrimary: PawsBaseTokens.onPrimary,
  primaryContainer: PawsBaseTokens.primaryContainer,
  onPrimaryContainer: PawsBaseTokens.onPrimaryContainer,
  secondary: PawsBaseTokens.secondary,
  onSecondary: PawsBaseTokens.onSecondary,
  secondaryContainer: PawsBaseTokens.secondaryContainer,
  onSecondaryContainer: PawsBaseTokens.onSecondaryContainer,
  surface: PawsBaseTokens.surface,
  onSurface: PawsBaseTokens.onSurface,
  surfaceVariant: PawsBaseTokens.surfaceContainer,
  onSurfaceVariant: PawsBaseTokens.onSurfaceVariant,
  outline: PawsBaseTokens.outline,
  error: PawsBaseTokens.error,
  onError: PawsBaseTokens.onError,
);

class PawsBaseDarkTokens {
  // Surface Colors
  static const Color surface = Color(0xFF121212);
  static const Color surfaceDim = Color(0xFF0E0E0E);
  static const Color surfaceBright = Color(0xFF1E1E1E);
  static const Color surfaceContainerLowest = Color(0xFF000000);
  static const Color surfaceContainerLow = Color(0xFF181818);
  static const Color surfaceContainer = Color(0xFF222222);
  static const Color surfaceContainerHigh = Color(0xFF2B2B2B);
  static const Color surfaceContainerHighest = Color(0xFF333333);

  // Brand / Primary Colors (Lighter for dark mode)
  static const Color primary = Color(0xFF8FA98F);
  static const Color primaryContainer = Color(0xFF354B37);
  static const Color onPrimary = Color(0xFF1B2C1C);
  static const Color onPrimaryContainer = Color(0xFFC4DFC3);

  // Secondary / Accent Colors
  static const Color secondary = Color(0xFFDED9C9);
  static const Color secondaryContainer = Color(0xFF4A4537);
  static const Color onSecondary = Color(0xFF2B261A);
  static const Color onSecondaryContainer = Color(0xFFF3EDDC);

  // Text / Typography Colors
  static const Color onSurface = Color(0xFFE4E3DB);
  static const Color onSurfaceVariant = Color(0xFFC8C7BA);
  static const Color outline = Color(0xFF949486);

  // Functional Colors
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
}

final ColorScheme pawsBaseDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: PawsBaseDarkTokens.primary,
  onPrimary: PawsBaseDarkTokens.onPrimary,
  primaryContainer: PawsBaseDarkTokens.primaryContainer,
  onPrimaryContainer: PawsBaseDarkTokens.onPrimaryContainer,
  secondary: PawsBaseDarkTokens.secondary,
  onSecondary: PawsBaseDarkTokens.onSecondary,
  secondaryContainer: PawsBaseDarkTokens.secondaryContainer,
  onSecondaryContainer: PawsBaseDarkTokens.onSecondaryContainer,
  surface: PawsBaseDarkTokens.surface,
  onSurface: PawsBaseDarkTokens.onSurface,
  surfaceVariant: PawsBaseDarkTokens.surfaceContainer,
  onSurfaceVariant: PawsBaseDarkTokens.onSurfaceVariant,
  outline: PawsBaseDarkTokens.outline,
  error: PawsBaseDarkTokens.error,
  onError: PawsBaseDarkTokens.onError,
);
