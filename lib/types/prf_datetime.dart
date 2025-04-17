import 'dart:convert';
import 'dart:typed_data';
import 'package:prf/core/prf_encoded.dart';

class PrfDateTime extends PrfEncoded<DateTime, String> {
  PrfDateTime(super.key, {super.defaultValue})
      : super(
          from: (base64) {
            if (base64 == null) return null;
            try {
              final bytes = base64Decode(base64);
              final millis =
                  ByteData.sublistView(bytes).getInt64(0, Endian.big);
              return DateTime.fromMillisecondsSinceEpoch(millis);
            } catch (_) {
              return null;
            }
          },
          to: (dateTime) {
            final buffer = ByteData(8);
            buffer.setInt64(0, dateTime.millisecondsSinceEpoch, Endian.big);
            return base64Encode(buffer.buffer.asUint8List());
          },
          getter: (prefs, key) async => prefs.getString(key),
          setter: (prefs, key, value) async =>
              await prefs.setString(key, value),
        );
}
