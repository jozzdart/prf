import 'package:prf/prf.dart';

/// A cached preference object specialized for storing enum values.
///
/// This class provides type-safe access to enum values stored in SharedPreferences,
/// with in-memory caching for improved performance. It uses [EnumAdapter] to
/// convert enum values to their integer indices for storage.
///
/// Example:
/// ```dart
/// enum Theme { light, dark, system }
///
/// final themePreference = PrfEnum<Theme>(
///   'app_theme',
///   values: Theme.values,
///   defaultValue: Theme.system,
/// );
///
/// await themePreference.set(Theme.dark);
/// final currentTheme = await themePreference.get(); // Returns Theme.dark
/// ```
class PrfEnum<T extends Enum> extends CachedPrfObject<T> {
  /// The adapter used for enum value conversion.
  final EnumAdapter<T> _adapter;

  @override

  /// Gets the adapter used to convert between the enum and its storage representation.
  EnumAdapter<T> get adapter => _adapter;

  /// Creates a new cached enum preference.
  ///
  /// - [key] is the key to store the preference under.
  /// - [values] is the list of all possible enum values, typically EnumType.values.
  /// - [defaultValue] is the optional default value to use when no value exists.
  PrfEnum(super.key, {required List<T> values, super.defaultValue})
      : _adapter = EnumAdapter<T>(values);
}
