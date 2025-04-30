import 'dart:typed_data';

import 'package:prf/prf.dart';

/// Registry for managing adapters that convert between Dart types and SharedPreferences.
///
/// The adapter map maintains a registry of [PrfAdapter] instances for different types,
/// allowing the PRF library to automatically select the appropriate adapter for each type.
/// It comes with built-in adapters for common types and can be extended with custom adapters.
class PrfAdapterMap {
  /// Internal mapping of types to their adapters.
  final Map<Type, PrfAdapter<dynamic>> _registry = {};

  /// Whether any adapters have been registered yet.
  bool registered = false;

  /// Creates a new adapter registry.
  PrfAdapterMap();

  /// Singleton instance of the adapter registry.
  ///
  /// This instance is used by the PRF library to access adapters.
  static PrfAdapterMap instance = PrfAdapterMap();

  /// Registers an adapter for type [T].
  ///
  /// If an adapter is already registered for type [T] and [override] is false,
  /// the registration will be ignored. Set [override] to true to replace an
  /// existing adapter.
  void register<T>(
    PrfAdapter<T> adapter, {
    bool override = false,
  }) {
    if (override || !_registry.containsKey(T)) {
      _registry[T] = adapter;
    }
  }

  /// Retrieves the adapter for type [T].
  ///
  /// Automatically registers all standard adapters if none have been registered yet.
  /// Throws a [StateError] if no adapter is registered for type [T].
  PrfAdapter<T> of<T>() {
    if (!registered) {
      registerAll();
    }
    final adapter = _registry[T];
    if (adapter == null) {
      throw StateError('No adapter registered for type $T');
    }
    return adapter as PrfAdapter<T>;
  }

  /// Checks if an adapter for type [T] has been registered.
  bool contains<T>() => _registry.containsKey(T);

  /// Registers all standard adapters if none have been registered yet.
  void registerAll() {
    if (registered) return;
    registered = true;
    registerAdapters();
  }

  /// Registers all standard adapters for primitive and common types.
  ///
  /// This includes:
  /// - [bool], [int], [double], [String], and [List<String>]
  /// - [DateTime], [Duration], [BigInt], and [Uint8List]
  void registerAdapters() {
    // Register primitive types
    register<bool>(const BoolAdapter());
    register<int>(const IntAdapter());
    register<double>(const DoubleAdapter());
    register<String>(const StringAdapter());
    register<List<String>>(const StringListAdapter());

    // Register special types
    register<num>(const NumAdapter());
    register<DateTime>(const DateTimeAdapter());
    register<Duration>(const DurationAdapter());
    register<BigInt>(const BigIntAdapter());
    register<Uint8List>(const BytesAdapter());
    register<Uri>(const UriAdapter());

    // List adapters
    register<List<bool>>(const BoolListAdapter());
    register<List<int>>(const IntListAdapter());
    register<List<double>>(const DoubleListAdapter());
    register<List<num>>(const NumListAdapter());
    register<List<Uri>>(const UriListAdapter());
    register<List<Uint8List>>(const BytesListAdapter());
    register<List<Duration>>(const DurationListAdapter64());
    register<List<BigInt>>(const BigIntListAdapter());
    register<List<DateTime>>(const DateTimeListAdapter());
  }
}
