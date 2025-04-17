import 'package:prf/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A specialized [PrfVariable] that handles encoding and decoding between
/// in-memory types and storage types.
///
/// Provides a flexible way to store complex types that aren't directly supported
/// by SharedPreferences by encoding them to supported types before storage and
/// decoding them after retrieval.
///
/// Type parameters:
/// * [TSource]: The in-memory type used in your application (e.g., DateTime, enum)
/// * [TStore]: The type used for storage in SharedPreferences (e.g., String, int)
class PrfEncoded<TSource, TStore> extends PrfVariable<TSource> {
  /// Creates a new [PrfEncoded] variable with the specified encoding and decoding functions.
  ///
  /// Parameters:
  /// * [key]: Unique identifier for the variable in SharedPreferences
  /// * [from]: Function to decode from storage type [TStore] to source type [TSource]
  /// * [to]: Function to encode from source type [TSource] to storage type [TStore]
  /// * [getter]: Function to retrieve the encoded value from SharedPreferences
  /// * [setter]: Function to save the encoded value to SharedPreferences
  /// * [defaultValue]: Optional default value to use when no value is stored
  PrfEncoded(
    String key, {
    required Decode<TSource, TStore> from,
    required Encode<TSource, TStore> to,
    required Future<TStore?> Function(SharedPreferences prefs, String key)
        getter,
    required Future<bool> Function(
      SharedPreferences prefs,
      String key,
      TStore value,
    ) setter,
    TSource? defaultValue,
  }) : super(
          key,
          (prefs, key) async {
            final stored = await getter(prefs, key);
            return from(stored);
          },
          (prefs, key, value) async {
            final stored = to(value);
            return setter(prefs, key, stored);
          },
          defaultValue,
        );
}
