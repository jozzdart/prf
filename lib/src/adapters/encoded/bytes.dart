import 'dart:convert';
import 'dart:typed_data';

import '../../core/encoded_adapter.dart';
import '../adapters.dart';

/// Adapter for binary data (Uint8List).
///
/// Stores binary data as base64-encoded strings.
class BytesAdapter extends PrfEncodedAdapter<Uint8List, String> {
  /// Creates a new binary data adapter.
  const BytesAdapter() : super(const StringAdapter());

  @override
  Uint8List? decode(String? base64) {
    if (base64 == null) return null;
    try {
      return base64Decode(base64);
    } catch (_) {
      return null; // corrupted or invalid base64
    }
  }

  @override
  String encode(Uint8List value) => base64Encode(value);
}
