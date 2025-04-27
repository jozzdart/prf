import 'dart:typed_data';
import 'package:prf/core/encoded_adapters.dart';
import 'package:prf/core/adapters.dart';

/// Registry for PrfAdapter instances
class PrfAdapterMap {
  final Map<Type, PrfAdapter<dynamic>> _registry = {};

  /// Returns true if any adapters have been registered
  bool registered = false;

  /// Creates a new adapter registry
  PrfAdapterMap();

  /// Singleton instance of the adapter registry
  static PrfAdapterMap instance = PrfAdapterMap();

  /// Registers an adapter for type [T] if not already registered.
  /// Set [override] to true to replace an existing adapter.
  void register<T>(
    PrfAdapter<T> adapter, {
    bool override = false,
  }) {
    if (override || !_registry.containsKey(T)) {
      _registry[T] = adapter;
    }
  }

  /// Retrieves the adapter for type [T].
  /// Registers all adapters if none have been registered yet.
  /// For enum types, tries to use a pre-registered enum adapter.
  /// Throws if no adapter is registered for type [T].
  /// Retrieves the adapter for type [T]. Throws if not registered.
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

  /// Returns true if an adapter for type [T] has been registered.
  bool contains<T>() => _registry.containsKey(T);

  /// Registers all adapters if none have been registered yet.
  void registerAll() {
    if (registered) return;
    registered = true;
    registerAdapters();
  }

  /// Registers all standard adapters
  void registerAdapters() {
    // Register primitive types
    register<bool>(const BoolAdapter());
    register<int>(const IntAdapter());
    register<double>(const DoubleAdapter());
    register<String>(const StringAdapter());
    register<List<String>>(const StringListAdapter());

    // Register special types
    register<DateTime>(DateTimeAdapter());
    register<Duration>(DurationAdapter());
    register<BigInt>(BigIntAdapter());
    register<Uint8List>(BytesAdapter());
  }
}
