import 'package:prf/prf.dart';

/// A cached string list preference.
///
/// This class is deprecated. Use [Prf] instead.
///
/// Example:
/// ```dart
/// final tags = Prf<List<String>>('tags');
/// ```
@Deprecated('Use Prf instead. This class will be removed in a future version.')
class PrfStringList extends Prf<List<String>> {
  /// Creates a new string list preference.
  @Deprecated(
      'Use Prf instead. This constructor will be removed in a future version.')
  PrfStringList(super.key, {super.defaultValue});
}
