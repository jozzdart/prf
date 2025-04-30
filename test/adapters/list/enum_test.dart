import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../utils/fake_prefs.dart';

enum TestEnum { first, second, third }

void main() {
  (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
    final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = store;
    final SharedPreferencesAsync preferences = SharedPreferencesAsync();
    return (preferences, store);
  }

  setUpAll(() async {
    PrfService.resetOverride();
    final (prefs, _) = getPreferences();
    PrfService.overrideWith(prefs);
  });

  group('EnumListAdapter<TestEnum>', () {
    const adapter = EnumListAdapter<TestEnum>(TestEnum.values);

    final enumList = [
      TestEnum.first,
      TestEnum.second,
      TestEnum.third,
      TestEnum.first,
    ];

    final intList = const [0, 1, 2, 0];

    test('encode returns correct list of indices', () {
      final result = adapter.encode(enumList);
      expect(result, intList);
    });

    test('decode returns correct list of enums', () {
      final result = adapter.decode(intList);
      expect(result, enumList);
    });

    test('decode returns null for null input', () {
      expect(adapter.decode(null), isNull);
    });

    test('decode returns null if any index is out of bounds', () {
      expect(adapter.decode([0, 1, -1]), isNull);
      expect(adapter.decode([0, 1, 99]), isNull);
    });

    test('encode empty list returns empty list', () {
      final result = adapter.encode([]);
      expect(result, []);
    });

    test('decode empty list returns empty list', () {
      final result = adapter.decode([]);
      expect(result, []);
    });

    test('getter returns null when no value exists', () async {
      final preferences = PrfService.instance;
      final result = await adapter.getter(preferences, 'test_enum_list');
      expect(result, isNull);
    });

    test('setter stores correct list of indices', () async {
      final preferences = PrfService.instance;
      await adapter.setter(preferences, 'test_enum_list', enumList);

      final prf =
          Prf.customAdapter<List<TestEnum>>('test_enum_list', adapter: adapter);

      final stored = await prf.get();
      expect(stored, enumList);
    });

    test('getter returns correct enum list when value exists', () async {
      final preferences = PrfService.instance;
      final prf =
          Prf.customAdapter<List<TestEnum>>('test_enum_list', adapter: adapter);

      final values = EnumListAdapter(TestEnum.values).decode(intList) ?? [];

      await prf.set(values);

      final result = await adapter.getter(preferences, 'test_enum_list') ?? [];
      expect(result, enumList);
    });

    test('complete round trip: setter followed by getter', () async {
      final preferences = PrfService.instance;
      await adapter.setter(preferences, 'test_enum_list', enumList);
      final result = await adapter.getter(preferences, 'test_enum_list');
      expect(result, enumList);
    });

    test('encode/decode preserves duplicate values', () {
      final list = [TestEnum.second, TestEnum.second, TestEnum.second];
      final encoded = adapter.encode(list);
      final decoded = adapter.decode(encoded);
      expect(decoded, list);
    });

    test('decode returns equal but non-identical objects', () {
      final decoded = adapter.decode(intList)!;
      for (var i = 0; i < decoded.length; i++) {
        expect(decoded[i], enumList[i]);
        expect(identical(decoded[i], enumList[i]), isTrue);
      }
    });

    test('Prf integration: storing and reading empty list works', () async {
      final prf = Prf.customAdapter<List<TestEnum>>(
        'empty_enum_list',
        adapter: adapter,
      );

      await prf.set([]);
      final result = await prf.get();
      expect(result, []);
    });
  });
}
