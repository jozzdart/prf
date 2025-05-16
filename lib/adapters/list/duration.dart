import 'dart:typed_data';
import 'package:prf/prf.dart';

/// Adapter for lists of [Duration] objects.
///
/// Stores each Duration as a 4-byte big-endian integer representing microseconds.
class DurationListAdapter extends BinaryListAdapter<Duration> {
  const DurationListAdapter() : super(8);

  @override
  Duration read(ByteData data, int offset) {
    final high = data.getUint32(offset, Endian.big);
    final low = data.getUint32(offset + 4, Endian.big);
    final micros = (high << 32) | low;
    return Duration(microseconds: micros);
  }

  @override
  void write(ByteData data, int offset, Duration value) {
    final micros = value.inMicroseconds;
    data.setUint32(offset, micros >> 32, Endian.big); // high 32 bits
    data.setUint32(offset + 4, micros & 0xFFFFFFFF, Endian.big); // low 32 bits
  }
}
