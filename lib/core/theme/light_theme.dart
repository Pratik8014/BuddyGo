import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData vibrantNeonTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  // Primary Colors - Electric Purple with Neon undertones
  primaryColor: const Color(0xFF8B5CF6),
  primaryColorLight: const Color(0xFFC4B5FD),
  primaryColorDark: const Color(0xFF6D28D9),

  // Color Scheme - Vibrant Fusion of Neon, Sunset, and Candy gradients
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF8B5CF6), // Electric Purple
    secondary: Color(0xFFFF6B6B), // Coral Pink (Sunset Blend)
    tertiary: Color(0xFF4FD1C5), // Electric Teal
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFF0F2FE), // Soft Lavender tint
    error: Color(0xFFE53E3E),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color(0xFF1A202C),
    onBackground: Color(0xFF1A202C),
    onError: Colors.white,
    primaryContainer: Color(0xFFE9D8FD),
    secondaryContainer: Color(0xFFFFE5E5),
    tertiaryContainer: Color(0xFFE0F2F1),
  ),

  // Background with subtle gradient effect
  scaffoldBackgroundColor: const Color(0xFFF0F2FE),

  // AppBar with Glassmorphism + Glow effect
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white.withOpacity(0.9),
    elevation: 0,
    centerTitle: true,
    scrolledUnderElevation: 0,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF1A202C),
      letterSpacing: -0.5,
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF1A202C),
      size: 24,
    ),
    actionsIconTheme: const IconThemeData(
      color: Color(0xFF8B5CF6),
      size: 24,
    ),
  ),

  // Text Theme - Playful Modern with gradient potential
  textTheme: GoogleFonts.poppinsTextTheme(
    const TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A202C),
        letterSpacing: -1,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A202C),
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A202C),
        height: 1.3,
      ),
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A202C),
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A202C),
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A202C),
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A202C),
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF4A5568),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFF2D3748),
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF4A5568),
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF718096),
      ),
    ),
  ),

  // Elevated Button - Neon Pop with Electric Glow
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF8B5CF6),
      foregroundColor: Colors.white,
      elevation: 8,
      shadowColor: const Color(0xFF8B5CF6).withOpacity(0.4),
      minimumSize: const Size(120, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      textStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),

  // Text Button - Vibrant Fusion style
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF8B5CF6),
      textStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  ),

  // Outlined Button - Rainbow Pastel influence
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF8B5CF6),
      side: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
      minimumSize: const Size(120, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      textStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // Input Decoration - Candy Gradient + Glow UI
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 20,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(
        color: Color(0xFF8B5CF6),
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 2),
    ),
    hintStyle: GoogleFonts.poppins(
      color: const Color(0xFFA0AEC0),
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    labelStyle: GoogleFonts.poppins(
      color: const Color(0xFF4A5568),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    prefixIconColor: const Color(0xFF8B5CF6),
    suffixIconColor: const Color(0xFF8B5CF6),
  ),

  // Card Theme - Instagram Vibes + Electric Glow
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 4,
    shadowColor: const Color(0xFF8B5CF6).withOpacity(0.2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    clipBehavior: Clip.antiAlias,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  // Bottom Navigation Bar - Playful Modern
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: const Color(0xFF8B5CF6),
    unselectedItemColor: const Color(0xFFA0AEC0),
    selectedLabelStyle: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
    unselectedLabelStyle: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    showSelectedLabels: true,
    showUnselectedLabels: true,
  ),

  // Floating Action Button - Neon Pop
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: const Color(0xFFFF6B6B),
    foregroundColor: Colors.white,
    elevation: 8,
    focusElevation: 12,
    hoverElevation: 12,
    disabledElevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    extendedSizeConstraints: const BoxConstraints(minHeight: 56, minWidth: 120),
    extendedTextStyle: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  ),

  // Chip Theme - Color Burst
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFE9D8FD),
    deleteIconColor: const Color(0xFF8B5CF6),
    disabledColor: const Color(0xFFEDF2F7),
    selectedColor: const Color(0xFF8B5CF6),
    secondarySelectedColor: const Color(0xFFFF6B6B),
    labelStyle: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF1A202C),
    ),
    secondaryLabelStyle: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    brightness: Brightness.light,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),

  // Progress Indicator - Electric Glow
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFF8B5CF6),
    linearTrackColor: Color(0xFFE9D8FD),
    circularTrackColor: Color(0xFFE9D8FD),
    refreshBackgroundColor: Colors.white,
  ),

  // Slider Theme - Vibrant Fusion
  sliderTheme: SliderThemeData(
    activeTrackColor: const Color(0xFF8B5CF6),
    inactiveTrackColor: const Color(0xFFE9D8FD),
    thumbColor: const Color(0xFFFF6B6B),
    overlayColor: const Color(0xFFFF6B6B).withOpacity(0.2),
    valueIndicatorColor: const Color(0xFF8B5CF6),
    valueIndicatorTextStyle: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),

  // Switch Theme - Neon Pop
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF8B5CF6);
      }
      return const Color(0xFFC4B5FD);
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF8B5CF6).withOpacity(0.5);
      }
      return const Color(0xFFE9D8FD);
    }),
  ),

  // Checkbox Theme - Rainbow Pastel
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF8B5CF6);
      }
      return Colors.white;
    }),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
    side: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
  ),

  // Radio Theme - Color Burst
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return const Color(0xFF8B5CF6);
      }
      return const Color(0xFFC4B5FD);
    }),
  ),

  // Dialog Theme - Glassmorphism effect
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white,
    elevation: 24,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(32),
    ),
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF1A202C),
    ),
    contentTextStyle: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF4A5568),
      height: 1.6,
    ),
  ),

  // Bottom Sheet Theme - Playful Modern
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    elevation: 16,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    modalBackgroundColor: Colors.white,
    modalElevation: 16,

  ),

  // Tab Bar Theme - Sunset Blend
  tabBarTheme: TabBarThemeData(
    labelColor: const Color(0xFF8B5CF6),
    unselectedLabelColor: const Color(0xFFA0AEC0),
    labelStyle: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
    unselectedLabelStyle: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    indicator: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Color(0xFF8B5CF6), width: 3),
      ),
    ),
  ),

  // Divider Theme - Electric Glow hint
  dividerTheme: const DividerThemeData(
    color: Color(0xFFE9D8FD),
    thickness: 1,
    space: 24,
  ),

  // Snackbar Theme - Vibrant Fusion
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF1A202C),
    contentTextStyle: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    actionTextColor: const Color(0xFFFF6B6B),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    behavior: SnackBarBehavior.floating,
  ),

  // Tooltip Theme - Playful Modern
  tooltipTheme: TooltipThemeData(
    decoration: BoxDecoration(
      color: const Color(0xFF1A202C).withOpacity(0.9),
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),
);

// Extension methods for easy gradient access
extension ThemeGradients on BuildContext {
  LinearGradient get primaryGradient => const LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get sunsetGradient => const LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFBBF24), Color(0xFF4FD1C5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get neonPopGradient => const LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get candyGradient => const LinearGradient(
    colors: [Color(0xFFF472B6), Color(0xFFFFD166), Color(0xFF06D6A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}