import '../../core/encoded_adapter.dart';
import '../adapters.dart';

/// Adapter for lists of [BigInt] values.
///
/// Each BigInt is stored as a base64-encoded string using [BigIntAdapter],
/// and the list is stored using SharedPreferences' native List&lt;String> support.
class BigIntListAdapter extends PrfEncodedAdapter<List<BigInt>, List<String>> {
  const BigIntListAdapter() : super(const StringListAdapter());

  static const BigIntAdapter _elementAdapter = BigIntAdapter();

  @override
  List<BigInt>? decode(List<String>? base64List) {
    if (base64List == null) return null;
    try {
      final result = <BigInt>[];
      for (final base64 in base64List) {
        final value = _elementAdapter.decode(base64);
        if (value == null) return null; // fail fast on invalid entry
        result.add(value);
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  @override
  List<String> encode(List<BigInt> values) {
    return values.map(_elementAdapter.encode).toList();
  }
}
