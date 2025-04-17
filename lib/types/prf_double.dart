import 'package:prf/core/prf_variable.dart';

class PrfDouble extends PrfVariable<double> {
  PrfDouble(String key, {double? defaultValue})
      : super(
          key,
          (prefs, key) async => prefs.getDouble(key),
          (prefs, key, value) async => await prefs.setDouble(key, value),
          defaultValue,
        );
}
