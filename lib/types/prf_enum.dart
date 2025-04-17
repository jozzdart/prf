import 'package:prf/prf.dart';

class PrfEnum<T extends Enum> extends PrfEncoded<T, int> {
  PrfEnum(super.key, {required List<T> values, super.defaultValue})
      : super(
          from: (index) {
            if (index == null || index < 0 || index >= values.length)
              return null;
            return values[index];
          },
          to: (e) => e.index,
          getter: (prefs, key) async => prefs.getInt(key),
          setter: (prefs, key, value) async => prefs.setInt(key, value),
        );
}
