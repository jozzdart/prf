/// Function type for encoding a source type [TSource] to a storage type [TStore].
///
/// Used to convert objects from their in-memory representation to a format
/// that can be stored in SharedPreferences.
typedef Encode<TSource, TStore> = TStore Function(TSource value);

/// Function type for decoding a storage type [TStore] back to source type [TSource].
///
/// Used to convert objects from their storage format back to their
/// in-memory representation. May return null if decoding fails.
typedef Decode<TSource, TStore> = TSource? Function(TStore? stored);
