import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../map/domain/entities/app_location.dart';
import 'ride_option.dart';

part 'ride.freezed.dart';
part 'ride.g.dart';

@freezed
abstract class Driver with _$Driver {
  const factory Driver({
    required String id,
    required String name,
    required double rating,
    required String phone,
    required String vehicleNumber,
    required String vehicleModel,
    required String image,
    required double latitude,
    required double longitude,
    required double heading,
  }) = _Driver;

  factory Driver.fromJson(Map<String, dynamic> json) => _$DriverFromJson(json);
}

@freezed
abstract class Ride with _$Ride {
  const factory Ride({
    required String id,
    required String userId,
    required String status, // searching, accepted, arrived, trip_started, completed, cancelled
    required AppLocation pickup,
    required AppLocation destination,
    required double distance,
    required int duration,
    required String rideType,
    required FareEstimate fareEstimate,
    required String paymentMethod,
    String? scheduledAt,
    Driver? driver,
    int? eta, // driver ETA
    String? otp, // Ride OTP
    required String createdAt,
    required String updatedAt,
  }) = _Ride;

  factory Ride.fromJson(Map<String, dynamic> json) => _$RideFromJson(json);
}
