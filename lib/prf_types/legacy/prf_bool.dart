import 'package:prf/prf.dart';

/// A cached boolean preference.
///
/// This class is deprecated. Use [Prf] instead.
///
/// Example:
/// ```dart
/// final darkMode = Prf<bool>('dark_mode');
/// ```
@Deprecated('Use Prf instead. This class will be removed in a future version.')
class PrfBool extends Prf<bool> {
  /// Creates a new boolean preference.
  @Deprecated(
      'Use Prf instead. This constructor will be removed in a future version.')
  PrfBool(super.key, {super.defaultValue});
}
