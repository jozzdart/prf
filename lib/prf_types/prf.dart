import 'package:prf/prf.dart';

class Prf<T> extends CachedPrfObject<T> {
  Prf(super.key, {super.defaultValue});

  @override
  PrfAdapter<T> get adapter => PrfAdapterMap.instance.of<T>();
}
