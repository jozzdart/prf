![img](https://i.imgur.com/pAUltto.png)

<h3 align="center"><i>Define. Get. Set. Done.</i></h3>
<p align="center">
        <img src="https://img.shields.io/codefactor/grade/github/jozzzzep/prf/main?style=flat-square">
        <img src="https://img.shields.io/github/license/jozzzzep/prf?style=flat-square">
        <img src="https://img.shields.io/pub/points/prf?style=flat-square">
        <img src="https://img.shields.io/pub/v/prf?style=flat-square">
        
</p>
<p align="center">
  <a href="https://buymeacoffee.com/yosefd99v" target="https://buymeacoffee.com/yosefd99v">
    <img src="https://img.shields.io/badge/Buy%20me%20a%20coffee-Support (:-blue?logo=buymeacoffee&style=flat-square" />
  </a>
</p>

No boilerplate. No repeated strings. No setup. Define your variables once, then `get()` and `set()` them anywhere with zero friction. `prf` makes local persistence faster, simpler, and easier to scale, with 20+ built-in types and a clean, type-safe API. Designed to fully replace raw use of `SharedPreferences`.

#### Table of Contents

- [**Introduction**](#-define--get--set--done)
- [Why Use `prf`?](#-why-use-prf)
- [**SharedPreferences** vs `prf`](#-sharedpreferences-vs-prf)
- [Setup & Basic Usage (Step-by-Step)](#-setup--basic-usage-step-by-step)
- [Available Methods and Supported Types](#-available-methods-and-supported-types)
- [Accessing `prf` Without async](#-accessing-prf-without-async)
- [Migrating from _SharedPreferences_ to `prf`](#-migrating-from-sharedpreferences-to-prf)
- [Recommended Companion Packages](#-recommended-companion-packages)
- [Why `prf` Wins in Real Apps](#-why-prf-wins-in-real-apps)
- [Adding Custom prfs (Advanced)](#how-to-add-custom-prf-types)

# ⚡ Define → Get → Set → Done

Just define your variable once — no strings, no boilerplate:

```dart
final username = Prf<String>('username');
```

Then get it:

```dart
final value = await username.get();
```

Or set it:

```dart
await username.set('Joey');
```

That’s it. You're done. Works out of the box with all of these:

- `bool` `int` `double` `String` `num` `Duration` `DateTime` `BigInt` `Uri` `Uint8List` (binary)
- Also lists `List<String>` `List<int>` `List<***>` of all supported types!
- [JSON & enums](#-available-methods-and-supported-types)

> All supported types use efficient binary encoding under the hood for optimal performance and minimal storage footprint — no setup required. Just use `Prf<T>` with any listed type, and everything works seamlessly.

---

### 🔥 Why Use `prf`

Working with `SharedPreferences` often leads to:

- Repeated string keys
- Manual casting and null handling
- Verbose async boilerplate
- Scattered, hard-to-maintain logic

`prf` solves all of that with a **one-line variable definition** that’s **type-safe**, **cached**, and **instantly usable** throughout your app. No key management, no setup, no boilerplate, no `.getString(...)` everywhere.

---

### What Sets `prf` Apart?

- ✅ **Single definition** — just one line to define, then reuse anywhere
- ✅ **Type-safe** — no casting, no runtime surprises
- ✅ **Automatic caching** — with `Prf<T>` for fast access
- ✅ **Easy isolate safety** — with `.isolated`
- ✅ **Lazy initialization** — no need to call `SharedPreferences.getInstance()` or anything.
- ✅ **Supports more than just primitives** — [20+ types](#-available-methods-and-supported-types), `Enums` & `JSON`
- ✅ **Built for testing** — easily reset, override, or mock storage
- ✅ **Cleaner codebase** — no more scattered `prefs.get...()` or typo-prone string keys

---

### 🔁 `SharedPreferences` vs `prf`

[⤴️ Back](#table-of-contents) -> Table of Contents

| Feature                         | `SharedPreferences` (raw)                                            | `prf`                                                                                                 |
| ------------------------------- | -------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| **Define Once, Reuse Anywhere** | ❌ Manual strings everywhere                                         | ✅ One-line variable definition                                                                       |
| **Type Safety**                 | ❌ Requires manual casting                                           | ✅ Fully typed, no casting needed                                                                     |
| **Supports Advanced Types**     | ❌ No - only **5** types.                                            | ✅ Built-in support for `20+ types` and supports `enums` & `JSON`                                     |
| **Readability**                 | ❌ Repetitive and verbose                                            | ✅ Clear, concise, expressive                                                                         |
| **Centralized Keys**            | ❌ You manage key strings                                            | ✅ Keys are defined as variables                                                                      |
| **Lazy Initialization**         | ❌ Must await `getInstance()` manually                               | ✅ Internally managed                                                                                 |
| **Supports Primitives**         | ✅ Yes                                                               | ✅ Yes                                                                                                |
| **Isolate & Caching**           | ⚠️ Partial — must manually choose between caching or no-caching APIs | ✅ Just `.isolate` for full isolate-safety<br>✅ `Prf<T>` for faster cached access (not isolate-safe) |

### 📌 Code Comparison

**Using `SharedPreferences`:**

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('username', 'Joey');
final username = prefs.getString('username') ?? '';
```

**Using `prf` with cached access (`Prf<T>`):**

```dart
final username = Prf<String>('username');
await username.set('Joey');
final name = await username.get();
```

**Using `prf` with isolate-safe access (`PrfIso<T>`):**

```dart
final username = Prf<String>('username').isolated;
await username.set('Joey');
final name = await username.get();
```

If you're tired of:

- Duplicated string keys
- Manual casting and null handling
- Scattered async boilerplate

Then `prf` is your drop-in solution for **fast, safe, scalable, and elegant local persistence**.

# 🚀 Setup & Basic Usage (Step-by-Step)

[⤴️ Back](#table-of-contents) -> Table of Contents

### Step 1: Add `prf` to your `pubspec.yaml`

```yaml
dependencies:
  prf: ^latest
```

Then run:

```bash
flutter pub get
```

---

### Step 2: Define Your Variable

You only need **one line** to create a saved variable.  
For example, to save how many coins a player has:

```dart
final playerCoins = Prf<int>('player_coins');
```

> This means:
>
> - You're saving an `int` (number)
> - The key is `'player_coins'`

---

### Step 3: Save a Value

To give the player 100 coins:

```dart
await playerCoins.set(100);
```

---

### Step 4: Read the Value

To read how many coins the player has:

```dart
final coins = await playerCoins.get();
```

```dart
print('Coins: $coins'); // 100
```

That’s it! 🎉 You don’t need to manage string keys or setup anything. Just define once, then use anywhere in your app.

---

### Step 5 (Optional): Use `.prf<T>()` Shortcut

Instead of defining the key explicitly, you can use the `.prf<T>()` extension on a string:

```dart
final playerCoins = 'player_coins'.prf<int>();
```

From there it behave the same as defining using `Prf<T>`

```dart
await playerCoins.set(100);
final coins = await playerCoins.get();
```

```dart
print('Coins: $coins');
```

This works exactly the same — just a stylistic preference if you like chaining on string keys.

# 📖 Available Methods and Supported Types

> [⤴️ Back](#table-of-contents) -> Table of Contents

---

### ✅ All `Prf<T>` types support these `methods` out of the box

- **`get()`** → returns the current value (cached or from disk)
- **`set(value)`** → saves the value and updates the cache (if applicable)
- **`remove()`** → deletes the value from storage (and cache if applicable)
- **`isNull()`** → returns `true` if the value is `null`
- **`getOrFallback(fallback)`** → returns the value or a fallback if `null`
- **`existsOnPrefs()`** → checks if the key exists in storage
- **`getOrDefault()`** → returns the value, or throws if no value exists and no default is defined (safe alternative to assuming non-null values)

---

### 📦 Supported `Types`:

```dart
final someData = Prf<T>('key');
```

All of these work automatically **(practically every type)**:

- `bool`, `int`, `double`, `num`, `String`, `Duration`, `DateTime`, `Uri`, `BigInt`, `Uint8List` (binary)
- `List<bool>`, `List<int>`, `List<String>`, `List<double>`, `List<num>`, `List<DateTime>`, `List<Duration>`, `List<Uint8List>`, `List<Uri>`, `List<BigInt>`

> All supported types use efficient binary encoding under the hood for optimal performance and minimal storage footprint — no setup required. Just use `Prf<T>` and everything works seamlessly.

---

### 🔧 Specialized Types - `Enums` & `JSON`

For enums and custom models, use the built-in factory helpers:

- `Prf.enumerated<T>()` → enum value
- `Prf.enumeratedList<T>()` → list of enum values
- `Prf.json<T>()` → custom model object
- `Prf.jsonList<T>()` → list of custom model objects

* `Prf.cast<T, TCast>()` → custom behavior

---

#### 🛰 Need Isolate Safety?

Every `Prf` object supports the `.isolated` getter — no matter the type (enums, bytes, JSON, lists, etc).  
It returns a `PrfIso` that works safely across isolates (no caching, always reads from disk).

These are practically the same:

```dart
final safeUser = Prf<String>('username').isolated; // Same
final safeUser = PrfIso<String>('username');       // Same
```

---

### 🎯 Example: Persisting an `Enum`

Define your enum:

```dart
enum AppTheme { light, dark, system }
```

Store it using `Prf.enumerated` (cached) or `PrfIso.enumerated` (isolate-safe):

```dart
final appTheme = Prf.enumerated<AppTheme>(
  'app_theme',
  values: AppTheme.values,
);
```

Usage:

```dart
final currentTheme = await appTheme.get(); // AppTheme.light / dark / system
await appTheme.set(AppTheme.dark);
```

### 📚 Persisting a `List` of `Enums`

Define your enum:

```dart
enum Permission { read, write, delete }
```

Store a list using `Prf.enumeratedList` (cached) or `PrfIso.enumeratedList` (isolate-safe):

```dart
final permissions = Prf.enumeratedList<Permission>(
  'user_permissions',
  values: Permission.values,
);
```

Usage:

```dart
final current = await permissions.get(); // [Permission.read, Permission.write]
await permissions.set([Permission.read, Permission.delete]);
```

---

### 🧠 Custom Types? No Problem

Want to persist something more complex?  
Use `Prf.json<T>()` or `PrfIso.json<T>()` with any model that supports `toJson` and `fromJson`:

```dart
final userData = Prf.json<User>(
  'user',
  fromJson: (json) => User.fromJson(json),
  toJson: (user) => user.toJson(),
);

```

### 🧠 Complex Lists? Just Use `jsonList`

For model lists, use `Prf.jsonList<T>()` or `PrfIso.jsonList<T>()`:

```dart
final favoriteBooks = Prf.jsonList<Book>(
  'favorite_books',
  fromJson: (json) => Book.fromJson(json),
  toJson: (book) => book.toJson(),
);
```

Usage:

```dart
await favoriteBooks.set([book1, book2]);
final list = await favoriteBooks.get(); // List<Book>
```

---

### 🧩 Custom Casting Adapter with `.cast()`

Need to persist a custom object that can be converted to a supported type (like `String`, `int` and all 20+ types)?
Use the `.cast()` factory to define **on-the-fly adapters** with custom encode/decode logic — no full adapter class needed!

```dart
final langPref = Prf.cast<Locale, String>(
  'saved_language',
  encode: (locale) => locale.languageCode,
  decode: (string) => string == null ? null : Locale(string),
);
```

- `T` → your custom type (e.g., `Locale`)
- `TCast` → any built-in supported type (e.g., `String`, `int`, `List<String>`, etc)
- `encode` → how to convert `T` to `TCast`
- `decode` → how to restore `T` from `TCast`

Great for storing objects that don’t need full `toJson()` support — just convert to a native type and you're done!

# ⚡ Accessing `prf` Without Async

[⤴️ Back](#table-of-contents) -> Table of Contents

If you want instant, non-async access to a stored value, you can pre-load it into memory.
Use `Prf.value<T>()` to create a `prf` object that automatically initializes and caches the value.

Example:

```dart
final userScore = await Prf.value<int>('user_score');

// Later, anywhere — no async needed:
print(userScore.cachedValue); // e.g., 42
```

- `Prf.value<T>()` reads the stored value once and caches it.
- You can access `.cachedValue` instantly after initialization.
- If no value was stored yet, `.cachedValue` will be the `defaultValue` or `null`.

✅ Best for fast access inside UI widgets, settings screens, and forms.  
⚠️ Not suitable for use across isolates — use `.isolated` or `PrfIso<T>` for isolate safety.

### 🚀 Quick Summary

- `await Prf.value<T>()` → loads and caches the value.
- `.cachedValue` → direct, instant access afterward.
- No async needed for future reads!

---

### 💡 Altervative - `.prf()` from String Keys

```dart
final username = 'username'.prf<String>();
await username.set('Joey');
final name = await username.get();
```

Isolate-safe version:

```dart
final username = 'username'.prf<String>().isolated;
await username.set('Joey');
final name = await username.get();
```

# 🔁 Migrating from SharedPreferences to `prf`

[⤴️ Back](#table-of-contents) -> Table of Contents

Whether you're using the modern `SharedPreferencesAsync` or the legacy `SharedPreferences`, migrating to `prf` is simple and gives you cleaner, type-safe, and scalable persistence — without losing any existing data.

In fact, you can use `prf` with your current keys and values out of the box, preserving all previously stored data. But while backwards compatibility is supported, we recommend reviewing [all built-in types and usage](#-available-methods-and-supported-types) that `prf` provide — which may offer a cleaner, more powerful way to structure your logic going forward, without relying on legacy patterns or custom code.

---

### ✅ If you're already using `SharedPreferencesAsync`

You can switch to `prf` with **zero configuration** — just use the same keys.

#### Before (`SharedPreferencesAsync`):

```dart
final prefs = SharedPreferencesAsync();
await prefs.setBool('dark_mode', true);
final isDark = await prefs.getBool('dark_mode');
```

#### After (`prf`):

```dart
final darkMode = Prf<bool>('dark_mode');
await darkMode.set(true);
final isDark = await darkMode.get();
```

- ✅ **As long as you're using the same keys and types, your data will still be there. No migration needed.**
- 🧼 **Or — if you don't care about previously stored values**, you can start fresh and use `prf` types right away. They’re ready to go with clean APIs and built-in caching for all dart types, `enums`, `JSONs`, and more.

---

### ✅ If you're using the legacy `SharedPreferences` class

You can still switch to `prf` using the same keys:

#### Before (`SharedPreferences`):

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('username', 'Joey');
final name = prefs.getString('username');
```

#### After (`prf`):

```dart
final username = Prf<String>('username');
await username.set('Joey');
final name = await username.get();
```

- ⚠️ `prf` uses **SharedPreferencesAsync**, which is isolate-safe, more robust — and **does not share data with the legacy `SharedPreferences` API**. The legacy API is **already planned for deprecation**, so [migrating](#️-if-your-app-is-already-in-production-using-sharedpreferences) away from it is strongly recommended.
- ✅ If you're still in development, you can safely switch to `prf` now — saved values from before will not be accessible, but that's usually fine while iterating.

> The migration bellow automatically migrates old values into the new backend if needed.
> Safe to call multiple times — it only runs once.

---

### ⚠️ If your app is already in production using `SharedPreferences`

If your app previously used `SharedPreferences` (the legacy API), and you're now using `prf` (which defaults to `SharedPreferencesAsync`):

- You **must run a one-time migration** to move your data into the new backend (especially on Android, where the storage backend switches to DataStore).

Run this **before any reads or writes**, ideally at app startup:

```dart
await PrfService.migrateFromLegacyPrefsIfNeeded();
```

> This ensures your old values are migrated into the new system.
> It is safe to call multiple times — migration will only occur once.

---

### Summary

| Case                                   | Do you need to migrate?     | Do your keys stay the same? |
| -------------------------------------- | --------------------------- | --------------------------- |
| Using `SharedPreferencesAsync`         | ❌ No migration needed      | ✅ Yes                      |
| Using `SharedPreferences` (dev only)   | ❌ No migration needed      | ✅ Yes                      |
| Using `SharedPreferences` (production) | ✅ Yes — run migration once | ✅ Yes                      |
| Starting fresh                         | ❌ No migration, no legacy  | 🔄 You can pick new keys    |

With `prf`, you get:

- 🚀 **Type-safe, reusable variables**
- 🧠 **Cleaner architecture**
- 🔄 **Built-in in-memory caching**
- 🔐 **Isolate-safe behavior** with `SharedPreferencesAsync`
- 📦 **Out-of-the-box support** for `20+ types`, `enums`, full `JSON` models and more

# 🌟 Recommended Companion Packages

[⤴️ Back](#table-of-contents) -> Table of Contents

In addition to typed variables, `prf` connects seamlessly with **additional persistence power tools** — packages built specifically to extend the capabilities of `prf` into advanced real-world use cases.  
These tools offer plug-and-play solutions that carry over the same caching, async-safety, and persistence guarantees you expect from `prf`.

Packages:  
**`limit` package** → https://pub.dev/packages/limit  
**`track` package** → https://pub.dev/packages/track

- ⏲ **[`limit`](https://pub.dev/packages/limit)** — manage cooldowns and rate limits across sessions and isolates. Includes:

  - **Cooldown** (fixed-time delays, e.g. daily rewards, retry timers)
  - **RateLimiter** (token bucket rate limiting, e.g. 1000 actions per 15 minutes)

- 🔥 **[`track`](https://pub.dev/packages/track)** — track progress, activity, and usage over time. Includes:

  - **StreakTracker** (aligned streak tracking, e.g. daily habits)
  - **HistoryTracker** (rolling lists of recent items with optional deduplication)
  - **PeriodicCounter** (auto-reset counters per period, e.g. daily tasks)
  - **RolloverCounter** (sliding-window counters, e.g. attempts per hour)
  - **ActivityCounter** (detailed time-based activity stats)
  - **BestRecord** (coming soon: track best performances or highscores)

# 🔍 Why `prf` Wins in Real Apps

[⤴️ Back](#table-of-contents) -> Table of Contents

Working with `SharedPreferences` directly can quickly become **verbose, error-prone, and difficult to scale**. Whether you’re building a simple prototype or a production-ready app, clean persistence matters.

### ❌ The Problem with Raw SharedPreferences

Even in basic use cases, you're forced to:

- Reuse raw string keys (risk of typos and duplication)
- Manually cast and fallback every read
- Handle async boilerplate (`getInstance`) everywhere
- Encode/decode complex types manually
- Spread key logic across multiple files

Let’s see how this unfolds in practice.

---

### 👎 Example: Saving and Reading Multiple Values

**Goal**: Save and retrieve a `username`, `isFirstLaunch`, and a `signupDate`.

### SharedPreferences (verbose and repetitive)

```dart
final prefs = await SharedPreferences.getInstance();

// Save values
await prefs.setString('username', 'Joey');
await prefs.setBool('is_first_launch', false);
await prefs.setString(
  'signup_date',
  DateTime.now().toIso8601String(),
);

// Read values
final username = prefs.getString('username') ?? '';
final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
final signupDateStr = prefs.getString('signup_date');
final signupDate = signupDateStr != null
  ? DateTime.tryParse(signupDateStr)
  : null;
```

🔻 **Issues:**

- Repeated string keys — no compile-time safety
- Manual fallback handling and parsing
- No caching — every `.get` hits disk
- Boilerplate increases exponentially with more values

---

### ✅ Example: Same Logic with `prf`

```dart
final username = Prf<String>('username');
final isFirstLaunch = Prf<bool>('is_first_launch', defaultValue: true);
final signupDate = Prf<DateTime>('signup_date');

// Save
await username.set('Joey');
await isFirstLaunch.set(false);
await signupDate.set(DateTime.now());

// Read
final name = await username.get();         // 'Joey'
final first = await isFirstLaunch.get();   // false
final date = await signupDate.get();       // DateTime instance
```

💡 Defined once, used anywhere — fully typed, cached, and clean.

---

### 🤯 It Gets Worse with Models

Storing a `User` model in raw `SharedPreferences` requires:

1. Manual `jsonEncode` / `jsonDecode`
2. Validation on read
3. String-based key tracking

### SharedPreferences with Model:

```dart
// Get SharedPreferences
final prefs = await SharedPreferences.getInstance();
// Encode to JSON
final json = jsonEncode(user.toJson());
// Set value
await prefs.setString('user_data', json);

// Read
final raw = prefs.getString('user_data');
User? user;
if (raw != null) {
  try {
    // Decode JSON
    final decoded = jsonDecode(raw);
    // Convert to User
    user = User.fromJson(decoded);
  } catch (_) {
    // fallback or error
  }
}
```

---

### ✅ Same Logic with `prf`

```dart
// Define once
final userData = Prf.json<User>(
  'user_data',
  fromJson: User.fromJson,
  toJson: (u) => u.toJson(),
);

// Save
await userData.set(user);

// Read
final savedUser = await userData.get(); // User?
```

Fully typed. Automatically parsed. Fallback-safe. Reusable across your app.

---

### ⚙️ Built for Real Apps

`prf` was built to eliminate the day-to-day pain of using SharedPreferences in production codebases:

- ✅ Define once — reuse anywhere
- ✅ Clean API — `get()`, `set()`, `remove()`, `isNull()` for all types
- ✅ Supports `20+ types`, `enum`, `JSON`
- ✅ Automatic caching — fast access after first read
- ✅ Test-friendly — easily reset, mock, or inspect values

---

# How to Add Custom `prf` Types

[⤴️ Back](#table-of-contents) -> Table of Contents

For most use cases, you can use built-in types or factories like `Prf.enumerated<T>()`, `Prf.json<T>()`, and now `Prf.cast<T, TCast>()` to persist almost anything.
This section is for advanced users who want full control — but with **less boilerplate** thanks to the new `.cast()` API.

---

## 🧪 1. Define Your Custom Class

```dart
class Color {
  final int r, g, b;
  const Color(this.r, this.g, this.b);

  Map<String, dynamic> toJson() => {'r': r, 'g': g, 'b': b};
  factory Color.fromJson(Map<String, dynamic> json) =>
      Color(json['r'] ?? 0, json['g'] ?? 0, json['b'] ?? 0);
}
```

---

## ⚡ 2. Use `.cast()` to Store It

You can store `Color` as a `String` by encoding it as JSON:

```dart
final favoriteColor = Prf.cast<Color, String>(
  'favorite_color',
  encode: (color) => jsonEncode(color.toJson()),
  decode: (string) => string == null
      ? null
      : Color.fromJson(jsonDecode(string)),
);
```

---

## 🧩 Access and Use It

```dart
await favoriteColor.set(Color(255, 0, 0));
final color = await favoriteColor.get();

print(color?.r); // 255
```

---

## 🚦 Want Isolate-Safe?

Just add `.isolated`:

```dart
final safeColor = favoriteColor.isolated;
```

---

## ✅ Summary

- Use `Prf.cast<T, TCast>()` to quickly persist custom objects.
- No need to write full adapter classes.
- Encode to any supported type (`String`, `int`, `List`, etc.).
- Add `.isolated` for isolate-safe usage.

[⤴️ Back](#table-of-contents) -> Table of Contents

---

## 🔗 License MIT © Jozz

<p align="center">
  <a href="https://buymeacoffee.com/yosefd99v" target="https://buymeacoffee.com/yosefd99v">
    ☕ Enjoying this package? You can support it here.
  </a>
</p>
