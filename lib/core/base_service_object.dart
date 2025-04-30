abstract class BaseServiceObject {
  /// Whether to use in-memory cache for performance.
  ///
  /// - When `true`, values are cached in memory and are **NOT isolate-safe**.
  /// - When `false` (default), values are read directly from disk and are **fully isolate-safe**.
  final bool useCache;

  const BaseServiceObject({this.useCache = false});
}
