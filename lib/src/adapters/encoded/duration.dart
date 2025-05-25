import 'package:prf/prf.dart';

/// Adapter for Duration objects.
///
/// Stores Duration as microseconds in an integer.
class DurationAdapter extends PrfEncodedAdapter<Duration, int> {
  /// Creates a new Duration adapter.
  const DurationAdapter() : super(const IntAdapter());

  @override
  Duration? decode(int? stored) {
    if (stored == null) return null;
    return Duration(microseconds: stored);
  }

  @override
  int encode(Duration value) => value.inMicroseconds;
}
