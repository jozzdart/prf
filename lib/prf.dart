/// PRF - Define. Get. Set. Done.
///
/// A powerful, type-safe, and developer-friendly persistence library that simplifies
/// working with [SharedPreferences] in Flutter applications.
///
/// PRF offers a clean, concise API for storing and retrieving values with zero
/// boilerplate, no string repetition, and strong type safety. It supports both
/// cached access ([Prf]) for performance and isolate-safe access ([Prfi]) for
/// reliability across multiple isolates.
///
/// ## Key Features:
///
/// * **Type Safety** — Define variables once, use them anywhere with full type checking
/// * **Caching** — Automatic in-memory caching with [Prf] for fast access
/// * **Isolate Safety** — [Prfi] ensures true isolate-safe access (always reads from disk)
/// * **Extended Type Support** — Beyond primitives: [DateTime], [BigInt], [Duration], enums, JSON models, and binary data
/// * **Zero Setup** — No manual initialization — define and use immediately
/// * **Production Utilities** — [PrfCooldown] for managing cooldowns, [PrfRateLimiter] for rate limiting
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
/// * `Prf.enumerated<T>()` / `Prfi.enumerated<T>()` — for enum values
/// * `Prf.json<T>()` / `Prfi.json<T>()` — for custom JSON model objects
///
/// ## Custom Adapters
///
/// PRF supports a fully modular adapter system.
/// Built-in adapters cover common types, but you can easily create and register
/// your own for any custom type, compressed format, or encrypted payload.
///
/// See [PrfAdapter] and [PrfAdapterMap] for details.
library;

export 'adapters/adapter_map.dart';
export 'adapters/encoded/big_int_adapter.dart';
export 'adapters/encoded/bytes_adapter.dart';
export 'adapters/encoded/date_time_adapter.dart';
export 'adapters/encoded/duration_adapter.dart';
export 'adapters/encoded/int_list_adapter.dart';
export 'adapters/encoded/num_adapter.dart';
export 'adapters/encoded/uri_adapter.dart';
export 'adapters/enum_adapter.dart';
export 'adapters/json_adapter.dart';
export 'adapters/native_adapters.dart';
export 'core/base_adapter.dart';
export 'core/base_object.dart';
export 'core/cached_object.dart';
export 'core/encoded_adapter.dart';
export 'core/extensions.dart';
export 'core/prf_service.dart';
export 'prf.dart';
export 'services/prf_cooldown.dart';
export 'services/prf_rate_limiter.dart';
export 'types/legacy/prf_big_int.dart';
export 'types/legacy/prf_bool.dart';
export 'types/legacy/prf_bytes.dart';
export 'types/legacy/prf_datetime.dart';
export 'types/legacy/prf_double.dart';
export 'types/legacy/prf_duration.dart';
export 'types/legacy/prf_enum.dart';
export 'types/legacy/prf_int.dart';
export 'types/legacy/prf_json.dart';
export 'types/legacy/prf_string.dart';
export 'types/legacy/prf_string_list.dart';
export 'types/legacy/prf_theme_mode.dart';
export 'types/legacy/prfy.dart';
export 'types/legacy/prfy_enum.dart';
export 'types/legacy/prfy_json.dart';
export 'types/prf.dart';
export 'types/prfi.dart';
