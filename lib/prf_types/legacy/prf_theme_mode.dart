import 'package:flutter/material.dart';
import 'package:prf/prfy_types/prf_enum.dart';

/// A cached preference for ThemeMode.
///
/// This class is deprecated. Use [Prf.enumerated] instead.
///
/// Example:
/// ```dart
/// final theme = Prf.enumerated<ThemeMode>('theme', values: ThemeMode.values);
/// ```
@Deprecated(
    'Use Prf.enumerated instead. This class will be removed in a future version.')
class PrfThemeMode extends PrfEnum<ThemeMode> {
  /// Creates a new cached ThemeMode preference.
  @Deprecated(
      'Use Prf.enumerated instead. This constructor will be removed in a future version.')
  PrfThemeMode(super.key, {super.defaultValue = ThemeMode.system})
      : super(values: ThemeMode.values);
}
