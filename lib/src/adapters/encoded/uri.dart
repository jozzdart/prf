import '../../core/encoded_adapter.dart';
import '../adapters.dart';

/// Adapter for URI values.
///
/// Stores URI values as strings in SharedPreferences.
/// Uses [Uri.tryParse] for safe parsing of stored strings back to URI objects.
class UriAdapter extends PrfEncodedAdapter<Uri, String> {
  /// Creates a new URI adapter.
  const UriAdapter() : super(const StringAdapter());

  @override
  Uri? decode(String? stored) {
    if (stored == null) return null;
    return Uri.tryParse(stored);
  }

  @override
  String encode(Uri value) => value.toString();
}
