import 'package:prf/prf.dart';

class PrfyEnum<T extends Enum> extends BasePrfObject<T> {
  final EnumAdapter<T> _adapter;

  @override
  EnumAdapter<T> get adapter => _adapter;

  PrfyEnum(super.key, {required List<T> values, super.defaultValue})
      : _adapter = EnumAdapter<T>(values);
}
