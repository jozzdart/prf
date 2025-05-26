import '../core/encoded_adapter.dart';

/// A function type that defines how to decode a stored string into an object of type [T].
typedef DecodeFunction<T, TStored> = T? Function(TStored? stored);

/// A function type that defines how to encode an object of type [T] into a string.
typedef EncodeFunction<T, TStored> = TStored Function(T value);

/// A generic adapter for encoding and decoding objects of type [T] to and from a storage type [TStore].
///
/// This class extends [PrfEncodedAdapter] and allows for custom encoding and decoding
/// logic to be provided via [decodeFunc] and [encodeFunc]. It is useful for cases where
/// the default encoding/decoding logic does not suffice or when dealing with custom types.
class EncodedDelegateAdapter<T, TStore> extends PrfEncodedAdapter<T, TStore> {
  /// The function used to decode a stored value of type [TStore] into an object of type [T].
  final DecodeFunction<T, TStore> decodeFunc;

  /// The function used to encode an object of type [T] into a value of type [TStore].
  final EncodeFunction<T, TStore> encodeFunc;

  /// Creates a new instance of [EncodedDelegateAdapter] with the provided encoding and decoding functions.
  ///
  /// - [decodeFunc]: A function that takes a [TStore] and returns an object of type [T] or null.
  /// - [encodeFunc]: A function that takes an object of type [T] and returns a [TStore].
  const EncodedDelegateAdapter(
    super._storingAdapter, {
    required this.decodeFunc,
    required this.encodeFunc,
  });

  @override
  T? decode(TStore? stored) {
    return decodeFunc(stored);
  }

  @override
  TStore encode(T value) {
    return encodeFunc(value);
  }
}
