import 'dart:convert';
import 'dart:typed_data';

import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class PrfEncodedAdapter<T, TStore> extends PrfAdapter<T> {
  final PrfAdapter<TStore> _storingAdapter =
      PrfAdapterMap.instance.of<TStore>();

  @override
  Future<T?> getter(SharedPreferencesAsync prefs, String key) async {
    final getRaw = await _storingAdapter.getter(prefs, key);
    return decode(getRaw);
  }

  @override
  Future<void> setter(SharedPreferencesAsync prefs, String key, T value) async {
    final encoded = encode(value);
    await _storingAdapter.setter(prefs, key, encoded);
  }

  TStore encode(T value);

  T? decode(TStore? stored);

  PrfEncodedAdapter();
}

class EnumAdapter<T extends Enum> extends PrfEncodedAdapter<T, int> {
  final List<T> values;

  EnumAdapter(this.values);

  @override
  T? decode(int? index) {
    if (index == null || index < 0 || index >= values.length) {
      return null;
    }
    return values[index];
  }

  @override
  int encode(T value) => value.index;
}

/// JSON adapter implementation that requires fromJson and toJson converters
class JsonAdapter<T> extends PrfEncodedAdapter<T, String> {
  final T Function(Map<String, dynamic> json) fromJson;
  final Map<String, dynamic> Function(T object) toJson;

  JsonAdapter({required this.fromJson, required this.toJson});

  @override
  T? decode(String? jsonString) {
    if (jsonString == null) return null;
    try {
      final map = jsonDecode(jsonString);
      if (map is Map<String, dynamic>) {
        return fromJson(map);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  String encode(T value) => jsonEncode(toJson(value));
}

class DateTimeAdapter extends PrfEncodedAdapter<DateTime, String> {
  DateTimeAdapter();

  @override
  DateTime? decode(String? base64) {
    if (base64 == null) return null;
    try {
      final bytes = base64Decode(base64);
      if (bytes.length < 8) return null; // Too short to contain a timestamp
      final micros = ByteData.sublistView(bytes).getInt64(0, Endian.big);
      return DateTime.fromMicrosecondsSinceEpoch(micros);
    } catch (_) {
      return null;
    }
  }

  @override
  String encode(DateTime dateTime) {
    final buffer = ByteData(8);
    buffer.setInt64(0, dateTime.microsecondsSinceEpoch, Endian.big);
    return base64Encode(buffer.buffer.asUint8List());
  }
}

/// Duration adapter implementation
class DurationAdapter extends PrfEncodedAdapter<Duration, int> {
  DurationAdapter();

  @override
  Duration? decode(int? stored) {
    if (stored == null) return null;
    return Duration(microseconds: stored);
  }

  @override
  int encode(Duration value) => value.inMicroseconds;
}

/// BigInt adapter implementation
class BigIntAdapter extends PrfEncodedAdapter<BigInt, String> {
  BigIntAdapter();

  @override
  BigInt? decode(String? base64) {
    if (base64 == null) return null;
    try {
      final bytes = base64Decode(base64);
      if (bytes.isEmpty) return BigInt.zero;

      // First byte indicates sign (0 for positive, 1 for negative)
      final isNegative = bytes[0] == 1;

      // Remaining bytes are the magnitude
      var result = BigInt.zero;
      for (var i = 1; i < bytes.length; i++) {
        result = (result << 8) | BigInt.from(bytes[i]);
      }

      return isNegative ? -result : result;
    } catch (_) {
      return null; // Invalid format
    }
  }

  @override
  String encode(BigInt bigInt) {
    // Convert to efficient binary representation
    final isNegative = bigInt.isNegative;
    final magnitude = bigInt.abs();

    // Calculate how many bytes we need
    var tempMag = magnitude;
    var byteCount = 0;
    do {
      byteCount++;
      tempMag = tempMag >> 8;
    } while (tempMag > BigInt.zero);

    // Create a byte array with an extra byte for the sign
    final bytes = Uint8List(byteCount + 1);

    // First byte indicates sign (0 for positive, 1 for negative)
    bytes[0] = isNegative ? 1 : 0;

    // Fill in the magnitude bytes in big-endian order
    var tempValue = magnitude;
    for (var i = byteCount; i > 0; i--) {
      bytes[i] = (tempValue & BigInt.from(0xFF)).toInt();
      tempValue = tempValue >> 8;
    }

    return base64Encode(bytes);
  }
}

/// Bytes (Uint8List) adapter implementation
class BytesAdapter extends PrfEncodedAdapter<Uint8List, String> {
  BytesAdapter();

  @override
  Uint8List? decode(String? base64) {
    if (base64 == null) return null;
    try {
      return base64Decode(base64);
    } catch (_) {
      return null; // corrupted or invalid base64
    }
  }

  @override
  String encode(Uint8List value) => base64Encode(value);
}
