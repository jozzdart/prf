import 'package:flutter_test/flutter_test.dart';
import 'package:prf/prf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../utils/fake_prefs.dart';

class Book {
  final String title;
  final int pages;

  Book(this.title, this.pages);

  Book.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        pages = json['pages'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'pages': pages,
      };

  @override
  bool operator ==(Object other) =>
      other is Book && other.title == title && other.pages == pages;

  @override
  int get hashCode => title.hashCode ^ pages.hashCode;
}

enum LogType { info, warning, error }

void main() {
  const testKey = 'test_history';

  (SharedPreferencesAsync, FakeSharedPreferencesAsync) getPreferences() {
    final store = FakeSharedPreferencesAsync();
    SharedPreferencesAsyncPlatform.instance = store;
    final preferences = SharedPreferencesAsync();
    return (preferences, store);
  }

  setUp(() async {
    PrfService.resetOverride();
    final (prefs, _) = getPreferences();
    PrfService.overrideWith(prefs);
    await PrfHistory<int>(testKey).clear();
  });

  group('PrfHistory<int>', () {
    test('starts empty', () async {
      final history = PrfHistory<int>(testKey);
      final items = await history.getAll();
      expect(items, isEmpty);
    });

    test('adds a single item', () async {
      final history = PrfHistory<int>(testKey);
      await history.add(5);
      final items = await history.getAll();
      expect(items, [5]);
    });

    test('adds multiple items and keeps order (most recent first)', () async {
      final history = PrfHistory<int>(testKey);
      await history.add(1);
      await history.add(2);
      await history.add(3);
      final items = await history.getAll();
      expect(items, [3, 2, 1]);
    });

    test('respects maxLength constraint', () async {
      final history = PrfHistory<int>(testKey, maxLength: 3);
      for (var i = 0; i < 10; i++) {
        await history.add(i);
      }
      final items = await history.getAll();
      expect(items.length, 3);
      expect(items, [9, 8, 7]); // last 3 inserted at front
    });

    test('deduplicate removes older instance before inserting', () async {
      final history = PrfHistory<int>(testKey, deduplicate: true);
      await history.add(1);
      await history.add(2);
      await history.add(3);
      await history.add(2); // should move 2 to front
      final items = await history.getAll();
      expect(items, [2, 3, 1]);
    });

    test('clear empties the list', () async {
      final history = PrfHistory<int>(testKey);
      await history.add(1);
      await history.clear();
      final items = await history.getAll();
      expect(items, []);
    });

    test('remove clears persistent state', () async {
      final history = PrfHistory<int>(testKey);
      await history.add(1);
      await history.removeKey();

      final exists = await history.exists();
      final items = await history.getAll();

      expect(exists, isFalse);
      expect(items, []);
    });

    test('exists returns true when data exists', () async {
      final history = PrfHistory<int>(testKey);
      await history.add(123);
      final exists = await history.exists();
      expect(exists, isTrue);
    });

    test('exists returns false when no data', () async {
      final history = PrfHistory<int>(testKey);
      history.removeKey();
      final exists = await history.exists();
      expect(exists, isFalse);
    });

    test('deduplicate = false allows duplicates', () async {
      final history = PrfHistory<int>(testKey, deduplicate: false);
      await history.add(1);
      await history.add(2);
      await history.add(1);
      final items = await history.getAll();
      expect(items, [1, 2, 1]); // both 1s stay
    });

    test('can mix deduplication and length limit', () async {
      final history = PrfHistory<int>(testKey, deduplicate: true, maxLength: 2);
      await history.add(1);
      await history.add(2);
      await history.add(1); // dedup to front
      final items = await history.getAll();
      expect(items, [1, 2]); // not [1, 1] or [1, 3]
    });

    test('concurrent updates are safely locked', () async {
      final history = PrfHistory<int>(testKey);
      await Future.wait([
        history.add(1),
        history.add(2),
        history.add(3),
      ]);
      final items = await history.getAll();
      expect(items.contains(1), isTrue);
      expect(items.contains(2), isTrue);
      expect(items.contains(3), isTrue);
      expect(items.length, 3);
    });

    test('setAll replaces entire list', () async {
      final history = PrfHistory<int>(testKey);
      await history.setAll([10, 20, 30]);
      final items = await history.getAll();
      expect(items, [10, 20, 30]);
    });

    test('setAll respects maxLength', () async {
      final history = PrfHistory<int>(testKey, maxLength: 2);
      await history.setAll([1, 2, 3, 4]);
      final items = await history.getAll();
      expect(items, [1, 2]); // first two
    });

    test('setAll deduplicates list if enabled', () async {
      final history = PrfHistory<int>(testKey, deduplicate: true);
      await history.setAll([1, 2, 2, 3]);
      final items = await history.getAll();
      expect(items.toSet().length, items.length);
    });

    test('remove deletes specific item from list', () async {
      final history = PrfHistory<int>(testKey);
      await history.setAll([1, 2, 3]);
      await history.remove(2);
      final items = await history.getAll();
      expect(items, [1, 3]);
    });

    test('removeWhere removes matching items', () async {
      final history = PrfHistory<int>(testKey);
      await history.setAll([1, 2, 3, 4]);
      await history.removeWhere((x) => x.isEven);
      final items = await history.getAll();
      expect(items, [1, 3]);
    });

    test('contains returns true for existing item', () async {
      final history = PrfHistory<int>(testKey);
      await history.setAll([1, 2, 3]);
      final result = await history.contains(2);
      expect(result, isTrue);
    });

    test('length returns correct count', () async {
      final history = PrfHistory<int>(testKey);
      await history.setAll([1, 2, 3]);
      final count = await history.length();
      expect(count, 3);
    });

    test('isEmpty returns true when list is empty', () async {
      final history = PrfHistory<int>(testKey);
      expect(await history.isEmpty(), isTrue);
    });

    test('first returns most recent value', () async {
      final history = PrfHistory<int>(testKey);
      await history.add(1);
      await history.add(2);
      final first = await history.first();
      expect(first, 2);
    });

    test('last returns oldest value', () async {
      final history = PrfHistory<int>(testKey);
      await history.add(1);
      await history.add(2);
      final last = await history.last();
      expect(last, 1);
    });

    test('key returns assigned key', () async {
      final history = PrfHistory<int>('my_history_key');
      expect(history.key, PrfHistory.keyFromName('my_history_key'));
    });

    test('json factory stores and retrieves model', () async {
      final history = PrfHistory.json<Book>(
        'books',
        fromJson: (json) => Book.fromJson(json),
        toJson: (book) => book.toJson(),
      );

      final book = Book('1984', 328);
      await history.add(book);
      final items = await history.getAll();

      expect(items, [book]);
    });

    test('json factory preserves order', () async {
      final history = PrfHistory.json<Book>(
        'books',
        fromJson: (json) => Book.fromJson(json),
        toJson: (book) => book.toJson(),
      );

      final b1 = Book('Book A', 100);
      final b2 = Book('Book B', 200);
      final b3 = Book('Book C', 300);

      await history.add(b1);
      await history.add(b2);
      await history.add(b3);

      final items = await history.getAll();
      expect(items, [b3, b2, b1]);
    });

    test('json factory deduplicates when enabled', () async {
      final history = PrfHistory.json<Book>(
        'books',
        fromJson: Book.fromJson,
        toJson: (b) => b.toJson(),
        deduplicate: true,
      );

      final b = Book('Same Title', 100);
      await history.add(b);
      await history.add(Book('Another', 200));
      await history.add(b); // should move to front

      final items = await history.getAll();
      expect(items.first, b);
      expect(items.where((e) => e == b).length, 1); // no duplicates
    });

    test('json factory respects maxLength', () async {
      final history = PrfHistory.json<Book>(
        'books',
        fromJson: Book.fromJson,
        toJson: (b) => b.toJson(),
        maxLength: 2,
      );

      await history.add(Book('A', 1));
      await history.add(Book('B', 2));
      await history.add(Book('C', 3)); // oldest trimmed

      final items = await history.getAll();
      expect(items.length, 2);
      expect(items.first.title, 'C');
      expect(items.last.title, 'B');
    });

    test('json factory handles corrupted entries gracefully', () async {
      final (prefs, store) = getPreferences();

      final history = PrfHistory.json<Book>(
        'books',
        fromJson: Book.fromJson,
        toJson: (b) => b.toJson(),
      );

      final corrupted = ['{"invalid":true}', 'not json'];
      await store.setStringList('books', corrupted, SharedPreferencesOptions());

      final result = await history.getAll();
      expect(result, isEmpty);
    });

    test('json factory setAll stores full list', () async {
      final history = PrfHistory.json<Book>(
        'books_set',
        fromJson: Book.fromJson,
        toJson: (b) => b.toJson(),
      );

      final books = [
        Book('Alpha', 111),
        Book('Beta', 222),
        Book('Gamma', 333),
      ];

      await history.setAll(books);
      final result = await history.getAll();
      expect(result, books);
    });

    test('json factory setAll removes duplicates when enabled', () async {
      final history = PrfHistory.json<Book>(
        'books_set_dedup',
        fromJson: Book.fromJson,
        toJson: (b) => b.toJson(),
        deduplicate: true,
      );

      final dup = Book('Same', 999);
      await history.setAll([dup, dup, dup]);
      final result = await history.getAll();
      expect(result, [dup]);
    });

    test('json factory remove works correctly', () async {
      final history = PrfHistory.json<Book>(
        'books_remove',
        fromJson: Book.fromJson,
        toJson: (b) => b.toJson(),
      );

      final a = Book('A', 1);
      final b = Book('B', 2);
      final c = Book('C', 3);
      await history.setAll([a, b, c]);

      await history.remove(b);
      final result = await history.getAll();
      expect(result, [a, c]);
    });

    test('json factory removeWhere removes matching', () async {
      final history = PrfHistory.json<Book>(
        'books_removewhere',
        fromJson: Book.fromJson,
        toJson: (b) => b.toJson(),
      );

      final a = Book('A', 10);
      final b = Book('B', 20);
      final c = Book('C', 30);
      await history.setAll([a, b, c]);

      await history.removeWhere((book) => book.pages >= 20);
      final result = await history.getAll();
      expect(result, [a]);
    });

    test('json factory first and last work as expected', () async {
      final history = PrfHistory.json<Book>(
        'books_first_last',
        fromJson: Book.fromJson,
        toJson: (b) => b.toJson(),
      );

      final b1 = Book('Oldest', 111);
      final b2 = Book('Newest', 999);
      await history.setAll([b1, b2]);

      expect(await history.first(), b1);
      expect(await history.last(), b2);
    });

    test('json factory contains works for object', () async {
      final history = PrfHistory.json<Book>(
        'books_contains',
        fromJson: Book.fromJson,
        toJson: (b) => b.toJson(),
      );

      final target = Book('Existentialism', 350);
      await history.add(target);
      expect(await history.contains(Book('Existentialism', 350)), isTrue);
    });

    test('enumerated history starts empty', () async {
      final history = PrfHistory.enumerated<LogType>(
        testKey,
        values: LogType.values,
      );
      final items = await history.getAll();
      expect(items, isEmpty);
    });

    test('enumerated history adds items in order', () async {
      final history = PrfHistory.enumerated<LogType>(
        testKey,
        values: LogType.values,
      );
      await history.add(LogType.warning);
      await history.add(LogType.error);
      final items = await history.getAll();
      expect(items, [LogType.error, LogType.warning]);
    });

    test('enumerated history respects maxLength', () async {
      final history = PrfHistory.enumerated<LogType>(
        testKey,
        values: LogType.values,
        maxLength: 2,
      );
      await history.add(LogType.info);
      await history.add(LogType.warning);
      await history.add(LogType.error);
      final items = await history.getAll();
      expect(items, [LogType.error, LogType.warning]);
    });

    test('enumerated history deduplicates and moves to front', () async {
      final history = PrfHistory.enumerated<LogType>(
        testKey,
        values: LogType.values,
        deduplicate: true,
      );
      await history.setAll([LogType.info, LogType.warning]);
      await history.add(LogType.info);
      final items = await history.getAll();
      expect(items, [LogType.info, LogType.warning]);
    });

    test('enumerated factory maintains enum integrity across storage',
        () async {
      final history = PrfHistory.enumerated<LogType>(
        testKey,
        values: LogType.values,
      );
      await history.setAll([LogType.warning, LogType.error]);
      final reloaded = PrfHistory.enumerated<LogType>(
        testKey,
        values: LogType.values,
      );
      final result = await reloaded.getAll();
      expect(result, [LogType.warning, LogType.error]);
    });

    test('enumerated setAll deduplicates if enabled', () async {
      final history = PrfHistory.enumerated<LogType>(
        testKey,
        values: LogType.values,
        deduplicate: true,
      );
      await history.setAll([LogType.info, LogType.warning, LogType.info]);
      final result = await history.getAll();
      expect(result.toSet().length, result.length);
    });

    test('enumerated removeWhere removes matching enum values', () async {
      final history = PrfHistory.enumerated<LogType>(
        testKey,
        values: LogType.values,
      );
      await history.setAll([LogType.info, LogType.warning, LogType.error]);
      await history.removeWhere((e) => e == LogType.warning);
      final result = await history.getAll();
      expect(result, [LogType.info, LogType.error]);
    });

    test('enumerated first and last return correct values', () async {
      final history = PrfHistory.enumerated<LogType>(
        testKey,
        values: LogType.values,
      );
      await history.setAll([LogType.info, LogType.warning]);
      expect(await history.first(), LogType.info);
      expect(await history.last(), LogType.warning);
    });

    test('enumerated contains returns true for existing enum', () async {
      final history = PrfHistory.enumerated<LogType>(
        testKey,
        values: LogType.values,
      );
      await history.add(LogType.error);
      expect(await history.contains(LogType.error), isTrue);
    });

    test('enumerated remove deletes specific enum', () async {
      final history = PrfHistory.enumerated<LogType>(
        testKey,
        values: LogType.values,
      );
      await history.setAll([LogType.info, LogType.warning, LogType.error]);
      await history.remove(LogType.warning);
      final result = await history.getAll();
      expect(result, [LogType.info, LogType.error]);
    });

    test('enumerated handles out-of-range stored indices gracefully', () async {
      final (prefs, store) = getPreferences();
      final adapter = IntListAdapter();
      final encoded = adapter.encode([0, 99]);
      await store.setString(testKey, encoded, SharedPreferencesOptions());

      final history = PrfHistory.enumerated<LogType>(
        testKey,
        values: LogType.values,
      );

      final result = await history.getAll();
      expect(result, isEmpty); // corruption fallback
    });
  });
}
