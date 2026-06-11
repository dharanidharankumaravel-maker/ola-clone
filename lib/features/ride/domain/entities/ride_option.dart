import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride_option.freezed.dart';
part 'ride_option.g.dart';

@freezed
abstract class FareEstimate with _$FareEstimate {
  const factory FareEstimate({
    required double baseFare,
    required double distanceFare,
    required double timeFare,
    required double surgeMultiplier,
    required double total,
    required String currency,
    required double distance,
    required int duration,
  }) = _FareEstimate;

  factory FareEstimate.fromJson(Map<String, dynamic> json) => _$FareEstimateFromJson(json);
}

@freezed
abstract class RideOption with _$RideOption {
  const factory RideOption({
    required String type,
    required String name,
    required String description,
    required String icon,
    required int seats,
    required bool available,
    required int eta,
    required FareEstimate fareEstimate,
  }) = _RideOption;

  factory RideOption.fromJson(Map<String, dynamic> json) => _$RideOptionFromJson(json);
}
