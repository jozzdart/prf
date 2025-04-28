import 'package:prf/prf.dart';

/// An isolate-safe preference object.
///
/// This class is deprecated. Use [PrfIso] instead.
///
/// Example:
/// ```dart
/// final username = PrfIso<String>('username');
/// ```
@Deprecated(
    'Use PrfIso instead. This class will be removed in a future version.')
class Prfy<T> extends BasePrfObject<T> {
  /// Creates a new isolate-safe preference object with the given [key] and optional [defaultValue].
  @Deprecated(
      'Use PrfIso instead. This class will be removed in a future version.')
  Prfy(super.key, {super.defaultValue});

  /// Gets the appropriate adapter for type [T] from the adapter registry.
  @override
  final PrfAdapter<T> adapter = PrfAdapterMap.instance.of<T>();
}
