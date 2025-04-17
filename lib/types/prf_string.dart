import 'package:prf/core/prf_variable.dart';

class PrfString extends PrfVariable<String> {
  PrfString(String key, {String? defaultValue})
      : super(
          key,
          (prefs, key) async => prefs.getString(key),
          (prefs, key, value) async => await prefs.setString(key, value),
          defaultValue,
        );
}
