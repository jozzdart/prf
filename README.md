![img](https://i.imgur.com/pAUltto.png)

<h3 align="center"><i>Define. Get. Set. Done.</i></h3>
<p align="center">
        <img src="https://img.shields.io/codefactor/grade/github/jozzzzep/prf/main?style=flat-square">
        <img src="https://img.shields.io/github/license/jozzzzep/prf?style=flat-square">
        <img src="https://img.shields.io/pub/points/prf?style=flat-square">
        <img src="https://img.shields.io/pub/v/prf?style=flat-square">
</p>

No boilerplate. No repeated strings. No setup. Define your variables once, then `get()` and `set()` them anywhere with zero friction. `prf` makes local persistence faster, simpler, and easier to scale.

> Supports more types than SharedPreferences out of the box — including `DateTime`, `Uint8List`, enums, and full JSON.

- [Introduction](#-define--get--set--done)
- [Why Use `prf`?](#-why-use-prf)
- [**SharedPreferences** vs `prf`](#-sharedpreferences-vs-prf)
- [Setup & Basic Usage (Step-by-Step)](#-setup--basic-usage-step-by-step)
- [Available Methods for All `prf` Types](#-available-methods-for-all-prf-types)
- [Supported `prf` Types](#-supported-prf-types)
- [Roadmap & Future Plans](#️-roadmap--future-plans)

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

That’s it. You're done.

> Works with: `int`, `double`, `bool`, `String`, `List<String>`,  
> and advanced types like `DateTime`, `Uint8List`, enums, and full JSON objects.

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
- ✅ **Supports more than just primitives**
  - `String`, `int`, `double`, `bool`, `List<String>`
  - `DateTime`, `Uint8List`, enums, and full JSON objects
- ✅ **Built for testing** — easily reset or mock storage in tests
- ✅ **Cleaner codebase** — no more scattered `prefs.get...()` or typo-prone string keys

---

### 🔁 `SharedPreferences` vs `prf`

| Feature                         | `SharedPreferences` (raw)                                 | `prf`                                                           |
| ------------------------------- | --------------------------------------------------------- | --------------------------------------------------------------- |
| **Define Once, Reuse Anywhere** | ❌ Manual strings everywhere                              | ✅ One-line variable definition                                 |
| **Type Safety**                 | ❌ Requires manual casting                                | ✅ Fully typed, no casting needed                               |
| **Readability**                 | ❌ Repetitive and verbose                                 | ✅ Clear, concise, expressive                                   |
| **Centralized Keys**            | ❌ You manage key strings                                 | ✅ Keys are defined as variables                                |
| **Caching**                     | ❌ No built-in caching                                    | ✅ Automatic in-memory caching                                  |
| **Lazy Initialization**         | ❌ Must await `getInstance()` manually                    | ✅ Internally managed                                           |
| **Supports Primitives**         | ✅ Yes                                                    | ✅ Yes                                                          |
| **Supports Advanced Types**     | ❌ No (`DateTime`, `enum`, etc. must be encoded manually) | ✅ Built-in support for `DateTime`, `Uint8List`, `enum`, `JSON` |

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

| Type           | Class           | Common Use Cases                              |
| -------------- | --------------- | --------------------------------------------- |
| `bool`         | `PrfBool`       | Feature flags, settings toggles               |
| `int`          | `PrfInt`        | Counters, scores, timestamps                  |
| `double`       | `PrfDouble`     | Ratings, sliders, precise values              |
| `String`       | `PrfString`     | Usernames, tokens, IDs                        |
| `List<String>` | `PrfStringList` | Tags, recent items, multi-select options      |
| `Uint8List`    | `PrfBytes`      | Binary data (images, keys, QR codes)          |
| `DateTime`     | `PrfDateTime`   | Timestamps, cooldowns, scheduled actions      |
| `enum`         | `PrfEnum<T>`    | Typed modes, states, user roles               |
| `T (via JSON)` | `PrfJson<T>`    | Full model objects with `toJson` / `fromJson` |

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

# 🛣️ Roadmap & Future Plans

`prf` is built for simplicity, performance, and scalability. Upcoming improvements focus on expanding flexibility while maintaining a zero-boilerplate experience.

### ✅ Planned Enhancements

- **Improved performance**  
  Smarter caching and leaner async operations.

- **Additional type support**  
  `Duration`, `BigInt`, encrypted strings, and enhanced `PrfJson<T>`.

- **Custom storage** _(experimental)_  
  Support for alternative adapters (Hive, Isar, file system).

- **Testing & tooling**  
  In-memory test adapter, debug inspection tools, and test utilities.

- **Optional code generation**  
  Annotations for auto-registering variables and reducing manual setup.

---

## 🔗 License MIT © Jozz
