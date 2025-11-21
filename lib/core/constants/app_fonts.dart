/// App Font Constants
/// 
/// This file provides centralized font management for the entire application.
/// Use these constants instead of hardcoded font family strings for better maintainability.
class AppFonts {
  AppFonts._();
  
  /// Primary font family used throughout the application
  static const String primaryFont = 'fs_albert';
  
  /// Backup font families in case the primary font is not available
  static const String fallbackFont = 'Inter';
  
  /// System font fallback
  static const String systemFont = 'System';
  
  /// Font stack for better cross-platform compatibility
  static const List<String> fontStack = [
    primaryFont,
    fallbackFont,
    systemFont,
  ];
}