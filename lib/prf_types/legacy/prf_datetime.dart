import 'package:prf/prf.dart';

/// A cached DateTime preference.
///
/// This class is deprecated. Use [Prf] instead.
///
/// Example:
/// ```dart
/// final lastUpdated = Prf<DateTime>('last_updated');
/// ```
@Deprecated('Use Prf instead. This class will be removed in a future version.')
class PrfDateTime extends Prf<DateTime> {
  /// Creates a new DateTime preference.
  @Deprecated(
      'Use Prf instead. This constructor will be removed in a future version.')
  PrfDateTime(super.key, {super.defaultValue});
}
