import 'package:prf/core/prf_variable.dart';

class PrfStringList extends PrfVariable<List<String>> {
  PrfStringList(String key, {List<String>? defaultValue})
      : super(
          key,
          (prefs, key) async => prefs.getStringList(key),
          (prefs, key, value) async => await prefs.setStringList(key, value),
          defaultValue,
        );
}
