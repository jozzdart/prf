import 'dart:convert';
import 'dart:typed_data';
import 'package:prf/core/prf_encoded.dart';

/// A type-safe wrapper for storing and retrieving DateTime values in SharedPreferences.
///
/// This class automatically handles the conversion between DateTime objects and
/// their binary representation (encoded as base64 strings for storage).
///
/// Use this class for storing timestamps, event dates, user registration dates,
/// or any time-related data.
///
/// Example:
/// ```dart
/// final lastLogin = PrfDateTime('last_login');
/// await lastLogin.set(DateTime.now());
/// final loginTime = await lastLogin.get();
/// ```
class PrfDateTime extends PrfEncoded<DateTime, String> {
  /// Creates a new DateTime preference variable with the specified [key].
  ///
  /// The optional [defaultValue] is returned if the preference is not found
  /// or if an error occurs while reading.
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
