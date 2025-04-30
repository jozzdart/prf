/// An abstract base class for service objects that provides caching options.
///
/// The `BaseServiceObject` class serves as a foundational class for service
/// objects that require caching capabilities. It offers a mechanism to
/// determine whether to use in-memory caching or to read values directly
/// from disk, which can impact performance and isolate-safety.
///
/// ## Usage
///
/// Extend this class to create a service object that benefits from caching.
/// You can control the caching behavior by setting the [useCache] parameter
/// in the constructor.
///
/// ```dart
/// class MyServiceObject extends BaseServiceObject {
///   MyServiceObject({bool useCache = false}) : super(useCache: useCache);
/// }
/// ```
///
/// ## Caching Behavior
///
/// - **In-Memory Cache (`useCache = true`)**:
///   - Values are cached in memory for faster access.
///   - Not safe for use across isolates, meaning it should be used when
///     isolate-safety is not a concern.
///
/// - **Disk Cache (`useCache = false`)**:
///   - Values are read directly from disk, ensuring data consistency
///     across isolates.
///   - This is the default behavior and is recommended for most use cases
///     where isolate-safety is required.
///
/// ## Constructor
///
/// - `BaseServiceObject({bool useCache = false})`:
///   - [useCache]: A boolean flag indicating whether to use in-memory
///     caching. Defaults to `false`.
abstract class BaseServiceObject {
  /// Whether to use in-memory cache for performance.
  ///
  /// - When `true`, values are cached in memory and are **NOT isolate-safe**.
  /// - When `false` (default), values are read directly from disk and are **fully isolate-safe**.
  final bool useCache;

  /// Creates a new instance of [BaseServiceObject].
  ///
  /// The [useCache] parameter determines the caching strategy.
  const BaseServiceObject({this.useCache = false});
}
