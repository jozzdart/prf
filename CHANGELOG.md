# Changelog

All notable changes to the **prf** package will be documented in this file.

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
