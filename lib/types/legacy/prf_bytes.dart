import 'dart:typed_data';

import 'package:prf/prf.dart';

/// A cached preference for Uint8List.
///
/// This class is deprecated. Use [Prf] directly instead.
///
/// Example:
/// ```dart
/// final bytes = Prf<Uint8List>('bytes');
/// ```
@Deprecated(
    'Use Prf<Uint8List> directly instead. This class will be removed in a future version.')
class PrfBytes extends Prf<Uint8List> {
  /// Creates a new cached bytes preference.
  @Deprecated(
      'Use Prf<Uint8List> directly instead. This constructor will be removed in a future version.')
  PrfBytes(super.key, {super.defaultValue});
}
