import 'package:prf/prf.dart';

/// A cached preference object for String values.
///
/// This class is deprecated. Use [Prf] instead.
///
/// Example:
/// ```dart
/// final username = Prf<String>('username');
/// ```
@Deprecated('Use Prf instead. This class will be removed in a future version.')
class PrfString extends Prf<String> {
  /// Creates a new cached String preference.
  @Deprecated(
      'Use Prf instead. This constructor will be removed in a future version.')
  PrfString(super.key, {super.defaultValue});
}
