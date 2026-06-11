// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppLocation _$AppLocationFromJson(Map<String, dynamic> json) => _AppLocation(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  formattedAddress: json['formattedAddress'] as String?,
  shortAddress: json['shortAddress'] as String?,
  placeId: json['placeId'] as String?,
  type: json['type'] as String? ?? 'recent',
);

Map<String, dynamic> _$AppLocationToJson(_AppLocation instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'formattedAddress': instance.formattedAddress,
      'shortAddress': instance.shortAddress,
      'placeId': instance.placeId,
      'type': instance.type,
    };
