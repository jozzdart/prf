# Changelog

All notable changes to the **prf** package will be documented in this file.

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
await Prf.migrateFromLegacyPrefsIfNeeded();
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
It’s safe to run every time — the migration will only happen once.

---

### ✅ What’s new in 2.0.0:

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

If your app is new, or you don’t care about previously stored data — you're done ✅  
If you’re upgrading and need old values — migrate once as shown above.

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

### Added

- `PrfJson<T>` class for storing JSON-serializable objects using `jsonEncode`/`jsonDecode`.
- Graceful fallback when decoding invalid JSON or mismatched types.

## 1.3.3

### Added

- `PrfDateTime` using base64-encoded 64-bit integers to persist `DateTime` values with millisecond precision.
- Integrated with `PrfEncoded` to reduce redundant logic.

## 1.3.2

### Added

- `PrfEncoded<TSource, TStore>` for reusable value transformation between domain objects and SharedPreferences-compatible types.
- Supports encoding formats like JSON, binary, and base64.

## 1.3.1

### Improved

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

### Fixed

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

### Added

- `typedef` support for `SharedPrefsGetter<T>` and `SharedPrefsSetter<T>`.
- Simplified `PrfVariable<T>` constructor by using delegates instead of abstract getter/setter classes.

### Changed

- Removed old abstract classes `PrfGetter` and `PrfSetter` in favor of inline functions.

## 1.0.2

### Improved

- Updated internal caching system for better performance on repeated `.get()` calls.

## 1.0.1

### Added

- Added `maybePrefs` and `isInitialized` to `Prf` for improved control over initialization state.

## 1.0.0

### Initial Release

- `PrfVariable<T>` base class with typed getter/setter support.
- Manual `SharedPreferences` injection.
- Clean and extensible architecture for managing preference values.
