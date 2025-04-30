import 'dart:typed_data';
import 'package:prf/prf.dart';

/// Adapter for lists of [Duration] objects.
///
/// Stores each Duration as a 4-byte big-endian integer representing microseconds.
class DurationListAdapter64 extends BinaryListAdapter<Duration> {
  const DurationListAdapter64() : super(8);

  @override
  Duration read(ByteData data, int offset) =>
      Duration(microseconds: data.getInt64(offset, Endian.big));

  @override
  void write(ByteData data, int offset, Duration value) =>
      data.setInt64(offset, value.inMicroseconds, Endian.big);
}
