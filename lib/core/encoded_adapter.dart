import 'package:prf/core/base_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base adapter for types that need encoding before storing in SharedPreferences.
///
/// This abstract class handles the conversion between a type [T] and a storage type [TStore]
/// that is directly supported by SharedPreferences (like String or int).
/// Implementations need to provide [encode] and [decode] methods.
abstract class PrfEncodedAdapter<T, TStore> extends PrfAdapter<T> {
  /// The adapter used to store the encoded values.
  final PrfAdapter<TStore> _storingAdapter;

  @override
  Future<T?> getter(SharedPreferencesAsync prefs, String key) async {
    final getRaw = await _storingAdapter.getter(prefs, key);
    return decode(getRaw);
  }

  @override
  Future<void> setter(SharedPreferencesAsync prefs, String key, T value) async {
    final encoded = encode(value);
    await _storingAdapter.setter(prefs, key, encoded);
  }

  /// Encodes a value of type [T] to the storage type [TStore].
  TStore encode(T value);

  /// Decodes a value of storage type [TStore] back to type [T].
  ///
  /// Returns null if the stored value is null or cannot be decoded.
  T? decode(TStore? stored);

  /// Creates a new encoded adapter.
  const PrfEncodedAdapter(this._storingAdapter);
}
