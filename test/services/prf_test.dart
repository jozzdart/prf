import 'package:flutter_test/flutter_test.dart';
import 'package:prf/services/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Prf', () {
    const mockValues = {
      'username': 'dev_pikud',
      'is_logged_in': true,
      'count': 42,
    };

    setUp(() async {
      SharedPreferences.setMockInitialValues(mockValues);
      Prf.reset();
    });

    test('getInstance initializes prefs if not already initialized', () async {
      expect(Prf.isInitialized, isFalse);
      expect(Prf.maybePrefs, isNull);

      final prefs = await Prf.getInstance();

      expect(prefs.getString('username'), 'dev_pikud');
      expect(Prf.isInitialized, isTrue);
      expect(Prf.maybePrefs, isNotNull);
    });

    test(
      'getInstance returns the same instance if already initialized',
      () async {
        final prefs1 = await Prf.getInstance();
        final prefs2 = await Prf.getInstance();

        expect(identical(prefs1, prefs2), isTrue);
      },
    );

    test('reset clears initialized instance and future', () async {
      await Prf.getInstance();
      expect(Prf.isInitialized, isTrue);

      Prf.reset();
      expect(Prf.isInitialized, isFalse);
      expect(Prf.maybePrefs, isNull);

      final prefs = await Prf.getInstance();
      expect(prefs.getBool('is_logged_in'), true);
    });

    test(
      'maybePrefs is null before initialization and not null after',
      () async {
        expect(Prf.maybePrefs, isNull);
        await Prf.getInstance();
        expect(Prf.maybePrefs, isA<SharedPreferences>());
      },
    );

    test('isInitialized returns correct status', () async {
      expect(Prf.isInitialized, false);
      await Prf.getInstance();
      expect(Prf.isInitialized, true);
    });

    test('modifying prefs via instance affects global access', () async {
      final prefs = await Prf.getInstance();
      await prefs.setInt('score', 99);

      final second = await Prf.getInstance();
      expect(second.getInt('score'), 99);
    });
  });
}
