import 'dart:typed_data';
import 'package:prf/prf.dart';

/// Adapter for lists of doubles.
///
/// Stores double lists as base64-encoded binary data, with each double
/// represented as an 8-byte IEEE 754 double-precision floating-point number.
class DoubleListAdapter extends BinaryListAdapter<double> {
  const DoubleListAdapter() : super(8);

  @override
  double read(ByteData data, int offset) => data.getFloat64(offset, Endian.big);

  @override
  void write(ByteData data, int offset, double value) =>
      data.setFloat64(offset, value, Endian.big);
}
