import 'package:prf/prf.dart';

/// A type-safe wrapper for storing and retrieving enum values in SharedPreferences.
///
/// This class automatically handles the conversion between enum values and their
/// integer indices for storage in SharedPreferences.
///
/// Use this class for storing enumerated types like application states, user roles,
/// theme modes, or any other enum-based selections.
///
/// Example:
/// ```dart
/// enum ThemeMode { light, dark, system }
///
/// final themePreference = PrfEnum<ThemeMode>(
///   'theme_mode',
///   values: ThemeMode.values,
///   defaultValue: ThemeMode.system,
/// );
///
/// await themePreference.set(ThemeMode.dark);
/// final mode = await themePreference.get(); // ThemeMode.dark
/// ```
class PrfEnum<T extends Enum> extends PrfEncoded<T, int> {
  /// Creates a new enum preference variable with the specified [key].
  ///
  /// [values] is required and should be the enum's values list (e.g., `MyEnum.values`).
  ///
  /// The optional [defaultValue] is returned if the preference is not found
  /// or if an error occurs while reading.
  PrfEnum(super.key, {required List<T> values, super.defaultValue})
      : super(
          from: (index) {
            if (index == null || index < 0 || index >= values.length) {
              return null;
            }
            return values[index];
          },
          to: (e) => e.index,
          getter: (prefs, key) async => await prefs.getInt(key),
          setter: (prefs, key, value) async => await prefs.setInt(key, value),
        );
}
