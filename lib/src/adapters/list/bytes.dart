import 'dart:convert';
import 'dart:typed_data';
import 'package:prf/prf.dart';

/// Adapter for lists of binary data (`Uint8List`).
///
/// Each element is stored as a base64-encoded string,
/// and the list is stored using SharedPreferences' native `List<String>` type.
class BytesListAdapter
    extends PrfEncodedAdapter<List<Uint8List>, List<String>> {
  /// Creates a new adapter for lists of binary data.
  const BytesListAdapter() : super(const StringListAdapter());

  @override
  List<Uint8List>? decode(List<String>? base64List) {
    if (base64List == null) return null;
    try {
      final result = <Uint8List>[];
      for (final base64 in base64List) {
        result.add(base64Decode(base64));
      }
      return result;
    } catch (_) {
      return null; // in case of malformed base64
    }
  }

  @override
  List<String> encode(List<Uint8List> values) {
    return values.map(base64Encode).toList();
  }
}
