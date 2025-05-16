## 2.4.2

### Hotfix: Web Compatibility for 64-bit Encoded Types

Fixed runtime crash on Flutter Web due to unsupported `ByteData.getInt64`/`setInt64` operations in `dart2js`.
This affected all `prf` types storing 64-bit values:

- `DateTime`
- `List<DateTime>`
- `List<Duration>`

These types now use manual 64-bit encoding via two 32-bit integers (`high`/`low`) to ensure full Web compatibility, with no changes to binary format or migration required.

## 2.4.1

### ✨ New: Custom Casting Adapter with `.cast()`

You can now easily create **custom adapters on-the-fly** for types that can be encoded into a native type all supported `prf` types using the new `.cast()` factory on `Prf`.

This allows you to persist your custom objects without writing a full adapter class, by just providing encode/decode functions.

### Example

Let's say you want to store a `Locale` as an `String`:

```dart
final langPref = Prf.cast<Locale, String>(
  'saved_language',
  encode: (locale) => locale.languageCode,
  decode: (string) => string == null ? null : Locale(string),
);
```

### ✨ New: `getOrDefault()` extension method

Added a new method to all `prf` values:

```dart
Future<T> getOrDefault()
```

Returns the value from SharedPreferences, or throws an exception if it's `null` and no default was defined.

#### Example:

```dart
final coins = 'coins'.prf<int>(defaultValue: 0);
print(await coins.getOrDefault()); // → 0

final level = 'level'.prf<int>(); // no default
print(await level.getOrDefault()); // ❌ throws if not set
```

This improves error visibility in logic that assumes a non-null value must exist.

### Technical Details

- Introduced `EncodedDelegateAdapter<T, TCast>`: a flexible adapter that delegates encoding/decoding to provided functions.
- `.cast<T, TCast>()` factory wraps this adapter for ergonomic, type-safe usage.
- Compatible with all existing `prf` features (caching, isolated, custom defaults).

## 2.4.0

We are officially **deprecating all persistent utility services** (trackers and limiters) from the `prf` package. To keep `prf` focused purely on **persistence** (without embedded logic), all advanced time-based utilities are being migrated to two new dedicated packages:

### Why this change?

- Improves **modularity** and keeps `prf` lightweight.
- Reduces dependencies for apps that only need persistence.
- Allows `track` and `limit` to evolve independently with focused updates.
- Removes \~300 extra tests and \~1,200 lines from the README, which had made the package heavy and harder to navigate.
- Frees up space to expand `limit` and `track` with more features and utilities while keeping `prf` clean, focused, and \~90% smaller in size.

✅ **The APIs remain backward-compatible until v3.0 (2026) — just change your imports.**

- **`limit` package** → https://pub.dev/packages/limit

  - `PrfCooldown` → `Cooldown`
  - `PrfRateLimiter` → `RateLimiter`

- **`track` package** → https://pub.dev/packages/track

  - `PrfStreakTracker` → `StreakTracker`
  - `PrfPeriodicCounter` → `PeriodicCounter`
  - `PrfRolloverCounter` → `RolloverCounter`
  - `PrfActivityCounter` → `ActivityCounter`
  - `PrfHistory` → `HistoryTracker`
  - _Enums:_
    - `TrackerPeriod` → `TimePeriod`
    - `ActivitySpan` → `TimeSpan`

```bash
flutter pub add track
flutter pub add limit
```

### Deprecated in 2.4.0 (to be removed in v3.0.0 estimated 2026):

- Limit Services: `PrfCooldown` `PrfRateLimiter`
- Tracking Services: `PrfStreakTracker` `PrfPeriodicCounter` `PrfRolloverCounter` `PrfActivityCounter` `PrfHistory`
- Enums: `TrackerPeriod` `ActivitySpan`
- Service Interfaces: `BaseCounterTracker` `BaseTracker`

Everything related to the services. Nothing changed in `prf` itself.

## 2.3.1

- Added `PrfHistory<T>`: a reusable persisted history tracker for any type. Supports max length trimming, deduplication, isolation safety, and flexible factory constructors for enums and JSON models. Also added `.historyTracker(name)` extension on `PrfAdapter<List<T>>` for simplified `PrfHistory<T>` creation.

- Added `.prf<T>()` and `.prfCustomAdapter<T>()` extensions on `String` for quick and concise variable creation.

```dart
    final coinsPrf = 'player_coins'.prf<int>(); // works with all types now
```

- Added `.prf(key)` extension on `PrfAdapter<T>` for direct use of custom adapters without boilerplate.

```dart
  final colorPrf = ColorAdapter().prf('saved_color'); // no need to specify types
```

- Added `Prf.jsonList<T>()` for easy creation of cached and isolate-safe preferences for lists of JSON-serializable objects.
- Added `Prf.enumeratedList<T>()` for type-safe enum list preferences backed by native `List<int>` storage.
- Added `JsonListAdapter<T>`: stores a `List<T>` where each item is a JSON string using native `List<String>` support.
- Added `EnumListAdapter<T>`: stores a list of enums as their integer indices using native `List<int>` support.
- Fixed broken or incorrect navigation links in the README.

## 2.3.0

### General Additions

- Added `Back to Table of Contents` links to all README sections for improved navigation.
- All utilities & services now support an optional `useCache: true` parameter to enable faster memory-cached access for single-isolate apps. They remain **isolate-safe by default**, but enabling caching **disables isolate safety**. See the `README` for guidance on when to enable it.
- Added adapters for `List<num>`, `List<Uint8List>`, `List<BigInt>`, `List<Duration>`, and `List<Uri>`. Now the package supports all possible types out of the box!

### 🧭 Tracker Services

Introduced a suite of new tracker utilities — see the 📖 `README` for full documentation, examples, and usage tips:

- **`PrfStreakTracker`** — Persistent streak tracker that increases when an action is performed every aligned period (e.g. daily), and resets if a period is missed. Ideal for login streaks, daily habits, and weekly goals. Includes methods for checking streak length, detecting breaks, and calculating time left before expiration.

- **`PrfPeriodicCounter`** — A persistent counter that resets itself automatically at the start of each aligned period (e.g. daily, hourly, weekly). Perfect for counting recurring actions like logins or submissions. Supports incrementing, getting, resetting, and clearing the count.

- **`PrfRolloverCounter`** — A sliding-window counter that resets itself after a fixed duration (e.g. 10 minutes after last use). Useful for rolling metrics like "actions per hour" or "retry cooldowns". Includes time-aware utilities like time remaining, end time, and percentage elapsed.

- **`PrfActivityCounter`** — A time-based analytics tracker that aggregates values over hour, day, month, and year spans. Useful for building heatmaps, tracking activity frequency, or logging usage patterns. Supports advanced queries like `.summary()`, `.total()`, `.all()`, and `.maxValue()`, with uncapped yearly data retention.

- All tracker tools are now covered by **extensive tests** — including 220 dedicated tests for the new trackers — to ensure proper state reset, timestamp alignment, and session persistence.
- These tools are designed for advanced use cases like counters, streaks, timers, and rolling metrics — allowing custom persistent services to be built cleanly and safely. All built on top of `PrfIso<T> — fully isolate-safe.

### Fixed

> **All persistent utilities and services are now fully synchronized.**

This version introduces **comprehensive internal locking** to all `Prf`-based services and trackers to prevent concurrent access issues in asynchronous or multi-call scenarios.  
Previously, state mutations (e.g. `.set`, `.reset`, `.increment`) were **not guarded**, which could cause race conditions, corrupted values, or inconsistent behavior — especially in rapid or concurrent calls.

This update ensures:

- **Atomic updates** to counters, cooldowns, and streaks.
- **No race conditions** between `.get()`, `.set()`, and `.reset()`.
- **Consistency across isolates or concurrent flows**.
- **Industry-grade safety guarantees** for production apps.

### 🧱 Foundation for Custom Trackers

Introduced new foundational base classes for building your own tracking tools:

- `BaseTracker<T>` — base for timestamp-aware persistent values with expiration handling.
- `BaseCounterTracker` — extension of `BaseTracker<int>` with `.increment()` and consistent default logic.
- `TrackerPeriod` — an enum of aligned periods like `minutes10`, `hourly`, `daily`, `weekly`, with `.duration` and `.alignedStart()`.

## 2.2.4

- Added factory methods:
  - `Prf.json<T>(...)` and `Prf.enumerated<T>(...)`
  - `PrfIso.json(...)` and `PrfIso.enumerated(...)`
- Added `.isolated` getter on `Prf<T>` for isolate-safe access.
- Expanded native type support:
  - Built-in adapters for `num`, `Uri`, `List<int>`, `List<bool>`, `List<double>`, `List<DateTime>` now supported out of the box with all `prf` values! (with efficient binary encoding under the hood)
- All adapters are now `const` for reduced memory usage and better performance.
- Updated README documentation.
- Now isolated `prfs` can easily be created like this:

```dart
final isoValue = Prf<String>('username').isolated;
```

**Changes and Deprecations:**

- Renamed `Prfy<T>` → `PrfIso<T>`.
- Added deprecation annotations with migration instructions.
- Deprecated classes (to be removed in v3.0.0):
  - `PrfJson<T>` → `Prf.json<T>(...)`
  - `PrfEnum<T>` → `Prf.enumerated<T>(...)`
  - `Prfy<T>` → `PrfIso<T>`
  - `PrfyJson<T>` → `PrfIso.json<T>(...)`
  - `PrfyEnum<T>` → `PrfIso.enumerated<T>(...)`
  - Or alternatively: `Prf.json<T>(...).isolated`, `Prf.enumerated<T>(...).isolated`
- Added extensive tests for every single adapter, with more than 300 tests - all adapters are heavily tested to ensure data integrity.

## 2.2.3

- Fixed `Prf.value<T>()` not being static as intended.

## 2.2.2

- Updated README

## 2.2.1

### Added

- **Instant Cached Access**:  
  Introduced `.cachedValue` getter for `Prf<T>` objects to access the last loaded value **without async**.
- **`Prf.value<T>()` factory**:  
  Added `Prf.value<T>()` constructor that automatically loads the stored value into memory, making `.cachedValue` immediately usable after initialization.

  Example:

  ```dart
  final score = await Prf.value<int>('user_score');
  print(score.cachedValue); // No async needed
  ```

  - After calling `Prf.value()`, you can access `.cachedValue` instantly.
  - If no value exists, `.cachedValue` will be the `defaultValue` or `null`.

### Notes

- This feature improves UI performance where fast access to settings or preferences is needed.
- Reminder: `Prf<T>` is optimized for speed but **not isolate-safe** — use `Prfy<T>` when isolate safety is required.

## 2.2.0

### Major Update

- **Unified API**:  
  Consolidated all legacy `PrfX` classes (`PrfBool`, `PrfInt`, `PrfDouble`, etc.) into a single generic structure:

  - `Prf<T>` — **Cached**, fast access (not isolate-safe by design).
  - `Prfy<T>` — **Isolate-safe**, no internal caching, always reads from storage.

- **Adapter-Based Architecture**:  
  Added modular adapter system (`PrfAdapter<T>`) with built-in adapters for:

  - Primitive types (`bool`, `int`, `double`, `String`, `List<String>`)
  - Encoded types (`DateTime`, `Duration`, `BigInt`, `Uint8List`, Enums, JSON)

- **Backward Compatibility**:  
  Legacy `PrfX` classes remain available, internally powered by the new adapter system.

- **Extensibility**:  
  Developers can register custom type adapters via `PrfAdapterMap.instance.register()`.

- **Internal Reorganization**:  
  Major file structure improvements (`core/`, `prf_types/`, `prfy_types/`, `services/`) for better modularity and future expansion.

### Fixed

- **Isolate Safety Issue (Issue #3)** ([stuartmorgan-g](https://github.com/stuartmorgan-g)):  
  Previously, `prf` incorrectly advertised full isolate safety while using internal caching.  
  This release properly separates behavior:

  - `Prfy<T>` values are **truly isolate-safe**, always reading from `SharedPreferencesAsync` without cache.
  - `Prf<T>` values **use caching** for performance, but are **not isolate-safe** across isolates (expected Dart behavior).
  - README and comparison tables have been updated to accurately reflect these distinctions and explain the cache behavior clearly.

- Corrected claims about `shared_preferences` caching behavior — acknowledged that `SharedPreferencesWithCache` **does** have Dart-side caching.

- Clarified that naive Dart caching, like in `Prf<T>`, shares the same limitations as `SharedPreferencesWithCache` regarding multi-isolate consistency.

### Added

- `PrfyJson<T>` — Safe JSON object storage across isolates.
- `PrfyEnum<T>` — Safe enum storage across isolates.
- `PrfJson<T>` — Cached JSON object storage.
- `PrfEnum<T>` — Cached enum storage.
- `DateTimeAdapter`, `DurationAdapter`, `BigIntAdapter`, `BytesAdapter` for encoded types.
- `PrfCooldown` and `PrfRateLimiter` now internally use the new types.

### Changed

- Updated README to accurately describe:

  - Isolate-safe usage patterns (`Prfy`).
  - Cache-optimized usage patterns (`Prf`).
  - Caching behavior and limitations compared to `shared_preferences`.

- Improved internal documentation on the adapter registration system and best practices.

## 2.1.3

- Fixed issues related to pub.dev formatting

## 2.1.2

- Fixed problems with README formatting

## 2.1.1

- Shortened package description in pubspec.yaml to comply with pub.dev length requirements

## 2.1.0

### Added

- **`PrfCooldown`** utility for managing persistent cooldown periods with built-in tracking and duration handling
- **`PrfRateLimiter`** industry-grade token bucket limiter using `prf` types for rolling-rate restrictions (e.g. `1000 actions per 15 minutes`)
- **New typed variables**:
  - `PrfTheme` – store theme mode (`light`, `dark`, `system`)
  - `PrfDuration` – store `Duration` as microseconds
  - `PrfBigInt` – store `BigInt` as a string
- `removeAll()` method in `PrfCooldown` and `PrfRateLimiter` to clear all related sub-keys
- `overrideWith()` and `resetOverride()` methods in `Prf` to inject custom `SharedPreferencesAsync` instance for testing
- Detailed migration documentation for:
  - Migrating from `SharedPreferences`
  - Migrating from `SharedPreferencesAsync`
  - Migrating from legacy `prf`
- README coverage for isolate support and compatibility

### Changed

- Internal singleton of `Prf` now supports override injection for better testability
- Updated comparison table in README to highlight isolate safety, caching, and type support

### Fixed

- Deprecated `Prf.clear(...)` to discourage unintentional global wipes — use `Prf.instance.clear()` instead for clarity and safety

## 2.0.0

### Internals migrated to SharedPreferencesAsync

🚨 **Behavioral Breaking Change** (no API changes)

### TL;DR — Do You Need to Do Anything?

- ✅ **No action needed** if:
  - Your app is new and doesn't rely on previously stored values, or
  - You were **already using `SharedPreferencesAsync`** — everything will continue to work seamlessly.
- 🔁 **Run a migration** if:
  - Your app was using `prf` prior to this version (pre-2.0.0)
  - You want to preserve previously stored values

```dart
await PrfService.migrateFromLegacyPrefsIfNeeded();
```

---

### 🧠 Why this change?

`prf` now uses `SharedPreferencesAsync` under the hood — the **new, isolate-safe**, officially recommended backend for shared preferences.

This change future-proofs `prf` and avoids issues caused by the old `SharedPreferences` API, which:

- Is being **deprecated**
- Is **not isolate-safe**
- Does **not guarantee disk persistence** on write ([source](https://medium.com/@thejussomaraj546/sharedpreferences-b2a36be724e6))

---

### 🛠 Migration Instructions

If your app used `prf` previously and stored data you want to keep:

```dart
await Prf.migrateFromLegacyPrefsIfNeeded();
```

This safely copies data from the legacy storage backend to the new one.  
It's safe to run every time — the migration will only happen once.

---

### ✅ What's new in 2.0.0:

- Internals now use `SharedPreferencesAsync`
- Full **isolate-safety**, suitable for background plugins like `firebase_messaging`
- Removed reliance on `getInstance()` and internal platform-side caching
- `prf` now fully controls its own cache
- Public API is **unchanged** — `get()`, `set()`, `remove()` all still work the same

---

### 🔁 Key Differences

| Feature                | Before (`1.x`)             | After (`2.0.0`)        |
| ---------------------- | -------------------------- | ---------------------- |
| Backend                | SharedPreferences (legacy) | SharedPreferencesAsync |
| Android storage method | SharedPreferences XML      | DataStore Preferences  |
| Isolate-safe           | ❌ No                      | ✅ Yes                 |

---

### 💬 Summary

This is a critical under-the-hood upgrade to ensure `prf` is compatible with modern Flutter apps, isolate-safe, and ready for the future of shared preferences.

If your app is new, or you don't care about previously stored data — you're done ✅  
If you're upgrading and need old values — migrate once as shown above.

## 1.3.8

- Added example file for pub.dev to showcase package usage.

## 1.3.7

- Finished setting up for publishing, this package was private for too long in my repositoriee, hope you enjoy it!

## 1.3.6

- Added omprehensive documentation comments for the entire library.
- Improved API reference with examples and usage notes.
- Enhanced dartdoc coverage for all public classes and methods.
- Better explanation of advanced features and type support.

## 1.3.5

- Improved `PrfDateTime` encoding reliability by enforcing endian order consistency.
- Fixed internal handling of corrupted `base64` data for `PrfBytes`.

## 1.3.4

- `PrfJson<T>` class for storing JSON-serializable objects using `jsonEncode`/`jsonDecode`.
- Graceful fallback when decoding invalid JSON or mismatched types.

## 1.3.3

- `PrfDateTime` using base64-encoded 64-bit integers to persist `DateTime` values with millisecond precision.
- Integrated with `PrfEncoded` to reduce redundant logic.

## 1.3.2

- `PrfEncoded<TSource, TStore>` for reusable value transformation between domain objects and SharedPreferences-compatible types.
- Supports encoding formats like JSON, binary, and base64.

## 1.3.1

- Added `_exists` check inside `getValue()` to allow fallback to `defaultValue` if key is missing.
- Improved caching logic to avoid unnecessary SharedPreferences reads.

## 1.3.0

### Added

- `PrfVariableExtensions<T>` extension with:
  - `.get()`, `.set(value)`, `.remove()`, `.isNull()`
  - Uses lazy `SharedPreferences` initialization automatically.

### Changed

- Removed requirement to manually call `Prf.init()`. Now fully lazy-loaded via `Prf.getInstance()`.

## 1.2.1

- Minor internal refactor to prevent reinitializing `_initFuture` in `Prf`.

## 1.2.0

### Added

- `PrfBytes` with transparent base64 storage of `Uint8List`.
- Full support for all native SharedPreferences types:
  - `PrfInt`
  - `PrfDouble`
  - `PrfBool`
  - `PrfString`
  - `PrfStringList`

### Improved

- Unified all variable types using delegate-based constructors.
- Internal logic now handles nullability consistently and efficiently.

## 1.1.0

- Added `typedef` support for `SharedPrefsGetter<T>` and `SharedPrefsSetter<T>`.
- Simplified `PrfVariable<T>` constructor by using delegates instead of abstract getter/setter classes.
- Removed old abstract classes `PrfGetter` and `PrfSetter` in favor of inline functions.

## 1.0.2

- Updated internal caching system for better performance on repeated `.get()` calls.

## 1.0.1

- Added `maybePrefs` and `isInitialized` to `Prf` for improved control over initialization state.

## 1.0.0

- `PrfVariable<T>` base class with typed getter/setter support.
- Manual `SharedPreferences` injection.
- Clean and extensible architecture for managing preference values.
