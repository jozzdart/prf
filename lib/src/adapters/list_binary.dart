import 'dart:convert';
import 'dart:typed_data';

import '../core/encoded_adapter.dart';
import 'adapters.dart';

/// An abstract adapter for encoding and decoding lists of binary data.
///
/// This adapter handles the conversion between a list of type [T] and a
/// Base64-encoded [String] for storage in SharedPreferences. It uses a
/// specified byte size to read and write binary data.
///
/// Subclasses must implement the [read] and [write] methods to define
/// how individual elements of type [T] are read from and written to
/// binary data.
abstract class BinaryListAdapter<T> extends PrfEncodedAdapter<List<T>, String> {
  /// The size in bytes of each element in the list.
  final int byteSize;

  /// Creates a new [BinaryListAdapter] with the given [byteSize].
  ///
  /// The [byteSize] is used to determine how many bytes each element
  /// occupies in the binary data.
  const BinaryListAdapter(this.byteSize) : super(const StringAdapter());

  /// Reads an element of type [T] from the given [ByteData] starting at
  /// the specified [offset].
  ///
  /// This method must be implemented by subclasses to define how an
  /// element is read from binary data.
  T read(ByteData data, int offset);

  /// Writes an element of type [T] to the given [ByteData] starting at
  /// the specified [offset].
  ///
  /// This method must be implemented by subclasses to define how an
  /// element is written to binary data.
  void write(ByteData data, int offset, T value);

  @override

  /// Decodes a Base64-encoded [String] into a list of elements of type [T].
  ///
  /// Returns `null` if the input [base64String] is `null` or if the
  /// decoded byte length is not a multiple of [byteSize].
  List<T>? decode(String? base64String) {
    if (base64String == null) return null;
    try {
      final bytes = base64Decode(base64String);
      if (bytes.length % byteSize != 0) return null;

      final result = <T>[];
      final byteData = ByteData.sublistView(bytes);
      for (var i = 0; i < byteData.lengthInBytes; i += byteSize) {
        result.add(read(byteData, i));
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  @override

  /// Encodes a list of elements of type [T] into a Base64-encoded [String].
  ///
  /// Each element is written to binary data using the [write] method,
  /// and the resulting bytes are encoded as a Base64 [String].
  String encode(List<T> values) {
    final bytes = Uint8List(values.length * byteSize);
    final byteData = ByteData.sublistView(bytes);
    for (var i = 0; i < values.length; i++) {
      write(byteData, i * byteSize, values[i]);
    }
    return base64Encode(bytes);
  }
}
