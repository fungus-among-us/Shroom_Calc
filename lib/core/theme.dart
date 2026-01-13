import 'package:flutter/material.dart';

/// Contemporary Apothecary Theme
/// Sophisticated organic aesthetic inspired by botanical laboratories,
/// mycology research, and artisanal craft. Natural science meets refined design.
class AppTheme {
  // Color palette: Rich amber, forest sage, warm terracotta, cream bases
  // Inspired by dried mushroom caps, mycelium networks, spore prints, and natural materials

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    // Primary: Rich amber-caramel (like dried Golden Teacher caps)
    primary: Color(0xFFB8884D), // Deep golden amber
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFFE4C2), // Warm champagne
    onPrimaryContainer: Color(0xFF2D1B00),
    // Secondary: Forest sage (mycelium growth environment)
    secondary: Color(0xFF4A6B54), // Deep sage with warmth
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD0E8D8), // Pale mint-sage
    onSecondaryContainer: Color(0xFF0A2015),
    // Tertiary: Warm terracotta (spore print tones)
    tertiary: Color(0xFFB85C47), // Rich terracotta-sienna
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFDDD3), // Soft peachy coral
    onTertiaryContainer: Color(0xFF3A0F09),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    // Surface: Warm cream with subtle yellow undertone
    surface: Color(0xFFFFFAF3), // Creamy ivory
    onSurface: Color(0xFF1E1B16),
    surfaceContainerHighest: Color(0xFFECE6DD), // Warm linen
    surfaceContainerHigh: Color(0xFFF2EDE4), // Light parchment
    surfaceContainer: Color(0xFFF8F3EA), // Subtle cream
    surfaceContainerLow: Color(0xFFFDF8EF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    onSurfaceVariant: Color(0xFF4D4639), // Warm charcoal-brown
    outline: Color(0xFF7E7667), // Muted taupe
    outlineVariant: Color(0xFFD0C9B9), // Light warm gray
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF343028),
    onInverseSurface: Color(0xFFF7F1E8),
    inversePrimary: Color(0xFFFFD791), // Bright amber glow
    surfaceTint: Color(0xFFB8884D),
  );

  // Dark theme: Nighttime forest with bioluminescent accents
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFFD791), // Glowing amber
    onPrimary: Color(0xFF4A2800),
    primaryContainer: Color(0xFF6A3D00),
    onPrimaryContainer: Color(0xFFFFE4C2),
    secondary: Color(0xFFB4D4C0), // Soft mint (bioluminescent mycelium)
    onSecondary: Color(0xFF1F3728),
    secondaryContainer: Color(0xFF354E3E),
    onSecondaryContainer: Color(0xFFD0E8D8),
    tertiary: Color(0xFFFFB4A0), // Soft coral glow
    onTertiary: Color(0xFF5F1A10),
    tertiaryContainer: Color(0xFF7E3026),
    onTertiaryContainer: Color(0xFFFFDDD3),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF151310), // Deep forest floor
    onSurface: Color(0xFFECE6DD),
    surfaceContainerHighest: Color(0xFF3A3630), // Dark bark
    surfaceContainerHigh: Color(0xFF2F2B26),
    surfaceContainer: Color(0xFF24211D),
    surfaceContainerLow: Color(0xFF1E1B16),
    surfaceContainerLowest: Color(0xFF100E0B),
    onSurfaceVariant: Color(0xFFD0C9B9),
    outline: Color(0xFF989181), // Weathered wood
    outlineVariant: Color(0xFF4D4639),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFECE6DD),
    onInverseSurface: Color(0xFF343028),
    inversePrimary: Color(0xFFB8884D),
    surfaceTint: Color(0xFFFFD791),
  );

  // Fluid Typography System
  // Based on a refined modular scale (1.250 - Major Third) for harmonious proportions
  // Optimized for readability across mobile, tablet, and desktop screens
  // Font sizes scale naturally with device type using platform-appropriate system fonts

  static TextTheme get textTheme {
    return const TextTheme(
      // Display styles - Large headings (rarely used in this app)
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w300, // Light weight for elegance
        letterSpacing: -0.5,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w300,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles - Section headers
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500, // Slightly bolder for emphasis
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title styles - Card headers, dialog titles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600, // Semibold for hierarchy
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body styles - Main content (optimized for readability)
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.50, // Generous line height for comfort
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.50, // Increased from 1.43 for better readability
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.45, // Increased from 1.33
      ),

      // Label styles - Buttons, tabs, form labels
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600, // Bold for buttons
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.40,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  // Light theme with refined spacing and elevated components
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      textTheme: textTheme,

      // AppBar with subtle elevation
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Color(0x08000000),
        surfaceTintColor: Colors.transparent,
      ),

      // Cards with soft shadows
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: lightColorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // Input fields with refined appearance
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            lightColorScheme.surfaceContainerHighest.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: lightColorScheme.outline.withOpacity(0.4),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: lightColorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: lightColorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: lightColorScheme.error,
            width: 1,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Elevated buttons with refined styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(88, 48),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Filled buttons (primary actions)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(88, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Segmented buttons with refined appearance
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ),

      // Dividers with subtle appearance
      dividerTheme: DividerThemeData(
        color: lightColorScheme.outlineVariant.withOpacity(0.5),
        thickness: 1,
        space: 1,
      ),

      // Bottom navigation with elevation
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        shadowColor: const Color(0x0A000000),
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(size: 24, color: lightColorScheme.primary);
          }
          return IconThemeData(
            size: 24,
            color: lightColorScheme.onSurfaceVariant,
          );
        }),
      ),

      // List tiles with proper spacing
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minVerticalPadding: 8,
      ),

      // Chips with refined styling
      chipTheme: ChipThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // Dark theme with rich depth and atmospheric quality
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Color(0x12000000),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: darkColorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            darkColorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: darkColorScheme.outline.withOpacity(0.4),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: darkColorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: darkColorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: darkColorScheme.error,
            width: 1,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(88, 48),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(88, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: darkColorScheme.outlineVariant.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        shadowColor: const Color(0x15000000),
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(size: 24, color: darkColorScheme.primary);
          }
          return IconThemeData(
            size: 24,
            color: darkColorScheme.onSurfaceVariant,
          );
        }),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minVerticalPadding: 8,
      ),
      chipTheme: ChipThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
