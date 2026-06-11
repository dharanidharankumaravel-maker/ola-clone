// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FareEstimate _$FareEstimateFromJson(Map<String, dynamic> json) =>
    _FareEstimate(
      baseFare: (json['baseFare'] as num).toDouble(),
      distanceFare: (json['distanceFare'] as num).toDouble(),
      timeFare: (json['timeFare'] as num).toDouble(),
      surgeMultiplier: (json['surgeMultiplier'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      currency: json['currency'] as String,
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toInt(),
    );

Map<String, dynamic> _$FareEstimateToJson(_FareEstimate instance) =>
    <String, dynamic>{
      'baseFare': instance.baseFare,
      'distanceFare': instance.distanceFare,
      'timeFare': instance.timeFare,
      'surgeMultiplier': instance.surgeMultiplier,
      'total': instance.total,
      'currency': instance.currency,
      'distance': instance.distance,
      'duration': instance.duration,
    };

_RideOption _$RideOptionFromJson(Map<String, dynamic> json) => _RideOption(
  type: json['type'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  icon: json['icon'] as String,
  seats: (json['seats'] as num).toInt(),
  available: json['available'] as bool,
  eta: (json['eta'] as num).toInt(),
  fareEstimate: FareEstimate.fromJson(
    json['fareEstimate'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$RideOptionToJson(_RideOption instance) =>
    <String, dynamic>{
      'type': instance.type,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'seats': instance.seats,
      'available': instance.available,
      'eta': instance.eta,
      'fareEstimate': instance.fareEstimate,
    };
