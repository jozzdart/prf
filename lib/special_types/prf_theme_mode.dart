import 'package:flutter/material.dart';
import 'package:prf/core/prf_encoded.dart';

/// A type-safe wrapper for storing and retrieving [ThemeMode] values in SharedPreferences.
///
/// This class automatically handles the conversion between ThemeMode enum values and
/// their string representation for storage.
///
/// The default value is based on the current system theme if not specified otherwise.
///
/// Example:
/// ```dart
/// final themeMode = PrfThemeMode('app_theme_mode');
/// await themeMode.set(ThemeMode.dark);
/// final currentTheme = await themeMode.get(); // ThemeMode.dark
/// ```
class PrfThemeMode extends PrfEncoded<ThemeMode, String> {
  /// Creates a new ThemeMode preference variable with the specified [key].
  ///
  /// If [defaultValue] is not provided, it will use the system's current theme mode.
  /// This is determined at runtime when the value is first requested.
  PrfThemeMode(super.key, {ThemeMode? defaultValue})
      : super(
          from: (stringValue) {
            if (stringValue == null) return null;
            try {
              return ThemeMode.values.firstWhere(
                (mode) => mode.toString() == stringValue,
                orElse: () => ThemeMode.system,
              );
            } catch (_) {
              return null;
            }
          },
          to: (themeMode) => themeMode.toString(),
          getter: (prefs, key) async => await prefs.getString(key),
          setter: (prefs, key, value) async =>
              await prefs.setString(key, value),
          defaultValue: defaultValue ?? ThemeMode.system,
        );
}
