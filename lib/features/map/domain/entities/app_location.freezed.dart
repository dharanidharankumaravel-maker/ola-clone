// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppLocation {

 double get latitude; double get longitude; String? get formattedAddress; String? get shortAddress; String? get placeId; String get type;
/// Create a copy of AppLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppLocationCopyWith<AppLocation> get copyWith => _$AppLocationCopyWithImpl<AppLocation>(this as AppLocation, _$identity);

  /// Serializes this AppLocation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppLocation&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.formattedAddress, formattedAddress) || other.formattedAddress == formattedAddress)&&(identical(other.shortAddress, shortAddress) || other.shortAddress == shortAddress)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,formattedAddress,shortAddress,placeId,type);

@override
String toString() {
  return 'AppLocation(latitude: $latitude, longitude: $longitude, formattedAddress: $formattedAddress, shortAddress: $shortAddress, placeId: $placeId, type: $type)';
}


}

/// @nodoc
abstract mixin class $AppLocationCopyWith<$Res>  {
  factory $AppLocationCopyWith(AppLocation value, $Res Function(AppLocation) _then) = _$AppLocationCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, String? formattedAddress, String? shortAddress, String? placeId, String type
});




}
/// @nodoc
class _$AppLocationCopyWithImpl<$Res>
    implements $AppLocationCopyWith<$Res> {
  _$AppLocationCopyWithImpl(this._self, this._then);

  final AppLocation _self;
  final $Res Function(AppLocation) _then;

/// Create a copy of AppLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? formattedAddress = freezed,Object? shortAddress = freezed,Object? placeId = freezed,Object? type = null,}) {
  return _then(_self.copyWith(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,formattedAddress: freezed == formattedAddress ? _self.formattedAddress : formattedAddress // ignore: cast_nullable_to_non_nullable
as String?,shortAddress: freezed == shortAddress ? _self.shortAddress : shortAddress // ignore: cast_nullable_to_non_nullable
as String?,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppLocation].
extension AppLocationPatterns on AppLocation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppLocation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppLocation value)  $default,){
final _that = this;
switch (_that) {
case _AppLocation():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppLocation value)?  $default,){
final _that = this;
switch (_that) {
case _AppLocation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude,  String? formattedAddress,  String? shortAddress,  String? placeId,  String type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppLocation() when $default != null:
return $default(_that.latitude,_that.longitude,_that.formattedAddress,_that.shortAddress,_that.placeId,_that.type);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude,  String? formattedAddress,  String? shortAddress,  String? placeId,  String type)  $default,) {final _that = this;
switch (_that) {
case _AppLocation():
return $default(_that.latitude,_that.longitude,_that.formattedAddress,_that.shortAddress,_that.placeId,_that.type);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude,  String? formattedAddress,  String? shortAddress,  String? placeId,  String type)?  $default,) {final _that = this;
switch (_that) {
case _AppLocation() when $default != null:
return $default(_that.latitude,_that.longitude,_that.formattedAddress,_that.shortAddress,_that.placeId,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppLocation implements AppLocation {
  const _AppLocation({required this.latitude, required this.longitude, this.formattedAddress, this.shortAddress, this.placeId, this.type = 'recent'});
  factory _AppLocation.fromJson(Map<String, dynamic> json) => _$AppLocationFromJson(json);

@override final  double latitude;
@override final  double longitude;
@override final  String? formattedAddress;
@override final  String? shortAddress;
@override final  String? placeId;
@override@JsonKey() final  String type;

/// Create a copy of AppLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppLocationCopyWith<_AppLocation> get copyWith => __$AppLocationCopyWithImpl<_AppLocation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppLocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppLocation&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.formattedAddress, formattedAddress) || other.formattedAddress == formattedAddress)&&(identical(other.shortAddress, shortAddress) || other.shortAddress == shortAddress)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,formattedAddress,shortAddress,placeId,type);

@override
String toString() {
  return 'AppLocation(latitude: $latitude, longitude: $longitude, formattedAddress: $formattedAddress, shortAddress: $shortAddress, placeId: $placeId, type: $type)';
}


}

/// @nodoc
abstract mixin class _$AppLocationCopyWith<$Res> implements $AppLocationCopyWith<$Res> {
  factory _$AppLocationCopyWith(_AppLocation value, $Res Function(_AppLocation) _then) = __$AppLocationCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, String? formattedAddress, String? shortAddress, String? placeId, String type
});




}
/// @nodoc
class __$AppLocationCopyWithImpl<$Res>
    implements _$AppLocationCopyWith<$Res> {
  __$AppLocationCopyWithImpl(this._self, this._then);

  final _AppLocation _self;
  final $Res Function(_AppLocation) _then;

/// Create a copy of AppLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? formattedAddress = freezed,Object? shortAddress = freezed,Object? placeId = freezed,Object? type = null,}) {
  return _then(_AppLocation(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,formattedAddress: freezed == formattedAddress ? _self.formattedAddress : formattedAddress // ignore: cast_nullable_to_non_nullable
as String?,shortAddress: freezed == shortAddress ? _self.shortAddress : shortAddress // ignore: cast_nullable_to_non_nullable
as String?,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
