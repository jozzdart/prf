import 'package:prf/core/prf_variable.dart';

class PrfInt extends PrfVariable<int> {
  PrfInt(String key, {int? defaultValue})
      : super(
          key,
          (prefs, key) async => prefs.getInt(key),
          (prefs, key, value) async => await prefs.setInt(key, value),
          defaultValue,
        );
}
