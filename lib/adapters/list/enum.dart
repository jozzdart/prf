import 'package:prf/prf.dart';

/// Adapter for lists of enum values.
///
/// Stores each enum as its index using the native `List<int>` adapter.
class EnumListAdapter<T extends Enum>
    extends PrfEncodedAdapter<List<T>, List<int>> {
  /// The list of all possible enum values, typically `EnumType.values`.
  final List<T> values;

  /// Creates a new enum list adapter for the given enum [values].
  const EnumListAdapter(this.values) : super(const IntListAdapter());

  @override
  List<T>? decode(List<int>? stored) {
    if (stored == null) return null;
    final result = <T>[];
    for (final index in stored) {
      if (index < 0 || index >= values.length) return null;
      result.add(values[index]);
    }
    return result;
  }

  @override
  List<int> encode(List<T> list) => list.map((e) => e.index).toList();
}
