// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FareEstimate {

 double get baseFare; double get distanceFare; double get timeFare; double get surgeMultiplier; double get total; String get currency; double get distance; int get duration;
/// Create a copy of FareEstimate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FareEstimateCopyWith<FareEstimate> get copyWith => _$FareEstimateCopyWithImpl<FareEstimate>(this as FareEstimate, _$identity);

  /// Serializes this FareEstimate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FareEstimate&&(identical(other.baseFare, baseFare) || other.baseFare == baseFare)&&(identical(other.distanceFare, distanceFare) || other.distanceFare == distanceFare)&&(identical(other.timeFare, timeFare) || other.timeFare == timeFare)&&(identical(other.surgeMultiplier, surgeMultiplier) || other.surgeMultiplier == surgeMultiplier)&&(identical(other.total, total) || other.total == total)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,baseFare,distanceFare,timeFare,surgeMultiplier,total,currency,distance,duration);

@override
String toString() {
  return 'FareEstimate(baseFare: $baseFare, distanceFare: $distanceFare, timeFare: $timeFare, surgeMultiplier: $surgeMultiplier, total: $total, currency: $currency, distance: $distance, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $FareEstimateCopyWith<$Res>  {
  factory $FareEstimateCopyWith(FareEstimate value, $Res Function(FareEstimate) _then) = _$FareEstimateCopyWithImpl;
@useResult
$Res call({
 double baseFare, double distanceFare, double timeFare, double surgeMultiplier, double total, String currency, double distance, int duration
});




}
/// @nodoc
class _$FareEstimateCopyWithImpl<$Res>
    implements $FareEstimateCopyWith<$Res> {
  _$FareEstimateCopyWithImpl(this._self, this._then);

  final FareEstimate _self;
  final $Res Function(FareEstimate) _then;

/// Create a copy of FareEstimate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? baseFare = null,Object? distanceFare = null,Object? timeFare = null,Object? surgeMultiplier = null,Object? total = null,Object? currency = null,Object? distance = null,Object? duration = null,}) {
  return _then(_self.copyWith(
baseFare: null == baseFare ? _self.baseFare : baseFare // ignore: cast_nullable_to_non_nullable
as double,distanceFare: null == distanceFare ? _self.distanceFare : distanceFare // ignore: cast_nullable_to_non_nullable
as double,timeFare: null == timeFare ? _self.timeFare : timeFare // ignore: cast_nullable_to_non_nullable
as double,surgeMultiplier: null == surgeMultiplier ? _self.surgeMultiplier : surgeMultiplier // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FareEstimate].
extension FareEstimatePatterns on FareEstimate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FareEstimate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FareEstimate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FareEstimate value)  $default,){
final _that = this;
switch (_that) {
case _FareEstimate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FareEstimate value)?  $default,){
final _that = this;
switch (_that) {
case _FareEstimate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double baseFare,  double distanceFare,  double timeFare,  double surgeMultiplier,  double total,  String currency,  double distance,  int duration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FareEstimate() when $default != null:
return $default(_that.baseFare,_that.distanceFare,_that.timeFare,_that.surgeMultiplier,_that.total,_that.currency,_that.distance,_that.duration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double baseFare,  double distanceFare,  double timeFare,  double surgeMultiplier,  double total,  String currency,  double distance,  int duration)  $default,) {final _that = this;
switch (_that) {
case _FareEstimate():
return $default(_that.baseFare,_that.distanceFare,_that.timeFare,_that.surgeMultiplier,_that.total,_that.currency,_that.distance,_that.duration);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double baseFare,  double distanceFare,  double timeFare,  double surgeMultiplier,  double total,  String currency,  double distance,  int duration)?  $default,) {final _that = this;
switch (_that) {
case _FareEstimate() when $default != null:
return $default(_that.baseFare,_that.distanceFare,_that.timeFare,_that.surgeMultiplier,_that.total,_that.currency,_that.distance,_that.duration);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FareEstimate implements FareEstimate {
  const _FareEstimate({required this.baseFare, required this.distanceFare, required this.timeFare, required this.surgeMultiplier, required this.total, required this.currency, required this.distance, required this.duration});
  factory _FareEstimate.fromJson(Map<String, dynamic> json) => _$FareEstimateFromJson(json);

@override final  double baseFare;
@override final  double distanceFare;
@override final  double timeFare;
@override final  double surgeMultiplier;
@override final  double total;
@override final  String currency;
@override final  double distance;
@override final  int duration;

/// Create a copy of FareEstimate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FareEstimateCopyWith<_FareEstimate> get copyWith => __$FareEstimateCopyWithImpl<_FareEstimate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FareEstimateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FareEstimate&&(identical(other.baseFare, baseFare) || other.baseFare == baseFare)&&(identical(other.distanceFare, distanceFare) || other.distanceFare == distanceFare)&&(identical(other.timeFare, timeFare) || other.timeFare == timeFare)&&(identical(other.surgeMultiplier, surgeMultiplier) || other.surgeMultiplier == surgeMultiplier)&&(identical(other.total, total) || other.total == total)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.duration, duration) || other.duration == duration));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,baseFare,distanceFare,timeFare,surgeMultiplier,total,currency,distance,duration);

@override
String toString() {
  return 'FareEstimate(baseFare: $baseFare, distanceFare: $distanceFare, timeFare: $timeFare, surgeMultiplier: $surgeMultiplier, total: $total, currency: $currency, distance: $distance, duration: $duration)';
}


}

/// @nodoc
abstract mixin class _$FareEstimateCopyWith<$Res> implements $FareEstimateCopyWith<$Res> {
  factory _$FareEstimateCopyWith(_FareEstimate value, $Res Function(_FareEstimate) _then) = __$FareEstimateCopyWithImpl;
@override @useResult
$Res call({
 double baseFare, double distanceFare, double timeFare, double surgeMultiplier, double total, String currency, double distance, int duration
});




}
/// @nodoc
class __$FareEstimateCopyWithImpl<$Res>
    implements _$FareEstimateCopyWith<$Res> {
  __$FareEstimateCopyWithImpl(this._self, this._then);

  final _FareEstimate _self;
  final $Res Function(_FareEstimate) _then;

/// Create a copy of FareEstimate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? baseFare = null,Object? distanceFare = null,Object? timeFare = null,Object? surgeMultiplier = null,Object? total = null,Object? currency = null,Object? distance = null,Object? duration = null,}) {
  return _then(_FareEstimate(
baseFare: null == baseFare ? _self.baseFare : baseFare // ignore: cast_nullable_to_non_nullable
as double,distanceFare: null == distanceFare ? _self.distanceFare : distanceFare // ignore: cast_nullable_to_non_nullable
as double,timeFare: null == timeFare ? _self.timeFare : timeFare // ignore: cast_nullable_to_non_nullable
as double,surgeMultiplier: null == surgeMultiplier ? _self.surgeMultiplier : surgeMultiplier // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,distance: null == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RideOption {

 String get type; String get name; String get description; String get icon; int get seats; bool get available; int get eta; FareEstimate get fareEstimate;
/// Create a copy of RideOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideOptionCopyWith<RideOption> get copyWith => _$RideOptionCopyWithImpl<RideOption>(this as RideOption, _$identity);

  /// Serializes this RideOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideOption&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.seats, seats) || other.seats == seats)&&(identical(other.available, available) || other.available == available)&&(identical(other.eta, eta) || other.eta == eta)&&(identical(other.fareEstimate, fareEstimate) || other.fareEstimate == fareEstimate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,name,description,icon,seats,available,eta,fareEstimate);

@override
String toString() {
  return 'RideOption(type: $type, name: $name, description: $description, icon: $icon, seats: $seats, available: $available, eta: $eta, fareEstimate: $fareEstimate)';
}


}

/// @nodoc
abstract mixin class $RideOptionCopyWith<$Res>  {
  factory $RideOptionCopyWith(RideOption value, $Res Function(RideOption) _then) = _$RideOptionCopyWithImpl;
@useResult
$Res call({
 String type, String name, String description, String icon, int seats, bool available, int eta, FareEstimate fareEstimate
});


$FareEstimateCopyWith<$Res> get fareEstimate;

}
/// @nodoc
class _$RideOptionCopyWithImpl<$Res>
    implements $RideOptionCopyWith<$Res> {
  _$RideOptionCopyWithImpl(this._self, this._then);

  final RideOption _self;
  final $Res Function(RideOption) _then;

/// Create a copy of RideOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? name = null,Object? description = null,Object? icon = null,Object? seats = null,Object? available = null,Object? eta = null,Object? fareEstimate = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,seats: null == seats ? _self.seats : seats // ignore: cast_nullable_to_non_nullable
as int,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,eta: null == eta ? _self.eta : eta // ignore: cast_nullable_to_non_nullable
as int,fareEstimate: null == fareEstimate ? _self.fareEstimate : fareEstimate // ignore: cast_nullable_to_non_nullable
as FareEstimate,
  ));
}
/// Create a copy of RideOption
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FareEstimateCopyWith<$Res> get fareEstimate {
  
  return $FareEstimateCopyWith<$Res>(_self.fareEstimate, (value) {
    return _then(_self.copyWith(fareEstimate: value));
  });
}
}


/// Adds pattern-matching-related methods to [RideOption].
extension RideOptionPatterns on RideOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideOption value)  $default,){
final _that = this;
switch (_that) {
case _RideOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideOption value)?  $default,){
final _that = this;
switch (_that) {
case _RideOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String name,  String description,  String icon,  int seats,  bool available,  int eta,  FareEstimate fareEstimate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideOption() when $default != null:
return $default(_that.type,_that.name,_that.description,_that.icon,_that.seats,_that.available,_that.eta,_that.fareEstimate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String name,  String description,  String icon,  int seats,  bool available,  int eta,  FareEstimate fareEstimate)  $default,) {final _that = this;
switch (_that) {
case _RideOption():
return $default(_that.type,_that.name,_that.description,_that.icon,_that.seats,_that.available,_that.eta,_that.fareEstimate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String name,  String description,  String icon,  int seats,  bool available,  int eta,  FareEstimate fareEstimate)?  $default,) {final _that = this;
switch (_that) {
case _RideOption() when $default != null:
return $default(_that.type,_that.name,_that.description,_that.icon,_that.seats,_that.available,_that.eta,_that.fareEstimate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideOption implements RideOption {
  const _RideOption({required this.type, required this.name, required this.description, required this.icon, required this.seats, required this.available, required this.eta, required this.fareEstimate});
  factory _RideOption.fromJson(Map<String, dynamic> json) => _$RideOptionFromJson(json);

@override final  String type;
@override final  String name;
@override final  String description;
@override final  String icon;
@override final  int seats;
@override final  bool available;
@override final  int eta;
@override final  FareEstimate fareEstimate;

/// Create a copy of RideOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideOptionCopyWith<_RideOption> get copyWith => __$RideOptionCopyWithImpl<_RideOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideOption&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.seats, seats) || other.seats == seats)&&(identical(other.available, available) || other.available == available)&&(identical(other.eta, eta) || other.eta == eta)&&(identical(other.fareEstimate, fareEstimate) || other.fareEstimate == fareEstimate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,name,description,icon,seats,available,eta,fareEstimate);

@override
String toString() {
  return 'RideOption(type: $type, name: $name, description: $description, icon: $icon, seats: $seats, available: $available, eta: $eta, fareEstimate: $fareEstimate)';
}


}

/// @nodoc
abstract mixin class _$RideOptionCopyWith<$Res> implements $RideOptionCopyWith<$Res> {
  factory _$RideOptionCopyWith(_RideOption value, $Res Function(_RideOption) _then) = __$RideOptionCopyWithImpl;
@override @useResult
$Res call({
 String type, String name, String description, String icon, int seats, bool available, int eta, FareEstimate fareEstimate
});


@override $FareEstimateCopyWith<$Res> get fareEstimate;

}
/// @nodoc
class __$RideOptionCopyWithImpl<$Res>
    implements _$RideOptionCopyWith<$Res> {
  __$RideOptionCopyWithImpl(this._self, this._then);

  final _RideOption _self;
  final $Res Function(_RideOption) _then;

/// Create a copy of RideOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? name = null,Object? description = null,Object? icon = null,Object? seats = null,Object? available = null,Object? eta = null,Object? fareEstimate = null,}) {
  return _then(_RideOption(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,seats: null == seats ? _self.seats : seats // ignore: cast_nullable_to_non_nullable
as int,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,eta: null == eta ? _self.eta : eta // ignore: cast_nullable_to_non_nullable
as int,fareEstimate: null == fareEstimate ? _self.fareEstimate : fareEstimate // ignore: cast_nullable_to_non_nullable
as FareEstimate,
  ));
}

/// Create a copy of RideOption
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FareEstimateCopyWith<$Res> get fareEstimate {
  
  return $FareEstimateCopyWith<$Res>(_self.fareEstimate, (value) {
    return _then(_self.copyWith(fareEstimate: value));
  });
}
}

// dart format on
