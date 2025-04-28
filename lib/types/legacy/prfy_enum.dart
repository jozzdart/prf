import 'package:prf/prf.dart';

/// An isolate-safe enum preference.
///
/// This class is deprecated. Use [PrfIso.enumerated] instead.
///
/// Example:
/// ```dart
/// final theme = PrfIso.enumerated<Theme>('theme', values: Theme.values);
/// ```
@Deprecated(
    'Use PrfIso.enumerated instead. This class will be removed in a future version.')
class PrfyEnum<T extends Enum> extends BasePrfObject<T> {
  /// The adapter used for enum value conversion.
  final EnumAdapter<T> _adapter;

  @override

  /// Gets the adapter used to convert between the enum and its storage representation.
  EnumAdapter<T> get adapter => _adapter;

  /// Creates a new isolate-safe enum preference.
  ///
  /// - [key] is the key to store the preference under.
  /// - [values] is the list of all possible enum values, typically EnumType.values.
  /// - [defaultValue] is the optional default value to use when no value exists.
  @Deprecated(
      'Use PrfIso.enumerated instead. This constructor will be removed in a future version.')
  PrfyEnum(super.key, {required List<T> values, super.defaultValue})
      : _adapter = EnumAdapter<T>(values);
}
