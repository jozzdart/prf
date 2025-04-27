import 'package:prf/prf.dart';

/// An isolate-safe preference object specialized for storing enum values.
///
/// This class provides type-safe access to enum values stored in SharedPreferences,
/// without in-memory caching to ensure consistency across isolates. It uses
/// [EnumAdapter] to convert enum values to their integer indices for storage.
///
/// Unlike [PrfEnum], this implementation always reads from disk, making it
/// suitable for use in multiple isolates where cached values might become stale.
///
/// Example:
/// ```dart
/// enum LogLevel { debug, info, warning, error }
///
/// final logLevelPref = PrfyEnum<LogLevel>(
///   'log_level',
///   values: LogLevel.values,
///   defaultValue: LogLevel.info,
/// );
///
/// await logLevelPref.set(LogLevel.warning);
/// final level = await logLevelPref.get(); // Always reads from disk
/// ```
class PrfyEnum<T extends Enum> extends BasePrfObject<T> {
  /// The adapter used for enum value conversion.
  final EnumAdapter<T> _adapter;

  @override

  /// Gets the adapter used to convert between the enum and its storage representation.
  EnumAdapter<T> get adapter => _adapter;

  /// Creates a new isolate-safe enum preference.
  ///
  /// - [key] is the key to store the preference under.
  /// - [values] is the list of all possible enum values, typically EnumType.values.
  /// - [defaultValue] is the optional default value to use when no value exists.
  PrfyEnum(super.key, {required List<T> values, super.defaultValue})
      : _adapter = EnumAdapter<T>(values);
}
