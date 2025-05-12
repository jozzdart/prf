/// `prf` - Define. Get. Set. Done.
///
/// A powerful, type-safe, and developer-friendly persistence library that simplifies
/// working with [SharedPreferences] in Flutter applications.
///
/// `prf` offers a clean, concise API for storing and retrieving values with zero
/// boilerplate, no string repetition, and strong type safety. It supports both
/// cached access `Prf` for performance and isolate-safe access `.isolated` for
/// reliability across multiple isolates.
///
/// ## Key Features:
///
/// * **Type Safety** — Define variables once, use them anywhere with full type checking
/// * **Caching** — Automatic in-memory caching with [Prf] for fast access
/// * **Isolate Safety** — [PrfIso] ensures true isolate-safe access (always reads from disk)
/// * **Extended Type Support** — Beyond primitives: `20+ types`, `enums`, `JSON` models, and binary data
/// * **Zero Setup** — No manual initialization — define and use immediately
/// * **Custom Adapters** — Extend behavior easily with custom serialization, compression, encryption
///
/// ## Basic Usage:
///
/// ```dart
/// // Define persistent variables
/// final username = Prf<String>('username');
/// final darkMode = Prf<bool>('dark_mode', defaultValue: false);
///
/// // Set values
/// await username.set('Alice');
/// await darkMode.set(true);
///
/// // Get values
/// final name = await username.get();
/// final isDark = await darkMode.get();
/// ```
///
/// ## Specialized Types
///
/// Use simple factory methods instead of dedicated classes:
///
/// * `Prf.enumerated<T>()` — for enum values
/// * `Prf.json<T>()` — for custom JSON model objects
library;

export 'adapters/adapter_extensions.dart';
export 'adapters/adapter_map.dart';
export 'adapters/encoded/big_int.dart';
export 'adapters/encoded/bytes.dart';
export 'adapters/encoded/date_time.dart';
export 'adapters/encoded/duration.dart';
export 'adapters/encoded/num.dart';
export 'adapters/encoded/uri.dart';
export 'adapters/enum_adapter.dart';
export 'adapters/json_adapter.dart';
export 'adapters/list/big_int.dart';
export 'adapters/list/bool.dart';
export 'adapters/list/bytes.dart';
export 'adapters/list/date_time.dart';
export 'adapters/list/double.dart';
export 'adapters/list/duration.dart';
export 'adapters/list/enum.dart';
export 'adapters/list/int.dart';
export 'adapters/list/json.dart';
export 'adapters/list/num.dart';
export 'adapters/list/uri.dart';
export 'adapters/list_binary.dart';
export 'adapters/native_adapters.dart';
export 'adapters/encoded_delegate.dart';
export 'core/base_adapter.dart';
export 'core/base_object.dart';
export 'core/base_service_object.dart';
export 'core/cached_object.dart';
export 'core/encoded_adapter.dart';
export 'core/extensions.dart';
export 'core/prf_service.dart';
export 'deprecated/deprecated.dart';
export 'types/prf.dart';
export 'types/prf_iso.dart';
export 'types/string_extensions.dart';
