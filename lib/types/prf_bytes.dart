import 'dart:convert';
import 'dart:typed_data';
import 'package:prf/core/core.dart';

class PrfBytes extends PrfEncoded<Uint8List, String> {
  PrfBytes(super.key, {super.defaultValue})
      : super(
          from: (base64) {
            if (base64 == null) return null;
            try {
              return base64Decode(base64);
            } catch (_) {
              return null; // corrupted or invalid base64
            }
          },
          to: (value) => base64Encode(value),
          getter: (prefs, key) async => prefs.getString(key),
          setter: (prefs, key, value) async => prefs.setString(key, value),
        );
}
