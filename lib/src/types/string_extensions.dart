import 'package:prf/prf.dart';

/// Extensions on `String` to create type-safe `Prf` instances with minimal syntax.
///
/// These shortcuts allow you to quickly define a preference variable using the string
/// itself as the key, without manually repeating the key name.
///
/// Example:
/// ```dart
/// final username = 'user_name'.prf<String>();
/// await username.set('Joey');
/// ```
///
/// Custom adapters are also supported for more advanced use cases:
/// ```dart
/// final theme = 'theme_mode'.prfCustomAdapter(
///   EnumAdapter(AppTheme.values),
/// );
/// ```
extension PrfStringExtensions on String {
  /// Creates a cached [`Prf<T>`] variable using this string as the key.
  ///
  /// - [T] is the type to store.
  /// - [defaultValue] is an optional fallback if the value has not been set yet.
  ///
  /// This is a shorthand for:
  /// ```dart
  /// Prf<T>('some_key', defaultValue: ...)
  /// ```
  Prf<T> prf<T>({T? defaultValue}) {
    return Prf<T>(
      this,
      defaultValue: defaultValue,
    );
  }

  /// Creates a cached [`Prf<T>`] using a custom adapter for this key.
  ///
  /// This allows you to store advanced types like enums or complex objects
  /// with their own serialization logic.
  ///
  /// - [adapter] is a `PrfAdapter<T>` used for encoding/decoding.
  /// - [defaultValue] is the fallback value if no value has been set.
  ///
  /// Example:
  /// ```dart
  /// final settings = 'app_settings'.prfCustomAdapter(JsonAdapter(...));
  /// ```
  Prf<T> prfCustomAdapter<T>(PrfAdapter<T> adapter, {T? defaultValue}) {
    return Prf.customAdapter<T>(
      this,
      adapter: adapter,
      defaultValue: defaultValue,
    );
  }
}
