import 'package:flutter/material.dart';

/// Main App Theme Colors - Based on YAMAA app screenshots (Purple & Orange Theme)
class AppColors {
  AppColors._();

  // Main App Theme Colors
  static const Color primaryColor = Color(0xff6B0F1A);
  static const Color drawerColor = Color(0xff33070C);
  static Color backgroundColor = Color(0xffF5EFE6);
  static const Color appBarColor = Color(0xff6B0F1A);
  static const Color appSurfaceColor = Color(0xff5A1E3D);
  static const Color socialMediaButton = Color(0xffE5E3DE);
    static Color socialMediaText = Color(0xff878787);

  // Text Colors
  static Color txtColor = Colors.grey[800]!;
  static const Color lightTxtColor = Colors.white;
  static Color appBarIconColor = Colors.grey[100]!;

  // Component Colors
  static const Color buttonColor = Color(0xffFFC947);
  //#FFC947
  static const Color cardColor = Colors.white;
  static const Color iconColor = Color(0xff5A1E3D);

  // Interactive Colors
  static const Color clickColor = Color(0xffFFC947);
  static Color shadowColor = Colors.grey[100]!;
  static const Color priceColor = Color(0xffE28743);

  // Status Colors
  static const Color successColor = Colors.green;
  static const Color failColor = Colors.red;
  static const Color ratingColor = Color(0xFFFFD700);

  // Additional Colors
  static const Color appDividerColor = Colors.white24;
  static const Color appInfoColor = Color(0xFF8E4EC6);
  static const Color whiteColor = Colors.white;
  static const Color warningColor = Color(0xFFFFB020);
  static const Color infoColor = Color(0xFFE47B39);
}

/// Splash Screen Colors - Based on YAMAA purple & orange theme
class SplashColors {
  SplashColors._();

  static const Color backgroundStart = Color(0xFF8E4EC6);
  static const Color backgroundEnd = Color(0xFF6B2C91);
  static const Color textColor = Colors.white;
  static const Color accentColor = Color(0xFFE28743);
}

/// Gradient Colors for Special Effects
class GradientColors {
  GradientColors._();

  static const Color gradientStart = Color(0xFF8E4EC6);
  static const Color gradientEnd = Color(0xFF6B2C91);
  static const Color primaryGradientStart = Color(0xFFE47B39);
  static const Color primaryGradientEnd = Color(0xFFD4621A);
}

/// Surface and Container Colors
class SurfaceColors {
  SurfaceColors._();

  static const Color surfaceColor = Colors.white;
  static const Color containerColor = Color(0xFFF8FBFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
}
