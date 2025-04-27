import 'package:prf/prf.dart';

extension PrfOperationExtensions<T> on BasePrfObject<T> {
  Future<T?> get() async {
    return await getValue(PrfService.instance);
  }

  Future<void> set(T value) async {
    await setValue(PrfService.instance, value);
  }

  Future<void> remove() async {
    await removeValue(PrfService.instance);
  }

  Future<bool> isNull() async {
    return await isValueNull(PrfService.instance);
  }

  Future<T> getOrFallback(T fallback) async {
    return (await get()) ?? fallback;
  }

  Future<bool> existsOnPrefs() async {
    return await PrfService.instance.containsKey(key);
  }
}
