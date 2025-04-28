import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prf/core/prf_service.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../utils/fake_prefs.dart';

void main() {
  group('PrfService', () {
    (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
      final FakeSharedPreferencesAsync store = FakeSharedPreferencesAsync();
      SharedPreferencesAsyncPlatform.instance = store;
      final SharedPreferencesAsync preferences = SharedPreferencesAsync();
      return (preferences, store);
    }

    tearDown(() {
      // Reset the override after each test
      PrfService.resetOverride();
    });

    test('instance returns SharedPreferencesAsync instance', () async {
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);
      final prefs = PrfService.instance;
      expect(prefs, isA<SharedPreferencesAsync>());
    });

    test('overrideWith sets the instance to provided preferences', () async {
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);

      expect(identical(PrfService.instance, preferences), true);
    });

    test('resetOverride clears the override', () async {
      final (preferences, _) = getPreferences();
      PrfService.overrideWith(preferences);
      PrfService.resetOverride();

      expect(identical(PrfService.instance, preferences), false);
    });

    test('subsequent calls to instance return same instance if not overridden',
        () async {
      final firstInstance = PrfService.instance;
      final secondInstance = PrfService.instance;

      expect(identical(firstInstance, secondInstance), true);
    });
  });
}
