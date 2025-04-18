![img](https://i.imgur.com/pAUltto.png)

<h3 align="center"><i>Define. Get. Set. Done.</i></h3>
<p align="center">
        <img src="https://img.shields.io/codefactor/grade/github/jozzzzep/prf/main?style=flat-square">
        <img src="https://img.shields.io/github/license/jozzzzep/prf?style=flat-square">
        <img src="https://img.shields.io/pub/points/prf?style=flat-square">
        <img src="https://img.shields.io/pub/v/prf?style=flat-square">
</p>

No boilerplate. No repeated strings. No setup. Define your variables once, then `get()` and `set()` them anywhere with zero friction. `prf` makes local persistence faster, simpler, and easier to scale. Includes 10+ built-in types and utilities like persistent cooldowns and rate limiters. Designed to fully replace raw use of `SharedPreferences`.

> Way more types than **SharedPreferences** — including `enums` `DateTime` `JSON models` and more.  
> And also: `PrfCooldown` `PrfRateLimiter` for persistent cooldowns and rate limiters.

- [Introduction](#-define--get--set--done)
- [Why Use `prf`?](#-why-use-prf)
- [**SharedPreferences** vs `prf`](#-sharedpreferences-vs-prf)
- [Setup & Basic Usage (Step-by-Step)](#-setup--basic-usage-step-by-step)
- [Available Methods for All `prf` Types](#-available-methods-for-all-prf-types)
- [Supported `prf` Types](#-supported-prf-types)
- [Migrating from _SharedPreferences_ to `prf`](#-migrating-from-sharedpreferences-to-prf)
- [Persistent Services & Utilities](#️-persistent-services--utilities)
- [Roadmap & Future Plans](#️-roadmap--future-plans)
- [Why `prf` Wins in Real Apps](#-why-prf-wins-in-real-apps)

# ⚡ Define → Get → Set → Done

Just define your variable once — no strings, no boilerplate:

```dart
final username = PrfString('username');
```

Then get it:

```dart
final value = await username.get();
```

Or set it:

```dart
await username.set('Joey');
```

That’s it. You're done. Works with [all `prf` Types!](#-available-methods-for-all-prf-types)

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
- ✅ **Automatic caching** — values are stored in memory after the first read
- ✅ **Lazy initialization** — no need to manually call `SharedPreferences.getInstance()`
- ✅ **Supports more than just primitives** — [10+ types](#-available-methods-for-all-prf-types) without counting utilities.
- ✅ **Built for testing** — easily reset or mock storage in tests
- ✅ **Cleaner codebase** — no more scattered `prefs.get...()` or typo-prone string keys
- ✅ **Isolate-safe** — built on `SharedPreferencesAsync` for full isolate compatibility, **with caching on top**, making it faster and more ergonomic than working with raw `SharedPreferencesAsync` directly
- ✅ [**Persistent utilities included**](#️-persistent-services--utilities) —
  - `PrfCooldown` – for managing cooldown windows (e.g. daily rewards)
  - `PrfRateLimiter` – token-bucket limiter for X actions per time window (e.g. 1000 messages per 15 minutes)

---

### 🔁 `SharedPreferences` vs `prf`

| Feature                         | `SharedPreferences` (raw)                                                                 | `prf`                                                               |
| ------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| **Define Once, Reuse Anywhere** | ❌ Manual strings everywhere                                                              | ✅ One-line variable definition                                     |
| **Type Safety**                 | ❌ Requires manual casting                                                                | ✅ Fully typed, no casting needed                                   |
| **Readability**                 | ❌ Repetitive and verbose                                                                 | ✅ Clear, concise, expressive                                       |
| **Centralized Keys**            | ❌ You manage key strings                                                                 | ✅ Keys are defined as variables                                    |
| **Caching**                     | ❌ No built-in caching                                                                    | ✅ Automatic in-memory caching                                      |
| **Lazy Initialization**         | ❌ Must await `getInstance()` manually                                                    | ✅ Internally managed                                               |
| **Supports Primitives**         | ✅ Yes                                                                                    | ✅ Yes                                                              |
| **Supports Advanced Types**     | ❌ No (`DateTime`, `enum`, etc. must be encoded manually)                                 | ✅ Built-in support for `DateTime`, `Uint8List`, `enum`, `JSON`     |
| **Special Persistent Services** | ❌ None                                                                                   | ✅ `PrfCooldown`, `PrfRateLimiter`, and more in the future          |
| **Isolate Support**             | ⚠️ Partial — only works with `SharedPreferencesAsync`, but still inherits all limitations | ✅ Full isolate-safe support with async backen and built-in caching |

# 📌 Code Comparison

**Using `SharedPreferences`:**

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('username', 'Joey');
final username = prefs.getString('username') ?? '';
```

**Using `prf`:**

```dart
final username = PrfString('username');
await username.set('Joey');
final name = await username.get();
```

If you're tired of:

- Duplicated string keys
- Manual casting and null handling
- Scattered boilerplate

Then `prf` is your drop-in solution for **fast, safe, scalable, and elegant local persistence**.

# 🚀 Setup & Basic Usage (Step-by-Step)

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
final playerCoins = PrfInt('player_coins', defaultValue: 0);
```

> This means:
>
> - You're saving an `int` (number)
> - The key is `'player_coins'`
> - If it's empty, it starts at `0`

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
print('Coins: $coins'); // 100
```

That’s it! 🎉 You don’t need to manage string keys or setup anything. Just define once, then use anywhere in your app.

# 🧰 Available Methods for All `prf` Types

| Method                    | Description                                      |
| ------------------------- | ------------------------------------------------ |
| `get()`                   | Returns the current value (cached or from disk). |
| `set(value)`              | Saves the value and updates the cache.           |
| `remove()`                | Deletes the value from storage and memory.       |
| `isNull()`                | Returns `true` if the value is `null`.           |
| `getOrFallback(fallback)` | Returns the value or a fallback if `null`.       |
| `existsOnPrefs()`         | Checks if the key exists in SharedPreferences.   |

> Available on all `prf` types — consistent, type-safe, and ready anywhere in your app.

# 🔤 Supported `prf` Types

Define your variable once with a type that fits your use case. Every type supports `.get()`, `.set()`, `.remove()`, and more — all cached, type-safe, and ready to use.

| Basic Types    | Class           | Common Use Cases                                      |
| -------------- | --------------- | ----------------------------------------------------- |
| `bool`         | `PrfBool`       | Feature flags, settings toggles                       |
| `int`          | `PrfInt`        | Counters, scores, timestamps                          |
| `double`       | `PrfDouble`     | Ratings, sliders, precise values                      |
| `String`       | `PrfString`     | Usernames, tokens, IDs                                |
| `List<String>` | `PrfStringList` | Tags, recent items, multi-select options              |
| `enum`         | `PrfEnum<T>`    | Typed modes, states, user roles                       |
| `T (via JSON)` | `PrfJson<T>`    | Full model objects with `toJson` / `fromJson`         |
| `Uint8List`    | `PrfBytes`      | Binary data (images, keys, QR codes)                  |
| `DateTime`     | `PrfDateTime`   | Timestamps, cooldowns, scheduled actions              |
| `Duration`     | `PrfDuration`   | Intervals, delays, expiry timers                      |
| `BigInt`       | `PrfBigInt`     | Cryptographic data, large counters, blockchain tokens |
| `ThemeMode`    | `PrfThemeMode`  | Light/dark/system theme settings                      |

### ✅ All Types Support:

- `get()` – read the current value (cached or from disk)
- `set(value)` – write and cache the value
- `remove()` – delete from disk and cache
- `isNull()` – check if null
- `getOrFallback(default)` – safely access with fallback
- `existsOnPrefs()` – check if a key is stored

### 🧠 Custom Types? No Problem

Want to persist something more complex? Use `PrfJson<T>` with any model that supports `toJson` and `fromJson`.

```dart
final userData = PrfJson<User>(
  'user',
  fromJson: (json) => User.fromJson(json),
  toJson: (user) => user.toJson(),
);
```

Or use `PrfEncoded<TSource, TStore>` to define your own encoding logic (e.g., compress/encrypt/etc).

### Also See [Persistent Services & Utilities:](#️-persistent-services--utilities)

- `PrfCooldown` — for managing cooldown periods (e.g. daily rewards, retry delays)
- `PrfRateLimiter` — token-bucket limiter for rate control (e.g. 1000 actions per 15 minutes)

# 🔁 Migrating from SharedPreferences to `prf`

Whether you're using the modern `SharedPreferencesAsync` or the legacy `SharedPreferences`, migrating to `prf` is simple and gives you cleaner, type-safe, and scalable persistence — without losing any existing data.

In fact, you can use `prf` with your current keys and values out of the box, preserving all previously stored data. But while backwards compatibility is supported, we recommend reviewing [all built-in types and utilities](#-available-methods-for-all-prf-types) that `prf` provides — such as `PrfDuration`, `PrfCooldown`, and `PrfRateLimiter` — which may offer a cleaner, more powerful way to structure your logic going forward, without relying on legacy patterns or custom code.

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
final darkMode = PrfBool('dark_mode');
await darkMode.set(true);
final isDark = await darkMode.get();
```

> ✅ **As long as you're using the same keys and types, your data will still be there. No migration needed.**  
> 🧼 **Or — if you don't care about previously stored values**, you can start fresh and use `prf` types right away.  
> They’re ready to go with clean APIs and built-in caching for all variable types (`bool`, `int`, `DateTime`, `Uint8List`, enums, and more).

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
final username = PrfString('username');
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
await Prf.migrateFromLegacyPrefsIfNeeded();
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
- 📦 **Out-of-the-box support** for `DateTime`, `Uint8List`, enums, full models (`PrfJson<T>`), and more

# ⚙️ Persistent Services & Utilities

In addition to typed variables, `prf` includes **ready-to-use persistent utilities** for common real-world use cases — built on top of the same caching and async-safe architecture.

These utilities handle state automatically across sessions and isolates, with no manual logic or timers.
They’re fully integrated into `prf`, use built-in types under the hood, and require no extra setup. Just define and use.

### Included utilities:

- 🔁 [**PrfCooldown**](#-prfcooldown--persistent-cooldown-utility) — for managing cooldown periods (e.g. daily rewards, retry delays)
- 📊 [**PrfRateLimiter**](#-prfratelimiter--persistent-token-bucket-rate-limiter) — token-bucket limiter for rate control (e.g. 1000 actions per 15 minutes)

---

### 🕒 `PrfCooldown` – Persistent Cooldown Utility

`PrfCooldown` is a plug-and-play utility for managing **cooldown windows** (e.g. daily rewards, button lockouts, retry delays) that persist across sessions and isolates — no timers, no manual bookkeeping, no re-implementation every time.

It handles:

- Cooldown timing (`DateTime.now()` + duration)
- Persistent storage via `prf` (with caching and async-safety)
- Activation tracking and expiration logic
- Usage statistics (activation count, expiry progress, etc.)

---

### 🔧 How to Use

Instantiate it with a unique prefix and a duration:

```dart
final cooldown = PrfCooldown('daily_reward', duration: Duration(hours: 24));
```

You can then use:

- `isCooldownActive()` — Returns `true` if the cooldown is still active
- `isExpired()` — Returns `true` if the cooldown has expired or was never started
- `activateCooldown()` — Starts the cooldown using the configured duration
- `tryActivate()` — Starts cooldown only if it's not active — returns whether it was triggered
- `reset()` — Clears the cooldown timer, but keeps the activation count
- `completeReset()` — Fully resets both the cooldown and its usage counter
- `timeRemaining()` — Returns remaining time as a `Duration`
- `secondsRemaining()` — Same as above, in seconds
- `percentRemaining()` — Progress indicator between `0.0` and `1.0`
- `getLastActivationTime()` — Returns `DateTime?` of last activation
- `getEndTime()` — Returns when the cooldown will end
- `whenExpires()` — Returns a `Future` that completes when the cooldown ends
- `getActivationCount()` — Returns the total number of activations
- `removeAll()` — Deletes all stored values (for testing/debugging)
- `anyStateExists()` — Returns `true` if any cooldown data exists in storage

Here’s the **tutorial section** for `PrfCooldown`, production-grade, clear, and aligned with your README style:

---

#### ✅ Define a Cooldown

```dart
final cooldown = PrfCooldown('daily_reward', duration: Duration(hours: 24));
```

This creates a persistent cooldown that lasts 24 hours. It uses the prefix `'daily_reward'` to store:

- Last activation timestamp
- Activation count

---

#### 🔍 Check If Cooldown Is Active

```dart
if (await cooldown.isCooldownActive()) {
  print('Wait before trying again!');
}
```

---

#### ⏱ Activate the Cooldown

```dart
await cooldown.activateCooldown();
```

This sets the cooldown to now and begins the countdown. The activation count is automatically incremented.

---

#### ⚡ Try Activating Only If Expired

```dart
if (await cooldown.tryActivate()) {
  print('Action allowed and cooldown started');
} else {
  print('Still cooling down...');
}
```

Use this for one-line cooldown triggers (e.g. claiming a daily gift or retrying a network call).

---

#### 🧼 Reset or Fully Clear Cooldown

```dart
await cooldown.reset();         // Clears only the time
await cooldown.completeReset(); // Clears time and resets usage counter
```

---

#### 🕓 Check Time Remaining

```dart
final remaining = await cooldown.timeRemaining();
print('Still ${remaining.inMinutes} minutes left');
```

You can also use:

```dart
await cooldown.secondsRemaining();   // int
await cooldown.percentRemaining();   // double between 0.0–1.0
```

---

#### 📅 View Timing Info

```dart
final lastUsed = await cooldown.getLastActivationTime();
final endsAt = await cooldown.getEndTime();
```

---

#### ⏳ Wait for Expiry (e.g. for auto-retry)

```dart
await cooldown.whenExpires(); // Completes only when cooldown is over
```

---

#### 📊 Get Activation Count

```dart
final count = await cooldown.getActivationCount();
print('Used $count times');
```

---

#### 🧪 Test Utilities

```dart
await cooldown.removeAll();      // Clears all stored cooldown state
final exists = await cooldown.anyStateExists(); // Returns true if anything is stored
```

---

> You can create as many cooldowns as you need — each with a unique prefix.  
> All state is persisted, isolate-safe, and instantly reusable.

# 📊 `PrfRateLimiter` – Persistent Token Bucket Rate Limiter

`PrfRateLimiter` is a high-performance, plug-and-play utility that implements a **token bucket** algorithm to enforce rate limits — like “100 actions per 15 minutes” — across sessions, isolates, and app restarts.

It handles:

- Token-based rate limiting
- Automatic time-based token refill
- Persistent state using `prf` types (`PrfDouble`, `PrfDateTime`)
- Async-safe, isolate-compatible behavior with built-in caching

Perfect for chat limits, API quotas, retry windows, or any action frequency cap — all stored locally.

---

### 🔧 How to Use

Create a limiter with a unique key, a max token count, and a refill window:

```dart
final limiter = PrfRateLimiter('chat_send', maxTokens: 100, refillDuration: Duration(minutes: 15));
```

You can then use:

- `tryConsume()` — Tries to use 1 token; returns `true` if allowed, or `false` if rate-limited
- `isLimitedNow()` — Returns `true` if no tokens are currently available
- `isReady()` — Returns `true` if at least one token is available
- `getAvailableTokens()` — Returns the current number of usable tokens (calculated live)
- `timeUntilNextToken()` — Returns a `Duration` until at least one token will be available
- `nextAllowedTime()` — Returns the exact `DateTime` when a token will be available
- `reset()` — Resets to full token count and updates last refill to now
- `removeAll()` — Deletes all limiter state (for testing/debugging)
- `anyStateExists()` — Returns `true` if limiter data exists in storage
- `runIfAllowed(action)` — Runs a callback if allowed, otherwise returns `null`
- `debugStats()` — Returns detailed internal stats for logging and debugging

The limiter uses fractional tokens internally to maintain precise refill rates, even across app restarts. No timers or background services required — it just works.

---

#### ✅ `PrfRateLimiter` Basic Setup

Create a limiter with a key, a maximum number of actions, and a refill duration:

```dart
final limiter = PrfRateLimiter(
  'chat_send',
  maxTokens: 100,
  refillDuration: Duration(minutes: 15),
);
```

This example allows up to **100 actions per 15 minutes**. The token count is automatically replenished over time — even after app restarts.

---

#### 🚀 Check & Consume

To attempt an action:

```dart
final canSend = await limiter.tryConsume();

if (canSend) {
  // Allowed – proceed with the action
} else {
  // Blocked – too many actions, rate limit hit
}
```

Returns `true` if a token was available and consumed, or `false` if the limit was exceeded.

---

#### 🧮 Get Available Tokens

To check how many tokens are usable at the moment:

```dart
final tokens = await limiter.getAvailableTokens();
print('Tokens left: ${tokens.toStringAsFixed(2)}');
```

Useful for debugging, showing rate limit progress, or enabling/disabling UI actions.

---

#### ⏳ Time Until Next Token

To wait or show feedback until the next token becomes available:

```dart
final waitTime = await limiter.timeUntilNextToken();
print('Try again in: ${waitTime.inSeconds}s');
```

You can also get the actual time point:

```dart
final nextTime = await limiter.nextAllowedTime();
```

---

#### 🔁 Reset the Limiter

To fully refill the bucket and reset the refill clock:

```dart
await limiter.reset();
```

Use this after manual overrides, feature unlocks, or privileged user actions.

---

#### 🧼 Clear All Stored State

To wipe all saved token/refill data (for debugging or tests):

```dart
await limiter.removeAll();
```

To check if the limiter has any stored state:

```dart
final exists = await limiter.anyStateExists();
```

With `PrfRateLimiter`, you get a production-grade rolling window limiter with zero boilerplate — fully persistent and ready for real-world usage.

# 🛣️ Roadmap & Future Plans

`prf` is built for simplicity, performance, and scalability. Upcoming improvements focus on expanding flexibility while maintaining a zero-boilerplate experience.

### ✅ Planned Enhancements

- **Improved performance**  
  Smarter caching and leaner async operations.

- **Additional type support**  
  Encrypted strings, and more.

- **Custom storage** _(experimental)_  
  Support for alternative adapters (Hive, Isar, file system).

- **Testing & tooling**  
  In-memory test adapter, debug inspection tools, and test utilities.

- **Optional code generation**  
  Annotations for auto-registering variables and reducing manual setup.

# 🔍 Why `prf` Wins in Real Apps

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
final username = PrfString('username');
final isFirstLaunch = PrfBool('is_first_launch', defaultValue: true);
final signupDate = PrfDateTime('signup_date');

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
final prefs = await SharedPreferences.getInstance();

final json = jsonEncode(user.toJson());
await prefs.setString('user_data', json);

// Read
final raw = prefs.getString('user_data');
User? user;
if (raw != null) {
  try {
    final decoded = jsonDecode(raw);
    user = User.fromJson(decoded);
  } catch (_) {
    // fallback or error
  }
}
```

---

### ✅ Same Logic with `prf`

```dart
final userData = PrfJson<User>(
  'user_data',
  fromJson: User.fromJson,
  toJson: (u) => u.toJson(),
);

// Save
await userData.set(user);

// Read
final savedUser = await userData.get(); // User?
```

🧠 Fully typed. Automatically parsed. Fallback-safe. Reusable across your app.

---

### ⚙️ Built for Real Apps

`prf` was built to eliminate the day-to-day pain of using SharedPreferences in production codebases:

- ✅ Define once — reuse anywhere
- ✅ Clean API — `get()`, `set()`, `remove()`, `isNull()` for all types
- ✅ Supports advanced types: `DateTime`, `Uint8List`, `enum`, `JSON`
- ✅ Automatic caching — fast access after first read
- ✅ Test-friendly — easily reset, mock, or inspect values

---

## 🔗 License MIT © Jozz
