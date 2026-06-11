// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Driver _$DriverFromJson(Map<String, dynamic> json) => _Driver(
  id: json['id'] as String,
  name: json['name'] as String,
  rating: (json['rating'] as num).toDouble(),
  phone: json['phone'] as String,
  vehicleNumber: json['vehicleNumber'] as String,
  vehicleModel: json['vehicleModel'] as String,
  image: json['image'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  heading: (json['heading'] as num).toDouble(),
);

Map<String, dynamic> _$DriverToJson(_Driver instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'rating': instance.rating,
  'phone': instance.phone,
  'vehicleNumber': instance.vehicleNumber,
  'vehicleModel': instance.vehicleModel,
  'image': instance.image,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'heading': instance.heading,
};

_Ride _$RideFromJson(Map<String, dynamic> json) => _Ride(
  id: json['id'] as String,
  userId: json['userId'] as String,
  status: json['status'] as String,
  pickup: AppLocation.fromJson(json['pickup'] as Map<String, dynamic>),
  destination: AppLocation.fromJson(
    json['destination'] as Map<String, dynamic>,
  ),
  distance: (json['distance'] as num).toDouble(),
  duration: (json['duration'] as num).toInt(),
  rideType: json['rideType'] as String,
  fareEstimate: FareEstimate.fromJson(
    json['fareEstimate'] as Map<String, dynamic>,
  ),
  paymentMethod: json['paymentMethod'] as String,
  scheduledAt: json['scheduledAt'] as String?,
  driver: json['driver'] == null
      ? null
      : Driver.fromJson(json['driver'] as Map<String, dynamic>),
  eta: (json['eta'] as num?)?.toInt(),
  otp: json['otp'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$RideToJson(_Ride instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'status': instance.status,
  'pickup': instance.pickup,
  'destination': instance.destination,
  'distance': instance.distance,
  'duration': instance.duration,
  'rideType': instance.rideType,
  'fareEstimate': instance.fareEstimate,
  'paymentMethod': instance.paymentMethod,
  'scheduledAt': instance.scheduledAt,
  'driver': instance.driver,
  'eta': instance.eta,
  'otp': instance.otp,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
