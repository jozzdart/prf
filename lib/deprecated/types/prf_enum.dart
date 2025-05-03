import 'package:prf/prf.dart';

/// A cached preference object for enum values.
///
/// This class is deprecated. Use [Prf.enumerated] factory method instead.
///
/// Example:
/// ```dart
/// final theme = Prf.enumerated<Theme>(
///   'theme',
///   values: Theme.values,
///   defaultValue: Theme.light,
/// );
/// ```
@Deprecated(
    'Use Prf.enumerated factory method instead. This class will be removed in a future version.')
class PrfEnum<T extends Enum> extends CachedPrfObject<T> {
  /// The adapter used for enum value conversion.
  final EnumAdapter<T> _adapter;

  @override
  EnumAdapter<T> get adapter => _adapter;

  @Deprecated(
      'Use Prf.enumerated factory method instead. This constructor will be removed in a future version.')
  PrfEnum(super.key, {required List<T> values, super.defaultValue})
      : _adapter = EnumAdapter<T>(values);
}
