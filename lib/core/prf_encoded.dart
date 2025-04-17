import 'package:prf/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrfEncoded<TSource, TStore> extends PrfVariable<TSource> {
  PrfEncoded(
    String key, {
    required Decode<TSource, TStore> from,
    required Encode<TSource, TStore> to,
    required Future<TStore?> Function(SharedPreferences prefs, String key)
        getter,
    required Future<bool> Function(
      SharedPreferences prefs,
      String key,
      TStore value,
    ) setter,
    TSource? defaultValue,
  }) : super(
          key,
          (prefs, key) async {
            final stored = await getter(prefs, key);
            return from(stored);
          },
          (prefs, key, value) async {
            final stored = to(value);
            return setter(prefs, key, stored);
          },
          defaultValue,
        );
}
