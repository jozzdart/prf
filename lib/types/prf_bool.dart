import 'package:prf/core/prf_variable.dart';

class PrfBool extends PrfVariable<bool> {
  PrfBool(String key, {bool? defaultValue})
      : super(
          key,
          (prefs, key) async => prefs.getBool(key),
          (prefs, key, value) async => await prefs.setBool(key, value),
          defaultValue,
        );
}
