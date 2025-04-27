import 'package:prf/prf.dart';

class PrfyJson<T> extends BasePrfObject<T> {
  final PrfAdapter<T> _adapter;

  @override
  PrfAdapter<T> get adapter => _adapter;

  PrfyJson(
    super.key, {
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T object) toJson,
    super.defaultValue,
  }) : _adapter = JsonAdapter(fromJson: fromJson, toJson: toJson);
}
