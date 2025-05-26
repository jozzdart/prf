import '../../core/encoded_adapter.dart';
import '../adapters.dart';

/// Adapter for numeric values.
///
/// Stores numeric values as doubles in SharedPreferences.
/// This adapter can handle both integer and floating-point numbers,
/// converting them to and from double values.
class NumAdapter extends PrfEncodedAdapter<num, double> {
  /// Creates a new numeric adapter.
  const NumAdapter() : super(const DoubleAdapter());

  @override
  num? decode(double? stored) => stored;

  @override
  double encode(num value) => value.toDouble();
}
