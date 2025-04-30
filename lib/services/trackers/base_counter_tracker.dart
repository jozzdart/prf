import 'package:prf/prf.dart';

abstract class BaseCounterTracker extends BaseTracker<int> {
  BaseCounterTracker(super.key, {required super.suffix});

  Future<int> increment([int amount = 1]) async {
    final current = await get();
    final updated = current + amount;
    await value.set(updated);
    return updated;
  }

  @override
  int fallbackValue() => 0;
}
