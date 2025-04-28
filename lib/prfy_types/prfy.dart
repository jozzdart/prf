import 'package:prf/prf.dart';

/// An isolate-safe preference object.
///
/// This class is deprecated. Use [Prfi] instead.
///
/// Example:
/// ```dart
/// final username = Prfi<String>('username');
/// ```
@Deprecated('Use Prfi instead. This class will be removed in a future version.')
class Prfy<T> extends BasePrfObject<T> {
  /// Creates a new isolate-safe preference object with the given [key] and optional [defaultValue].
  @Deprecated(
      'Use Prfi instead. This class will be removed in a future version.')
  Prfy(super.key, {super.defaultValue});

  /// Gets the appropriate adapter for type [T] from the adapter registry.
  @override
  final PrfAdapter<T> adapter = PrfAdapterMap.instance.of<T>();
}
