import 'package:prf/prf.dart';

/// Extensions for building a persisted history tracker from any `PrfAdapter<List<T>>`.
@Deprecated(
    'PrfListAdapterExtensions has been deprecated. Please update your code to use the new package.')
extension PrfListAdapterExtensions<T> on PrfAdapter<List<T>> {
  /// Creates a `PrfHistory<T>` instance using this adapter.
  ///
  /// This is useful when you have a custom adapter for `List<T>` and want to
  /// track a FIFO-style history with persistence, deduplication, and max-length limits.
  ///
  /// ---
  /// Example:
  /// ```dart
  /// final adapter = JsonListAdapter<MyModel>(
  ///   fromJson: MyModel.fromJson,
  ///   toJson: (m) => m.toJson(),
  /// );
  ///
  /// final history = adapter.historyTracker(
  ///   'my_history',
  ///   maxLength: 100,
  ///   deduplicate: true,
  /// );
  /// ```
  ///
  /// - [name] is the shared preferences key for storage.
  /// - [maxLength] sets the maximum number of items retained in history (default: 50).
  /// - [deduplicate] removes older instances of an item before re-adding it (default: false).
  /// - [useCache] enables fast memory caching via `Prf` instead of `PrfIso` (default: false).
  @Deprecated(
      'historyTracker has been deprecated. Please update your code to use the new package.')
  PrfHistory<T> historyTracker(
    String name, {
    int maxLength = 50,
    bool deduplicate = false,
    bool useCache = false,
  }) {
    return PrfHistory.customAdapter<T>(
      name,
      adapter: this,
      maxLength: maxLength,
      deduplicate: deduplicate,
      useCache: useCache,
    );
  }
}
