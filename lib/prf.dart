/// PRF - Define. Get. Set. Done.
///
/// A powerful, type-safe, and developer-friendly persistence library that simplifies
/// working with [SharedPreferences] in Flutter applications.
///
/// PRF offers a clean, concise API for storing and retrieving values with zero
/// boilerplate, no string repetition, and strong type safety. It supports both
/// cached access ([Prf]) for performance and isolate-safe access ([Prfy]) for
/// reliability across multiple isolates.
///
/// ## Key Features:
///
/// * **Type Safety**: Define variables once, use them anywhere with full type checking
/// * **Caching**: Automatic in-memory caching with [Prf] for performance
/// * **Isolate Safety**: [Prfy] provides true isolate-safe access by always reading from disk
/// * **Extended Type Support**: Beyond primitives - [DateTime], [BigInt], [Duration], enums, and custom JSON models
/// * **Zero Setup**: No initialization required - define variables and start using them
/// * **Production Utilities**: [PrfCooldown] for managing cooldown periods and [PrfRateLimiter] for rate limiting
///
/// ## Basic Usage:
///
/// ```dart
/// // Define once
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
/// * `PrfEnum<T>` / `PrfyEnum<T>` - For enum values
/// * `PrfJson<T>` / `PrfyJson<T>` - For custom model objects
///
/// ## Custom Adapters
///
/// PRF supports custom type conversion through its adapter system. The library
/// provides built-in adapters for common types, and you can extend it with your
/// own adapters for custom serialization, compression, or encryption.
library;

export 'core/adapter_map.dart';
export 'core/adapters.dart';
export 'core/base_object.dart';
export 'core/encoded_adapters.dart';
export 'core/extensions.dart';
export 'core/cached_object.dart';
export 'core/prf_service.dart';
export 'prf.dart';
export 'prf_types/legacy/prf_big_int.dart';
export 'prf_types/legacy/prf_bool.dart';
export 'prf_types/legacy/prf_bytes.dart';
export 'prf_types/legacy/prf_datetime.dart';
export 'prf_types/legacy/prf_double.dart';
export 'prf_types/legacy/prf_duration.dart';
export 'prf_types/legacy/prf_int.dart';
export 'prf_types/legacy/prf_string.dart';
export 'prf_types/legacy/prf_string_list.dart';
export 'prf_types/legacy/prf_theme_mode.dart';
export 'prf_types/prf.dart';
export 'prf_types/prf_enum.dart';
export 'prf_types/prf_json.dart';
export 'prfy_types/prfy.dart';
export 'prfy_types/prfy_enum.dart';
export 'prfy_types/prfy_json.dart';
export 'services/prf_cooldown.dart';
export 'services/prf_rate_limiter.dart';
