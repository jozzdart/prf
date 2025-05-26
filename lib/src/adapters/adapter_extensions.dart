import '../core/base_adapter.dart';
import '../types/prf.dart';

/// Extension on `PrfAdapter<T>` to easily create a `Prf<T>` preference using this adapter.
///
/// This extension is useful when you have a custom adapter (e.g. for JSON, enums, or
/// compressed types) and want to quickly define a persisted variable without
/// manually calling `Prf.customAdapter<T>()` each time.
///
/// ---
///
/// ### Example
/// ```dart
/// final adapter = JsonAdapter<Book>(
///   fromJson: Book.fromJson,
///   toJson: (b) => b.toJson(),
/// );
///
/// final bookPref = adapter.prf('last_opened_book');
/// await bookPref.set(Book(...));
/// ```
extension PrfAdapterExtensions<T> on PrfAdapter<T> {
  /// Creates a [`Prf<T>`] using this adapter and the given key.
  ///
  /// - [key] is the storage key to use in SharedPreferences.
  /// - [defaultValue] is the value to fall back to if no value exists.
  ///
  /// This is equivalent to:
  /// ```dart
  /// Prf.customAdapter<T>('my_key', adapter: myAdapter)
  /// ```
  Prf<T> prf(String key, {T? defaultValue}) {
    return Prf.customAdapter<T>(
      key,
      adapter: this,
      defaultValue: defaultValue,
    );
  }
}
