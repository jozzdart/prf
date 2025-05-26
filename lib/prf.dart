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

export 'src/prf.dart';
