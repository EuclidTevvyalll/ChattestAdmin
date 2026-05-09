// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardStats {

 int get totalUsers; int get activeNow; int get totalMessages; double get revenue; String get userTrend; String get activeTrend; String get messageTrend; String get revenueTrend; List<double> get activityData;
/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStatsCopyWith<DashboardStats> get copyWith => _$DashboardStatsCopyWithImpl<DashboardStats>(this as DashboardStats, _$identity);

  /// Serializes this DashboardStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardStats&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.activeNow, activeNow) || other.activeNow == activeNow)&&(identical(other.totalMessages, totalMessages) || other.totalMessages == totalMessages)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.userTrend, userTrend) || other.userTrend == userTrend)&&(identical(other.activeTrend, activeTrend) || other.activeTrend == activeTrend)&&(identical(other.messageTrend, messageTrend) || other.messageTrend == messageTrend)&&(identical(other.revenueTrend, revenueTrend) || other.revenueTrend == revenueTrend)&&const DeepCollectionEquality().equals(other.activityData, activityData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUsers,activeNow,totalMessages,revenue,userTrend,activeTrend,messageTrend,revenueTrend,const DeepCollectionEquality().hash(activityData));

@override
String toString() {
  return 'DashboardStats(totalUsers: $totalUsers, activeNow: $activeNow, totalMessages: $totalMessages, revenue: $revenue, userTrend: $userTrend, activeTrend: $activeTrend, messageTrend: $messageTrend, revenueTrend: $revenueTrend, activityData: $activityData)';
}


}

/// @nodoc
abstract mixin class $DashboardStatsCopyWith<$Res>  {
  factory $DashboardStatsCopyWith(DashboardStats value, $Res Function(DashboardStats) _then) = _$DashboardStatsCopyWithImpl;
@useResult
$Res call({
 int totalUsers, int activeNow, int totalMessages, double revenue, String userTrend, String activeTrend, String messageTrend, String revenueTrend, List<double> activityData
});




}
/// @nodoc
class _$DashboardStatsCopyWithImpl<$Res>
    implements $DashboardStatsCopyWith<$Res> {
  _$DashboardStatsCopyWithImpl(this._self, this._then);

  final DashboardStats _self;
  final $Res Function(DashboardStats) _then;

/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalUsers = null,Object? activeNow = null,Object? totalMessages = null,Object? revenue = null,Object? userTrend = null,Object? activeTrend = null,Object? messageTrend = null,Object? revenueTrend = null,Object? activityData = null,}) {
  return _then(_self.copyWith(
totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,activeNow: null == activeNow ? _self.activeNow : activeNow // ignore: cast_nullable_to_non_nullable
as int,totalMessages: null == totalMessages ? _self.totalMessages : totalMessages // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,userTrend: null == userTrend ? _self.userTrend : userTrend // ignore: cast_nullable_to_non_nullable
as String,activeTrend: null == activeTrend ? _self.activeTrend : activeTrend // ignore: cast_nullable_to_non_nullable
as String,messageTrend: null == messageTrend ? _self.messageTrend : messageTrend // ignore: cast_nullable_to_non_nullable
as String,revenueTrend: null == revenueTrend ? _self.revenueTrend : revenueTrend // ignore: cast_nullable_to_non_nullable
as String,activityData: null == activityData ? _self.activityData : activityData // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardStats].
extension DashboardStatsPatterns on DashboardStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardStats value)  $default,){
final _that = this;
switch (_that) {
case _DashboardStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardStats value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalUsers,  int activeNow,  int totalMessages,  double revenue,  String userTrend,  String activeTrend,  String messageTrend,  String revenueTrend,  List<double> activityData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
return $default(_that.totalUsers,_that.activeNow,_that.totalMessages,_that.revenue,_that.userTrend,_that.activeTrend,_that.messageTrend,_that.revenueTrend,_that.activityData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalUsers,  int activeNow,  int totalMessages,  double revenue,  String userTrend,  String activeTrend,  String messageTrend,  String revenueTrend,  List<double> activityData)  $default,) {final _that = this;
switch (_that) {
case _DashboardStats():
return $default(_that.totalUsers,_that.activeNow,_that.totalMessages,_that.revenue,_that.userTrend,_that.activeTrend,_that.messageTrend,_that.revenueTrend,_that.activityData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalUsers,  int activeNow,  int totalMessages,  double revenue,  String userTrend,  String activeTrend,  String messageTrend,  String revenueTrend,  List<double> activityData)?  $default,) {final _that = this;
switch (_that) {
case _DashboardStats() when $default != null:
return $default(_that.totalUsers,_that.activeNow,_that.totalMessages,_that.revenue,_that.userTrend,_that.activeTrend,_that.messageTrend,_that.revenueTrend,_that.activityData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardStats implements DashboardStats {
  const _DashboardStats({required this.totalUsers, required this.activeNow, required this.totalMessages, required this.revenue, required this.userTrend, required this.activeTrend, required this.messageTrend, required this.revenueTrend, final  List<double> activityData = const []}): _activityData = activityData;
  factory _DashboardStats.fromJson(Map<String, dynamic> json) => _$DashboardStatsFromJson(json);

@override final  int totalUsers;
@override final  int activeNow;
@override final  int totalMessages;
@override final  double revenue;
@override final  String userTrend;
@override final  String activeTrend;
@override final  String messageTrend;
@override final  String revenueTrend;
 final  List<double> _activityData;
@override@JsonKey() List<double> get activityData {
  if (_activityData is EqualUnmodifiableListView) return _activityData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activityData);
}


/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStatsCopyWith<_DashboardStats> get copyWith => __$DashboardStatsCopyWithImpl<_DashboardStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardStats&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.activeNow, activeNow) || other.activeNow == activeNow)&&(identical(other.totalMessages, totalMessages) || other.totalMessages == totalMessages)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.userTrend, userTrend) || other.userTrend == userTrend)&&(identical(other.activeTrend, activeTrend) || other.activeTrend == activeTrend)&&(identical(other.messageTrend, messageTrend) || other.messageTrend == messageTrend)&&(identical(other.revenueTrend, revenueTrend) || other.revenueTrend == revenueTrend)&&const DeepCollectionEquality().equals(other._activityData, _activityData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUsers,activeNow,totalMessages,revenue,userTrend,activeTrend,messageTrend,revenueTrend,const DeepCollectionEquality().hash(_activityData));

@override
String toString() {
  return 'DashboardStats(totalUsers: $totalUsers, activeNow: $activeNow, totalMessages: $totalMessages, revenue: $revenue, userTrend: $userTrend, activeTrend: $activeTrend, messageTrend: $messageTrend, revenueTrend: $revenueTrend, activityData: $activityData)';
}


}

/// @nodoc
abstract mixin class _$DashboardStatsCopyWith<$Res> implements $DashboardStatsCopyWith<$Res> {
  factory _$DashboardStatsCopyWith(_DashboardStats value, $Res Function(_DashboardStats) _then) = __$DashboardStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalUsers, int activeNow, int totalMessages, double revenue, String userTrend, String activeTrend, String messageTrend, String revenueTrend, List<double> activityData
});




}
/// @nodoc
class __$DashboardStatsCopyWithImpl<$Res>
    implements _$DashboardStatsCopyWith<$Res> {
  __$DashboardStatsCopyWithImpl(this._self, this._then);

  final _DashboardStats _self;
  final $Res Function(_DashboardStats) _then;

/// Create a copy of DashboardStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalUsers = null,Object? activeNow = null,Object? totalMessages = null,Object? revenue = null,Object? userTrend = null,Object? activeTrend = null,Object? messageTrend = null,Object? revenueTrend = null,Object? activityData = null,}) {
  return _then(_DashboardStats(
totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,activeNow: null == activeNow ? _self.activeNow : activeNow // ignore: cast_nullable_to_non_nullable
as int,totalMessages: null == totalMessages ? _self.totalMessages : totalMessages // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as double,userTrend: null == userTrend ? _self.userTrend : userTrend // ignore: cast_nullable_to_non_nullable
as String,activeTrend: null == activeTrend ? _self.activeTrend : activeTrend // ignore: cast_nullable_to_non_nullable
as String,messageTrend: null == messageTrend ? _self.messageTrend : messageTrend // ignore: cast_nullable_to_non_nullable
as String,revenueTrend: null == revenueTrend ? _self.revenueTrend : revenueTrend // ignore: cast_nullable_to_non_nullable
as String,activityData: null == activityData ? _self._activityData : activityData // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}


}

// dart format on
