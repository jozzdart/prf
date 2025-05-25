import 'dart:typed_data';
import 'package:prf/prf.dart';

/// Adapter for lists of integers.
///
/// Stores integer lists as base64-encoded binary data, with each integer
/// represented as a 4-byte big-endian value.
class IntListAdapter extends BinaryListAdapter<int> {
  const IntListAdapter() : super(4);

  @override
  int read(ByteData data, int offset) => data.getInt32(offset, Endian.big);

  @override
  void write(ByteData data, int offset, int value) =>
      data.setInt32(offset, value, Endian.big);
}
