import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String phone,
    String? name,
    String? email,
    String? profilePhoto,
    @Default(5.0) double rating,
    @Default(0) double walletBalance,
    @Default(0) int totalRides,
    String? referralCode,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
