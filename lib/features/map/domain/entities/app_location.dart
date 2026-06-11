import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_location.freezed.dart';
part 'app_location.g.dart';

@freezed
abstract class AppLocation with _$AppLocation {
  const factory AppLocation({
    required double latitude,
    required double longitude,
    String? formattedAddress,
    String? shortAddress,
    String? placeId,
    @Default('recent') String type,
  }) = _AppLocation;

  factory AppLocation.fromJson(Map<String, dynamic> json) => _$AppLocationFromJson(json);
}
