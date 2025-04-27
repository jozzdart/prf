import 'package:prf/prf.dart';

class PrfEnum<T extends Enum> extends CachedPrfObject<T> {
  final EnumAdapter<T> _adapter;

  @override
  EnumAdapter<T> get adapter => _adapter;

  PrfEnum(super.key, {required List<T> values, super.defaultValue})
      : _adapter = EnumAdapter<T>(values);
}
