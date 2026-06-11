// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  phone: json['phone'] as String,
  name: json['name'] as String?,
  email: json['email'] as String?,
  profilePhoto: json['profilePhoto'] as String?,
  rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
  walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0,
  totalRides: (json['totalRides'] as num?)?.toInt() ?? 0,
  referralCode: json['referralCode'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'name': instance.name,
  'email': instance.email,
  'profilePhoto': instance.profilePhoto,
  'rating': instance.rating,
  'walletBalance': instance.walletBalance,
  'totalRides': instance.totalRides,
  'referralCode': instance.referralCode,
  'createdAt': instance.createdAt.toIso8601String(),
};
