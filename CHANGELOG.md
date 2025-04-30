# Changelog

All notable changes to the **prf** package will be documented in this file.

## 2.2.5

#### 🧭 Tracker Services

- Introduced a new high-level utility:

  - **`PrfPeriodicCounter`** — a drop-in persistent counter that resets itself automatically at the start of each aligned period (e.g. daily, hourly, every 5 minutes).  
    Tracks actions like "daily logins", "hourly submissions", or "weekly attempts" with zero boilerplate.

    ```dart
    final counter = PrfPeriodicCounter('daily_uploads', period: TrackerPeriod.daily);
    await counter.increment();  // +1 today
    final total = await counter.get(); // auto-resets each day at midnight
    ```

    Backed by `PrfIso<int>` and supports `.get()`, `.increment()`, `.reset()`, `.clear()` and `hasState()`.

- All tracker tools are now covered by **extensive tests** — including 150 dedicated tests for the new trackers — to ensure proper state reset, timestamp alignment, and session persistence.
- These tools are designed for advanced use cases like counters, streaks, timers, and rolling metrics — allowing custom persistent services to be built cleanly and safely. All built on top of `PrfIso<T>` — fully isolate-safe.

### Foundation for tracking tools

- Introduced new foundational classes for building persistent tracking tools:

  - `BaseTracker<T>` — a reusable base for timestamp-aware persistent values, with automatic expiry handling and fallback logic.
  - `BaseCounterTracker` — a numeric extension of `BaseTracker<int>` that adds `.increment()` and standardized zero fallback, ideal for counters.
  - `TrackerPeriod` — an enum of aligned time periods (e.g. `minutes10`, `hourly`, `daily`, `weekly`) with built-in `.duration` and `.alignedStart(DateTime)` helpers.

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
