import 'package:synchronized/synchronized.dart';

import '../../prf.dart';

/// A persisted, FIFO history tracker using a `Prf<List<T>>`.
///
/// This class provides a history tracker with features such as:
/// - Maximum length trimming: Ensures the history does not exceed a specified length.
/// - Deduplication: Prevents duplicate entries in the history.
/// - Cache toggle: Allows toggling between cached and isolated access.
/// - Isolation-safe access: Ensures thread-safe operations using locks.
///
/// The history is stored in a persistent format using the `Prf` package.
///
/// Example usage:
/// ```dart
/// final history = PrfHistory<String>('example');
/// await history.add('item1');
/// ```
@Deprecated(
    'PrfHistory has been moved to the track package. Please update your imports to use the new package.')
class PrfHistory<T> extends BaseServiceObject {
  final Prf<List<T>> _prfWithCache;
  final int maxLength;
  final bool deduplicate;
  final _lock = Lock();

  /// Returns the key associated with this history tracker.
  String get key => _prfWithCache.key;

  /// Returns the underlying `Prf` object, using cache if enabled.
  BasePrfObject<List<T>> get _prf =>
      useCache ? _prfWithCache : _prfWithCache.isolated;

  /// Default constructor.
  ///
  /// Creates a new `PrfHistory` instance with the specified name.
  ///
  /// [name] is the unique identifier for this history tracker.
  /// [maxLength] specifies the maximum number of items to retain.
  /// [deduplicate] indicates whether to remove duplicate entries.
  PrfHistory(
    String name, {
    this.maxLength = 50,
    this.deduplicate = false,
    super.useCache,
  }) : _prfWithCache = Prf<List<T>>(
          keyFromName(name),
          defaultValue: const [],
        );

  /// Adapter-based constructor.
  ///
  /// Creates a new `PrfHistory` instance with a custom adapter.
  ///
  /// [name] is the unique identifier for this history tracker.
  /// [adapter] is the custom adapter for handling persistence.
  PrfHistory._withAdapter(
    String name, {
    required PrfAdapter<List<T>> adapter,
    this.maxLength = 50,
    this.deduplicate = false,
    super.useCache,
  }) : _prfWithCache = Prf.customAdapter<List<T>>(
          keyFromName(name),
          adapter: adapter,
          defaultValue: const [],
        );

  /// Custom adapter-based factory.
  ///
  /// Creates a new `PrfHistory` instance with a custom adapter.
  ///
  /// [name] is the unique identifier for this history tracker.
  /// [adapter] is the custom adapter for handling persistence.
  static PrfHistory<T> customAdapter<T>(
    String name, {
    required PrfAdapter<List<T>> adapter,
    int maxLength = 50,
    bool deduplicate = false,
    bool useCache = false,
  }) =>
      PrfHistory._withAdapter(
        keyFromName(name),
        adapter: adapter,
        maxLength: maxLength,
        deduplicate: deduplicate,
        useCache: useCache,
      );

  /// JSON-based factory.
  ///
  /// Creates a new `PrfHistory` instance using JSON serialization.
  ///
  /// [name] is the unique identifier for this history tracker.
  /// [fromJson] is a function to deserialize JSON into an object.
  /// [toJson] is a function to serialize an object into JSON.
  static PrfHistory<T> json<T>(
    String name, {
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
    int maxLength = 50,
    bool deduplicate = false,
    bool useCache = false,
  }) =>
      PrfHistory._withAdapter(
        keyFromName(name),
        adapter: JsonListAdapter<T>(
          fromJson: fromJson,
          toJson: toJson,
        ),
        maxLength: maxLength,
        deduplicate: deduplicate,
        useCache: useCache,
      );

  /// Enum-based factory.
  ///
  /// Creates a new `PrfHistory` instance for enum types.
  ///
  /// [name] is the unique identifier for this history tracker.
  /// [values] is the list of enum values to be stored.
  static PrfHistory<T> enumerated<T extends Enum>(
    String name, {
    required List<T> values,
    int maxLength = 50,
    bool deduplicate = false,
    bool useCache = false,
  }) =>
      PrfHistory._withAdapter(
        keyFromName(name),
        adapter: EnumListAdapter<T>(values),
        maxLength: maxLength,
        deduplicate: deduplicate,
        useCache: useCache,
      );

  /// Adds an item to the front (most recent).
  ///
  /// [value] is the item to be added to the history.
  ///
  /// If [deduplicate] is true, any existing instance of [value] will be removed before adding.
  /// The history is trimmed to [maxLength] if necessary.
  Future<void> add(T value) => _lock.synchronized(() async {
        final list = List<T>.from(await _prf.get() ?? const []);
        if (deduplicate) list.remove(value);
        list.insert(0, value);
        if (list.length > maxLength) list.length = maxLength;
        await _prf.set(list);
      });

  /// Replaces the entire history list.
  ///
  /// [values] is the new list of items to set as the history.
  ///
  /// If [deduplicate] is true, duplicates in [values] will be removed.
  /// The list is trimmed to [maxLength] if necessary.
  Future<void> setAll(List<T> values) => _lock.synchronized(() async {
        final deduped = deduplicate ? values.toSet().toList() : [...values];
        final trimmed = deduped.take(maxLength).toList();
        await _prf.set(trimmed);
      });

  /// Removes an item by value.
  ///
  /// [value] is the item to be removed from the history.
  Future<void> remove(T value) => _lock.synchronized(() async {
        final list = List<T>.from(await _prf.get() ?? const []);
        list.remove(value);
        await _prf.set(list);
      });

  /// Removes all items matching the condition.
  ///
  /// [predicate] is a function that returns true for items to be removed.
  Future<void> removeWhere(bool Function(T) predicate) =>
      _lock.synchronized(() async {
        final list = List<T>.from(await _prf.get() ?? const []);
        list.removeWhere(predicate);
        await _prf.set(list);
      });

  /// Clears all items (resets to empty list).
  Future<void> clear() => _lock.synchronized(() => _prf.set([]));

  /// Deletes the history and the key from storage.
  Future<void> removeKey() => _lock.synchronized(() => _prf.remove());

  /// Checks if the key exists in storage.
  ///
  /// Returns true if the key exists, false otherwise.
  Future<bool> exists() => _prf.existsOnPrefs();

  /// Returns the full list (most recent first).
  ///
  /// Returns a list of all items in the history.
  Future<List<T>> getAll() async => await _prf.get() ?? const [];

  /// Checks if the list contains a value.
  ///
  /// [value] is the item to check for in the history.
  ///
  /// Returns true if [value] is found, false otherwise.
  Future<bool> contains(T value) async => (await getAll()).contains(value);

  /// Returns the number of items.
  ///
  /// Returns the count of items in the history.
  Future<int> length() async => (await getAll()).length;

  /// Returns true if empty.
  ///
  /// Returns true if the history is empty, false otherwise.
  Future<bool> isEmpty() async => (await getAll()).isEmpty;

  /// Returns the most recent value, or null.
  ///
  /// Returns the first item in the history, or null if empty.
  Future<T?> first() async => (await getAll()).firstOrNull;

  /// Returns the oldest value, or null.
  ///
  /// Returns the last item in the history, or null if empty.
  Future<T?> last() async => (await getAll()).lastOrNull;

  /// Generates a key from the given name.
  ///
  /// [name] is the base name for generating the key.
  ///
  /// Returns a string key for the history tracker.
  static String keyFromName(String name) => "history_tracker_$name";
}

/// Extension for safe list access.
extension _SafeListAccess<T> on List<T> {
  /// Returns the first item or null if the list is empty.
  T? get firstOrNull => isNotEmpty ? first : null;

  /// Returns the last item or null if the list is empty.
  T? get lastOrNull => isNotEmpty ? last : null;
}
