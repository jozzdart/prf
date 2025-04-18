part of 'prf_rate_limiter.dart';

class PrfRateLimiterStats {
  final double tokens;
  final DateTime lastRefill;
  final double maxTokens;
  final Duration refillDuration;
  final DateTime now;
  final double refillRatePerMs;
  final double refilledTokens;
  final double cappedTokenCount;

  const PrfRateLimiterStats({
    required this.tokens,
    required this.lastRefill,
    required this.maxTokens,
    required this.refillDuration,
    required this.now,
    required this.refillRatePerMs,
    required this.refilledTokens,
    required this.cappedTokenCount,
  });

  @override
  String toString() {
    return '''
--- RateLimiterStats: ---
-------------------------
    tokens stored:       $tokens
    last refill:         $lastRefill
    now:                 $now
    elapsed ms:          ${now.difference(lastRefill).inMilliseconds}
    refill rate/ms:      $refillRatePerMs
    refilled tokens:     $refilledTokens
    capped token count:  $cappedTokenCount
    max tokens:          $maxTokens
    refill duration:     ${refillDuration.inMilliseconds} ms
''';
  }
}
