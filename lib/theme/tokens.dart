import 'package:flutter/material.dart';

class PawsBaseTokens {
  // Surface Colors
  static const Color surface = Color(0xFFF5F5F0); // Tertiary from image
  static const Color surfaceDim = Color(0xFFDCDAD0);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  
  // Brand / Primary Colors
  static const Color primary = Color(0xFF8FA98F); // Primary from image
  static const Color primaryDark = Color(0xFF4C644E); // Dark shade from primary scale
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF8FA98F); 
  static const Color onPrimaryContainer = Color(0xFF1B2C1C);

  // Secondary / Accent Colors 
  static const Color secondary = Color(0xFFE6D5B8); // Secondary from image
  static const Color secondaryDark = Color(0xFF7D7767); // Dark shade from secondary scale
  static const Color onSecondary = Color(0xFF1C1C18); 
  static const Color secondaryContainer = Color(0xFFE6D5B8);
  static const Color onSecondaryContainer = Color(0xFF2B261A);

  // Tertiary
  static const Color tertiary = Color(0xFFF5F5F0);
  static const Color onTertiary = Color(0xFF1C1C18);

  // Neutral / Text Colors
  static const Color neutral = Color(0xFF5C5C54); // Neutral from image
  static const Color neutralDark = Color(0xFF333330); // Dark shade for inverted
  static const Color onSurface = Color(0xFF1C1C18);
  static const Color onSurfaceVariant = Color(0xFF5C5C54);
  static const Color outline = Color(0xFF5C5C54);

  // Functional Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);

  // Design System Metadata
  static const String fontFamily = 'Quicksand';
  static const double borderRadius = 8.0;
  static const double borderRadiusPill = 999.0; // For pill shapes
}

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
  tertiary: PawsBaseTokens.tertiary,
  onTertiary: PawsBaseTokens.onTertiary,
  surface: PawsBaseTokens.surface,
  onSurface: PawsBaseTokens.onSurface,
  surfaceVariant: PawsBaseTokens.secondary, // Light beige surface variant
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
