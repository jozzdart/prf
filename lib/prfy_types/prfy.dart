import 'package:prf/prf.dart';

class Prfy<T> extends BasePrfObject<T> {
  Prfy(super.key, {super.defaultValue});

  @override
  final PrfAdapter<T> adapter = PrfAdapterMap.instance.of<T>();
}
