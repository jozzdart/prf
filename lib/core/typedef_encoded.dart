typedef Encode<TSource, TStore> = TStore Function(TSource value);
typedef Decode<TSource, TStore> = TSource? Function(TStore? stored);
