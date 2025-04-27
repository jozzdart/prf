import 'dart:typed_data';

import 'package:prf/prf.dart';

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
@Deprecated(
    'Use Prf<Uint8List> instead for cached access or Prfy<Uint8List> for isolate-safe access')
class PrfBytes extends Prf<Uint8List> {
  /// Creates a new bytes preference variable with the specified [key].
  ///
  /// The optional [defaultValue] is returned if the preference is not found
  /// or if an error occurs while reading.
  PrfBytes(super.key, {super.defaultValue});
}
