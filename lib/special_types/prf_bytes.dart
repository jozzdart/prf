import 'dart:convert';
import 'dart:typed_data';
import 'package:prf/core/prf_encoded.dart';

/// A type-safe wrapper for storing and retrieving binary data (Uint8List) in SharedPreferences.
///
/// This class automatically handles the conversion between binary data and base64 encoded strings
/// for storage in SharedPreferences.
///
/// Use this class for storing binary data like images, cryptographic keys,
/// or any other raw byte content.
///
/// Example:
/// ```dart
/// final imageData = PrfBytes('profile_image');
/// await imageData.set(Uint8List.fromList([...]));
/// final bytes = await imageData.get();
/// ```
class PrfBytes extends PrfEncoded<Uint8List, String> {
  /// Creates a new bytes preference variable with the specified [key].
  ///
  /// The optional [defaultValue] is returned if the preference is not found
  /// or if an error occurs while reading.
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
          getter: (prefs, key) async => await prefs.getString(key),
          setter: (prefs, key, value) async =>
              await prefs.setString(key, value),
        );
}
