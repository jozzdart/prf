import 'dart:typed_data';

import 'package:prf/prf.dart';

/// A [NumListAdapter] is a specialized [BinaryListAdapter] for handling
/// lists of numeric values, encoding them as Base64 strings for storage.
///
/// This adapter uses a fixed byte size of 8 for each numeric element,
/// allowing it to store both integer and floating-point numbers.
/// It reads and writes numbers using big-endian byte order.
class NumListAdapter extends BinaryListAdapter<num> {
  /// Creates a new [NumListAdapter] with a fixed byte size of 8.
  const NumListAdapter() : super(8);

  /// Reads a numeric value from the given [ByteData] starting at the specified [offset].
  ///
  /// The value is read as a 64-bit floating-point number using big-endian byte order.
  @override
  num read(ByteData data, int offset) => data.getFloat64(offset, Endian.big);

  /// Writes a numeric value to the given [ByteData] starting at the specified [offset].
  ///
  /// The value is written as a 64-bit floating-point number using big-endian byte order.
  @override
  void write(ByteData data, int offset, num value) =>
      data.setFloat64(offset, value.toDouble(), Endian.big);
}
