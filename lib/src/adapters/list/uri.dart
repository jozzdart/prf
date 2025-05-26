import '../../core/encoded_adapter.dart';
import '../adapters.dart';

/// Adapter for lists of [Uri] objects.
///
/// Each URI is stored as a string, and the list is stored using
/// SharedPreferences' native `List<String>` support.
class UriListAdapter extends PrfEncodedAdapter<List<Uri>, List<String>> {
  const UriListAdapter() : super(const StringListAdapter());

  @override
  List<Uri>? decode(List<String>? stored) {
    if (stored == null) return null;
    final result = <Uri>[];
    for (final s in stored) {
      final uri = Uri.tryParse(s);
      if (uri == null) return null; // abort if any URI fails
      result.add(uri);
    }
    return result;
  }

  @override
  List<String> encode(List<Uri> values) {
    return values.map((u) => u.toString()).toList();
  }
}
