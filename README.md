<a id="back-to-top"></a>
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

No boilerplate. No repeated strings. No setup. Define your variables once, then `get()` and `set()` them anywhere with zero friction. `prf` makes local persistence faster, simpler, and easier to scale. Supports 20+ built-in types and includes utilities like persistent cooldowns, rate limiters and stats. Designed to fully replace raw use of `SharedPreferences`.

> Supports way more types than **SharedPreferences** — including `enums` `DateTime` `JSON models` +20 types and also special services `PrfCooldown` `PrfRateLimiter` `PrfTrackers` for production ready persistent cooldowns, rate limiters and stats.

- [Introduction](#-define--get--set--done)
- [Why Use `prf`?](#-why-use-prf)
- [**SharedPreferences** vs `prf`](#-sharedpreferences-vs-prf)
- [Setup & Basic Usage (Step-by-Step)](#-setup--basic-usage-step-by-step)
- [Available Methods for All `prf` Types](#-available-methods-for-all-prf-types)
- [Supported `prf` Types](#-supported-prf-types)
- [Accessing `prf` Without async](#-accessing-prf-without-async)
- [Migrating from _SharedPreferences_ to `prf`](#-migrating-from-sharedpreferences-to-prf)
- [Persistent Services & Utilities](#️-persistent-services--utilities)
- [Roadmap & Future Plans](#️-roadmap--future-plans)
- [Why `prf` Wins in Real Apps](#-why-prf-wins-in-real-apps)
- [Adding Custom Prfs (Advanced)](#️-how-to-add-a-custom-prf-type-advanced)

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

- `bool` `int` `double` `String` `num` `Duration` `DateTime` `BigInt` `Uri` `Uint8List` (binary data)
- `List<String>` `List<int>` `List<bool>` `List<double>` `List<DateTime>`
- [JSON & enums](#-supported-prf-types)
- [Special Services & Utilities](#️-persistent-services--utilities)

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
- ✅ **True isolate safety** — with `.isolated`
- ✅ **Lazy initialization** — no need to manually call `SharedPreferences.getInstance()`
- ✅ **Supports more than just primitives** — [20+ types](#-available-methods-for-all-prf-types), including `DateTime`, `Enums`, `BigInt`, `Duration`, `JSON`
- ✅ **Built for testing** — easily reset, override, or mock storage
- ✅ **Cleaner codebase** — no more scattered `prefs.get...()` or typo-prone string keys
- ✅ [**Persistent utilities included**](#️-persistent-services--utilities) —
  - `PrfCooldown` – manage cooldown windows (e.g. daily rewards)
  - `PrfRateLimiter` – token-bucket limiter (e.g. 1000 actions per 15 minutes)
  - `PrfPeriodicCounter` – aligned auto-resetting counters (e.g. daily logins, hourly tasks)
  - `PrfRolloverCounter` – window counters that reset after a fixed duration (e.g. 10-minute retry limits)

---

### 🔁 `SharedPreferences` vs `prf`

[⤴️ Back](#back-to-top) -> Table of Contents

| Feature                         | `SharedPreferences` (raw)                                                 | `prf`                                                                                                  |
| ------------------------------- | ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| **Define Once, Reuse Anywhere** | ❌ Manual strings everywhere                                              | ✅ One-line variable definition                                                                        |
| **Type Safety**                 | ❌ Requires manual casting                                                | ✅ Fully typed, no casting needed                                                                      |
| **Readability**                 | ❌ Repetitive and verbose                                                 | ✅ Clear, concise, expressive                                                                          |
| **Centralized Keys**            | ❌ You manage key strings                                                 | ✅ Keys are defined as variables                                                                       |
| **Lazy Initialization**         | ❌ Must await `getInstance()` manually                                    | ✅ Internally managed                                                                                  |
| **Supports Primitives**         | ✅ Yes                                                                    | ✅ Yes                                                                                                 |
| **Supports Advanced Types**     | ❌ No (`DateTime`, `enum`, etc. must be encoded manually)                 | ✅ Built-in support for `DateTime`, `Uint8List`, `enum`, `JSON`                                        |
| **Special Persistent Services** | ❌ None                                                                   | ✅ `PrfCooldown`, `PrfRateLimiter`, and more in the future                                             |
| **Isolate Support**             | ⚠️ Partial — must manually choose between caching or no-caching APIs      | ✅ Just `.isolate` for full isolate-safety<br>✅ `Prf<T>` for faster cached access (not isolate-safe)  |
| **Caching**                     | ✅ Yes (`SharedPreferencesWithCache`) or ❌ No (`SharedPreferencesAsync`) | ✅ Automatic in-memory caching with `Prf<T>`<br>✅ No caching with `PrfIso<T>` for true isolate-safety |

# 📌 Code Comparison

[⤴️ Back](#back-to-top) -> Table of Contents

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

---

If you're tired of:

- Duplicated string keys
- Manual casting and null handling
- Scattered async boilerplate

Then `prf` is your drop-in solution for **fast, safe, scalable, and elegant local persistence** — whether you want **maximum speed** (using `Prf`) or **full isolate safety** (using `PrfIso`).

# 🚀 Setup & Basic Usage (Step-by-Step)

[⤴️ Back](#back-to-top) -> Table of Contents

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
final playerCoins = Prf<int>('player_coins', defaultValue: 0);
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

[⤴️ Back](#back-to-top) -> Table of Contents

All `prf` types (both `Prf<T>` and `PrfIso<T>`) support the following methods:

| Method                    | Description                                               |
| ------------------------- | --------------------------------------------------------- |
| `get()`                   | Returns the current value (cached or from disk).          |
| `set(value)`              | Saves the value and updates the cache (if applicable).    |
| `remove()`                | Deletes the value from storage (and cache if applicable). |
| `isNull()`                | Returns `true` if the value is `null`.                    |
| `getOrFallback(fallback)` | Returns the value or a fallback if `null`.                |
| `existsOnPrefs()`         | Checks if the key exists in storage.                      |

> ✅ Available on **all `Prf<T>` and `PrfIso<T>` types** — consistent, type-safe, and ready to use anywhere in your app. It's even easier to make prf isolate safe just by calling `.isolate` on your prfs!

These are practically the same:

```dart
final safeUser = Prf<String>('username').isolated; // Same
final safeUser = PrfIso<String>('username');       // Same
```

---

# 🔤 Supported `prf` Types

[⤴️ Back](#back-to-top) -> Table of Contents

All of these work out of the box:

- `bool`
- `int`
- `double`
- `num`
- `String`
- `Duration`
- `DateTime`
- `Uri`
- `BigInt`
- `List<String>`
- `List<int>`
- `List<bool>`
- `List<double>`
- `List<DateTime>`
- `Uint8List` (binary data)

### Specialized Types

For enums and custom JSON models, use the built-in factory methods:

- `Prf.enumerated<T>()` — for enum values
- `Prf.json<T>()` — for custom model objects

### Also See [Persistent Services & Utilities:](#️-persistent-services--utilities)

- `PrfCooldown` — for managing cooldown periods (e.g. daily rewards, retry delays)
- `PrfRateLimiter` — token-bucket limiter for rate control (e.g. 1000 actions per 15 minutes)
- `PrfPeriodicCounter` — for tracking actions within aligned time periods (e.g. daily submissions, hourly usage); auto-resets at the start of each period
- `PrfRolloverCounter` — for tracking actions over a rolling duration (e.g. 10-minute retry attempts); resets after a fixed interval since last activity

---

### 🎯 Example: Persisting an Enum

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

Need full control? You can create fully custom persistent types by:

- Extending `CachedPrfObject<T>` (for cached access)
- Or extending `BasePrfObject<T>` (for isolate-safe direct access)
- And defining your own `PrfEncodedAdapter<T>` for custom serialization, compression, or encryption.

# ⚡ Accessing `prf` Without Async

[⤴️ Back](#back-to-top) -> Table of Contents

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

✅ Best for fast access inside UI widgets, settings screens, and forms. ⚠️ Not suitable for use across isolates — use `.isolated` or `PrfIso<T>` if you need isolate safety.

### 🚀 Quick Summary

- `await Prf.value<T>()` → loads and caches the value.
- `.cachedValue` → direct, instant access afterward.
- No async needed for future reads!

# 🔁 Migrating from SharedPreferences to `prf`

[⤴️ Back](#back-to-top) -> Table of Contents

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
final darkMode = Prf<bool>('dark_mode');
await darkMode.set(true);
final isDark = await darkMode.get();
```

- ✅ **As long as you're using the same keys and types, your data will still be there. No migration needed.**
- 🧼 **Or — if you don't care about previously stored values**, you can start fresh and use `prf` types right away. They’re ready to go with clean APIs and built-in caching for all variable types (`bool`, `int`, `DateTime`, `Uint8List`, enums, and more).

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
- 📦 **Out-of-the-box support** for `DateTime`, `Uint8List`, enums, full models (`PrfJson<T>`), and more

# ⚙️ Persistent Services & Utilities

[⤴️ Back](#back-to-top) -> Table of Contents

In addition to typed variables, `prf` includes **ready-to-use persistent utilities** for common real-world use cases — built on top of the same caching and async-safe architecture.

These utilities handle state automatically across sessions and isolates, with no manual logic or timers.  
They’re fully integrated into `prf`, use built-in types under the hood, and require no extra setup. Just define and use.

### Included utilities:

- 🔁 [**PrfCooldown**](#-prfcooldown--persistent-cooldown-utility) — for managing cooldown periods (e.g. daily rewards, retry delays)
- 📊 [**PrfRateLimiter**](#-prfratelimiter--persistent-token-bucket-rate-limiter) — token-bucket limiter for rate control (e.g. 1000 actions per 15 minutes)
- 📅 [**PrfPeriodicCounter**](#-prfperiodiccounter--aligned-time-based-counter) — auto-resetting counter for aligned time periods (e.g. daily tasks, hourly pings, weekly goals)
- ⏳ [**PrfRolloverCounter**](#-prfrollovercounter--sliding-window-counter) — sliding-window counter that resets a fixed duration after each activity (e.g. 10-minute retry window, actions per hour)

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

[⤴️ Back](#️-persistent-services--utilities) -> ⚙️ Persistent Services & Utilities

`PrfRateLimiter` is a high-performance, plug-and-play utility that implements a **token bucket** algorithm to enforce rate limits — like “100 actions per 15 minutes” — across sessions, isolates, and app restarts.

It handles:

- Token-based rate limiting
- Automatic time-based token refill
- Persistent state using `prf` types (`PrfIso<double>`, `PrfIso<DateTime>`)
- Async-safe, isolate-compatible behavior

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

---

### 📅 `PrfPeriodicCounter` – Aligned Time-Based Counter

[⤴️ Back](#️-persistent-services--utilities) -> ⚙️ Persistent Services & Utilities

`PrfPeriodicCounter` is a persistent counter that **automatically resets at the start of each aligned time period**, such as _daily_, _hourly_, or every _10 minutes_. It’s perfect for tracking time-bound events like “daily logins,” “hourly uploads,” or “weekly tasks,” without writing custom reset logic.

It handles:

- Aligned period math (e.g. resets every day at 00:00)
- Persistent storage via `prf` (`PrfIso<int>` and `PrfIso<DateTime>`)
- Auto-expiring values based on time alignment
- Counter tracking with optional increment amounts
- Period progress and time tracking

---

### 🔧 How to Use

Create a periodic counter with a unique key and a `TrackerPeriod`, you can then use:

- `get()` — Returns the current counter value (auto-resets if needed)
- `increment()` — Increments the counter, by a given amount (1 is the default)
- `reset()` — Manually resets the counter and aligns the timestamp to the current period start
- `peek()` — Returns the current value without checking or triggering expiration
- `raw()` — Alias for `peek()` (useful for debugging or display)
- `isNonZero()` — Returns `true` if the counter value is greater than zero
- `clearValueOnly()` — Resets only the counter, without modifying the timestamp
- `clear()` — Removes all stored values, including the timestamp
- `hasState()` — Returns `true` if any persistent state exists
- `isCurrentlyExpired()` — Returns `true` if the counter would reset right now
- `getLastUpdateTime()` — Returns the last reset-aligned timestamp
- `timeSinceLastUpdate()` — Returns how long it’s been since the last reset

You can also access **period-related properties**:

- `currentPeriodStart` — Returns the `DateTime` representing the current aligned period start
- `nextPeriodStart` — Returns the `DateTime` when the next period will begin
- `timeUntilNextPeriod` — Returns a `Duration` until the next reset occurs
- `elapsedInCurrentPeriod` — How much time has passed since the period began
- `percentElapsed` — A progress indicator (0.0 to 1.0) showing how far into the period we are

---

### ⏱ Available Periods (`TrackerPeriod`)

You can choose from a wide range of aligned time intervals:

- Seconds:  
  `seconds10`, `seconds20`, `seconds30`

- Minutes:  
  `minutes1`, `minutes2`, `minutes3`, `minutes5`, `minutes10`,  
  `minutes15`, `minutes20`, `minutes30`

- Hours:  
  `hourly`, `every2Hours`, `every3Hours`, `every6Hours`, `every12Hours`

- Days and longer:  
  `daily`, `weekly`, `monthly`

Each period is aligned automatically — e.g., daily resets at midnight, weekly at the start of the week, monthly on the 1st.

---

#### ✅ Define a Periodic Counter

```dart
final counter = PrfPeriodicCounter('daily_uploads', period: TrackerPeriod.daily);
```

This creates a persistent counter that **automatically resets at the start of each aligned period** (e.g. daily at midnight).  
It uses the prefix `'daily_uploads'` to store:

- The counter value (`int`)
- The last reset timestamp (`DateTime` aligned to period start)

---

#### ➕ Increment the Counter

```dart
await counter.increment();           // adds 1
await counter.increment(3);         // adds 3
```

You can increment by any custom amount. The value will reset if expired before incrementing.

---

#### 🔢 Get the Current Value

```dart
final count = await counter.get();
```

This returns the current counter value, automatically resetting it if the period expired.

---

#### 👀 Peek at Current Value (Without Reset Check)

```dart
final raw = await counter.peek();
```

Returns the current stored value without checking expiration or updating anything.  
Useful for diagnostics, stats, or UI display.

---

#### ✅ Check If Counter Is Non-Zero

```dart
final hasUsage = await counter.isNonZero();
```

Returns `true` if the current value is greater than zero.

---

#### 🔄 Manually Reset the Counter

```dart
await counter.reset();
```

Resets the value to zero and stores the current aligned timestamp.

---

#### ✂️ Clear Stored Counter Only (Preserve Timestamp)

```dart
await counter.clearValueOnly();
```

Resets the counter but **keeps the current period alignment** intact.

---

#### 🗑️ Clear All Stored State

```dart
await counter.clear();
```

Removes both value and timestamp from persistent storage.

---

#### ❓ Check if Any State Exists

```dart
final exists = await counter.hasState();
```

Returns `true` if the counter or timestamp exist in SharedPreferences.

---

#### ⌛ Check if Current Period Is Expired

```dart
final expired = await counter.isCurrentlyExpired();
```

Returns `true` if the stored timestamp is from an earlier period than now.

---

#### 🕓 View Timing Info

```dart
final last = await counter.getLastUpdateTime();     // last reset-aligned timestamp
final since = await counter.timeSinceLastUpdate();  // Duration since last reset
```

---

#### 📆 Period Insight & Progress

```dart
final start = counter.currentPeriodStart;      // start of this period
final next = counter.nextPeriodStart;          // start of the next period
final left = counter.timeUntilNextPeriod;      // how long until reset
final elapsed = counter.elapsedInCurrentPeriod; // time passed in current period
final percent = counter.percentElapsed;        // progress [0.0–1.0]
```

---

### ⏳ `PrfRolloverCounter` – Sliding Window Counter

[⤴️ Back](#️-persistent-services--utilities) -> ⚙️ Persistent Services & Utilities

`PrfRolloverCounter` is a persistent counter that automatically resets itself after a fixed duration from the last update. Ideal for tracking **rolling activity windows**, such as "submissions per hour", "attempts every 10 minutes", or "usage in the past day".

It handles:

- Time-based expiration with a sliding duration window
- Persistent storage using `PrfIso<int>` for full isolate-safety
- Seamless session persistence and automatic reset logic
- Rich time utilities to support countdowns, progress indicators, and timer-based UI logic

---

### 🔧 How to Use

- `get()` — Returns the current counter value (auto-resets if expired)
- `increment([amount])` — Increases the count by `amount` (default: `1`)
- `reset()` — Manually resets the counter and sets a new expiration time
- `clear()` — Deletes all stored state from preferences
- `hasState()` — Returns `true` if any saved state exists
- `peek()` — Returns the current value without triggering a reset
- `getLastUpdateTime()` — Returns the last update timestamp, or `null` if never used
- `isCurrentlyExpired()` — Returns `true` if the current window has expired
- `timeSinceLastUpdate()` — Returns how much time has passed since last use
- `timeRemaining()` — Returns how much time remains before auto-reset
- `secondsRemaining()` — Same as above, in seconds
- `percentElapsed()` — Progress of the current window as a `0.0–1.0` value
- `getEndTime()` — Returns the `DateTime` when the current window ends
- `whenExpires()` — Completes when the reset window expires

---

#### ✅ Define a Rollover Counter

```dart
final counter = PrfRolloverCounter('usage_counter', resetEvery: Duration(minutes: 10));
```

This creates a persistent counter that resets automatically 10 minutes after the last update. It uses the key `'usage_counter'` to store:

- Last update timestamp
- Rolling count value

---

#### ➕ Increment the Counter

```dart
await counter.increment();         // +1
await counter.increment(5);        // +5
```

This also refreshes the rollover timer.

---

#### 📈 Get the Current Value

```dart
final count = await counter.get(); // Auto-resets if expired
```

You can also check the value without affecting expiration:

```dart
final value = await counter.peek();
```

---

#### 🔄 Reset or Clear the Counter

```dart
await counter.reset(); // Sets count to 0 and updates timestamp
await counter.clear(); // Deletes all stored state
```

---

#### 🕓 Check Expiration Status

```dart
final expired = await counter.isCurrentlyExpired(); // true/false
```

You can also inspect metadata:

```dart
final lastUsed = await counter.getLastUpdateTime();
final since = await counter.timeSinceLastUpdate();
```

---

#### ⏳ Check Time Remaining

```dart
final duration = await counter.timeRemaining();
final seconds = await counter.secondsRemaining();
final percent = await counter.percentElapsed(); // 0.0–1.0
```

These can be used for progress bars, countdowns, etc.

---

#### 📅 Get the End Time

```dart
final end = await counter.getEndTime(); // DateTime when it auto-resets
```

---

#### 💤 Wait for Expiry

```dart
await counter.whenExpires(); // Completes when timer ends
```

Useful for polling, UI disable windows, etc.

---

#### 🧪 Test Utilities

```dart
await counter.clear();          // Removes all saved values
final exists = await counter.hasState(); // true if anything stored
```

---

# 🛣️ Roadmap & Future Plans

[⤴️ Back](#back-to-top) -> Table of Contents

`prf` is built for simplicity, performance, and scalability. Upcoming improvements focus on expanding flexibility while maintaining a zero-boilerplate experience.

### ✅ Planned Enhancements

- **Improved performance**
  Smarter caching and leaner async operations.

- Additional type support, Encryption, and more.

- **Custom storage**
  Support for alternative adapters (Hive, Isar, file system).

- **Testing & tooling**
  In-memory test adapter, debug inspection tools, and test utilities.

- **Optional code generation**
  Annotations for auto-registering variables and reducing manual setup.

# 🔍 Why `prf` Wins in Real Apps

[⤴️ Back](#back-to-top) -> Table of Contents

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
- ✅ Supports advanced types: `DateTime`, `Uint8List`, `enum`, `JSON`
- ✅ Automatic caching — fast access after first read
- ✅ Test-friendly — easily reset, mock, or inspect values

---

# 🛠️ How to Add a Custom `prf` Type (Advanced)

[⤴️ Back](#back-to-top) -> Table of Contents

For most use cases, you can simply use the built-in `Prf.enumerated<T>()`, `Prf.json<T>()`, `PrfIso.enumerated<T>()`, or `PrfIso.json<T>()` factories to persist enums and custom models easily.

This guide is for advanced scenarios where you need full control over how a type is stored — such as custom encoding, compression, or special storage behavior.

Expanding `prf` is simple:  
Just create a custom adapter and treat your new type like any other!

## 1. Create Your Class

```dart
class Color {
  final int r, g, b;
  const Color(this.r, this.g, this.b);

  Map<String, dynamic> toJson() => {'r': r, 'g': g, 'b': b};
  factory Color.fromJson(Map<String, dynamic> json) => Color(
    json['r'] ?? 0, json['g'] ?? 0, json['b'] ?? 0,
  );
}
```

### 2. Create an Adapter

```dart
import 'dart:convert';
import 'package:prf/prf.dart';

class ColorAdapter extends PrfEncodedAdapter<Color, String> {
  @override
  Color? decode(String? stored) =>
      stored == null ? null : Color.fromJson(jsonDecode(stored));

  @override
  String encode(Color value) => jsonEncode(value.toJson());
}
```

### 3. (Optional) Register It

```dart
PrfAdapterMap.instance.register<Color>(ColorAdapter());
```

> So you can use `Prf<Color>` without passing an adapter manually.

### 4. Use It!

```dart
final favoriteColor = Prf<Color>('favorite_color');

await favoriteColor.set(Color(255, 0, 0));
final color = await favoriteColor.get();

print(color?.r); // 255
```

For isolate-safe persistence:

```dart
final safeColor = favoriteColor.isolated;                // Same
final safeColor = Prf<Color>('favorite_color').isolated; // Same
final safeColor = PrfIso<Color>('favorite_color');       // Same
```

## Summary

- Create your class.
- Create a `PrfEncodedAdapter`.
- (Optional) Register it.
- Use `Prf<T>` or `PrfIso<T>` anywhere.

---

## 🔗 License MIT © Jozz
