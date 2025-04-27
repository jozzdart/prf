import 'package:flutter/material.dart';
import 'package:prf/prf_types/prf_enum.dart';

/// A type-safe wrapper for storing and retrieving [ThemeMode] values in SharedPreferences.
///
/// This class automatically handles the conversion between ThemeMode enum values and
/// their integer indices for storage.
///
/// The default value is based on the current system theme if not specified otherwise.
///
/// Example:
/// ```dart
/// final themeMode = PrfThemeMode('app_theme_mode');
/// await themeMode.set(ThemeMode.dark);
/// final currentTheme = await themeMode.get(); // ThemeMode.dark
/// ```
class PrfThemeMode extends PrfEnum<ThemeMode> {
  /// Creates a new ThemeMode preference variable with the specified [key].
  ///
  /// If [defaultValue] is not provided, it will use the system's current theme mode.
  /// This is determined at runtime when the value is first requested.
  PrfThemeMode(super.key, {super.defaultValue = ThemeMode.system})
      : super(values: ThemeMode.values);
}
