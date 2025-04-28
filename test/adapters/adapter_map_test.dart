import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:prf/adapters/adapter_map.dart';
import 'package:prf/adapters/native_adapters.dart';
import 'package:prf/core/base_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomType {}

class CustomAdapter extends PrfAdapter<CustomType> {
  @override
  Future<CustomType?> getter(SharedPreferencesAsync prefs, String key) async {
    return CustomType();
  }

  @override
  Future<void> setter(
      SharedPreferencesAsync prefs, String key, CustomType value) async {
    await prefs.setString(key, "custom");
  }

  const CustomAdapter();
}

void main() {
  group('PrfAdapterMap', () {
    late PrfAdapterMap adapterMap;

    setUp(() {
      adapterMap = PrfAdapterMap();
    });

    test('initially has no adapters registered', () {
      expect(adapterMap.registered, false);
      expect(adapterMap.contains<String>(), false);
    });

    test('registerAll registers standard adapters', () {
      adapterMap.registerAll();

      expect(adapterMap.registered, true);

      // native
      expect(adapterMap.contains<bool>(), true);
      expect(adapterMap.contains<int>(), true);
      expect(adapterMap.contains<double>(), true);
      expect(adapterMap.contains<String>(), true);
      expect(adapterMap.contains<List<String>>(), true);

      // encoded
      expect(adapterMap.contains<num>(), true);
      expect(adapterMap.contains<DateTime>(), true);
      expect(adapterMap.contains<Duration>(), true);
      expect(adapterMap.contains<BigInt>(), true);
      expect(adapterMap.contains<Uint8List>(), true);
      expect(adapterMap.contains<Uri>(), true);

      // lists
      expect(adapterMap.contains<List<int>>(), true);
      expect(adapterMap.contains<List<bool>>(), true);
    });

    test('of<T>() automatically registers adapters if none registered', () {
      expect(adapterMap.registered, false);

      final stringAdapter = adapterMap.of<String>();

      expect(adapterMap.registered, true);
      expect(stringAdapter, isA<StringAdapter>());
    });

    test('of<T>() throws for unregistered custom type', () {
      expect(() => adapterMap.of<CustomType>(), throwsStateError);
    });

    test('register adds a custom adapter', () {
      adapterMap.register<CustomType>(const CustomAdapter());

      expect(adapterMap.contains<CustomType>(), true);
      expect(adapterMap.of<CustomType>(), isA<CustomAdapter>());
    });

    test('register does not override existing adapter by default', () {
      adapterMap.register<String>(const StringAdapter());
      final firstAdapter = adapterMap.of<String>();

      // Try to register a second adapter without override
      adapterMap.register<String>(const StringAdapter());
      final secondAdapter = adapterMap.of<String>();

      // Should be the same instance
      expect(identical(firstAdapter, secondAdapter), true);
    });

    test('register with override replaces existing adapter', () {
      adapterMap.register<String>(const StringAdapter());
      final firstAdapter = adapterMap.of<String>();

      // Create a new adapter instance
      final newAdapter = StringAdapter();

      // Register with override flag
      adapterMap.register<String>(newAdapter, override: true);
      final secondAdapter = adapterMap.of<String>();

      // Should NOT be the same instance
      expect(identical(firstAdapter, secondAdapter), false);
      expect(secondAdapter, equals(newAdapter));
    });

    test('singleton instance is accessible', () {
      expect(PrfAdapterMap.instance, isA<PrfAdapterMap>());
    });
  });
}
