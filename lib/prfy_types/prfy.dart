import 'package:prf/prf.dart';

/// An isolate-safe preference object that provides type-safe access to SharedPreferences.
///
/// Unlike [Prf], this implementation does not cache values in memory, making it
/// suitable for use across isolates but requiring disk reads for each access.
/// Use this when you need preferences that are always consistent across isolates.
///
/// Example:
/// ```dart
/// final settings = Prfy<bool>('dark_mode', defaultValue: false);
/// await settings.set(true);
/// final isDarkMode = await settings.get(); // Always reads from disk
/// ```
class Prfy<T> extends BasePrfObject<T> {
  /// Creates a new isolate-safe preference object with the given [key] and optional [defaultValue].
  Prfy(super.key, {super.defaultValue});

  /// Gets the appropriate adapter for type [T] from the adapter registry.
  @override
  final PrfAdapter<T> adapter = PrfAdapterMap.instance.of<T>();
}
