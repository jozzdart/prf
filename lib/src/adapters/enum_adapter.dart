import '../core/encoded_adapter.dart';
import 'adapters.dart';

/// Adapter for Enum values.
///
/// Stores enum values as their integer indices.
class EnumAdapter<T extends Enum> extends PrfEncodedAdapter<T, int> {
  /// The list of all possible enum values in their declaration order.
  final List<T> values;

  /// Creates a new enum adapter with the specified list of enum values.
  ///
  /// The [values] list should contain all possible values of the enum,
  /// typically obtained via `EnumType.values`.
  const EnumAdapter(this.values) : super(const IntAdapter());

  @override
  T? decode(int? index) {
    if (index == null || index < 0 || index >= values.length) {
      return null;
    }
    return values[index];
  }

  @override
  int encode(T value) => value.index;
}
