// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileModel {

 String get id; String get username;@JsonKey(name: 'nickname') String? get nickname;@JsonKey(name: 'avatar_url') String? get avatarUrl;@JsonKey(name: 'is_admin') bool get isAdmin;@JsonKey(name: 'is_online') bool? get isOnline;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of ProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileModelCopyWith<ProfileModel> get copyWith => _$ProfileModelCopyWithImpl<ProfileModel>(this as ProfileModel, _$identity);

  /// Serializes this ProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,nickname,avatarUrl,isAdmin,isOnline,createdAt,updatedAt);

@override
String toString() {
  return 'ProfileModel(id: $id, username: $username, nickname: $nickname, avatarUrl: $avatarUrl, isAdmin: $isAdmin, isOnline: $isOnline, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProfileModelCopyWith<$Res>  {
  factory $ProfileModelCopyWith(ProfileModel value, $Res Function(ProfileModel) _then) = _$ProfileModelCopyWithImpl;
@useResult
$Res call({
 String id, String username,@JsonKey(name: 'nickname') String? nickname,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'is_admin') bool isAdmin,@JsonKey(name: 'is_online') bool? isOnline,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$ProfileModelCopyWithImpl<$Res>
    implements $ProfileModelCopyWith<$Res> {
  _$ProfileModelCopyWithImpl(this._self, this._then);

  final ProfileModel _self;
  final $Res Function(ProfileModel) _then;

/// Create a copy of ProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? nickname = freezed,Object? avatarUrl = freezed,Object? isAdmin = null,Object? isOnline = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,isOnline: freezed == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileModel].
extension ProfileModelPatterns on ProfileModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _ProfileModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username, @JsonKey(name: 'nickname')  String? nickname, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_admin')  bool isAdmin, @JsonKey(name: 'is_online')  bool? isOnline, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileModel() when $default != null:
return $default(_that.id,_that.username,_that.nickname,_that.avatarUrl,_that.isAdmin,_that.isOnline,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username, @JsonKey(name: 'nickname')  String? nickname, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_admin')  bool isAdmin, @JsonKey(name: 'is_online')  bool? isOnline, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProfileModel():
return $default(_that.id,_that.username,_that.nickname,_that.avatarUrl,_that.isAdmin,_that.isOnline,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username, @JsonKey(name: 'nickname')  String? nickname, @JsonKey(name: 'avatar_url')  String? avatarUrl, @JsonKey(name: 'is_admin')  bool isAdmin, @JsonKey(name: 'is_online')  bool? isOnline, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProfileModel() when $default != null:
return $default(_that.id,_that.username,_that.nickname,_that.avatarUrl,_that.isAdmin,_that.isOnline,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileModel implements ProfileModel {
  const _ProfileModel({required this.id, required this.username, @JsonKey(name: 'nickname') this.nickname, @JsonKey(name: 'avatar_url') this.avatarUrl, @JsonKey(name: 'is_admin') this.isAdmin = false, @JsonKey(name: 'is_online') this.isOnline, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _ProfileModel.fromJson(Map<String, dynamic> json) => _$ProfileModelFromJson(json);

@override final  String id;
@override final  String username;
@override@JsonKey(name: 'nickname') final  String? nickname;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override@JsonKey(name: 'is_admin') final  bool isAdmin;
@override@JsonKey(name: 'is_online') final  bool? isOnline;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of ProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileModelCopyWith<_ProfileModel> get copyWith => __$ProfileModelCopyWithImpl<_ProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,nickname,avatarUrl,isAdmin,isOnline,createdAt,updatedAt);

@override
String toString() {
  return 'ProfileModel(id: $id, username: $username, nickname: $nickname, avatarUrl: $avatarUrl, isAdmin: $isAdmin, isOnline: $isOnline, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProfileModelCopyWith<$Res> implements $ProfileModelCopyWith<$Res> {
  factory _$ProfileModelCopyWith(_ProfileModel value, $Res Function(_ProfileModel) _then) = __$ProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String username,@JsonKey(name: 'nickname') String? nickname,@JsonKey(name: 'avatar_url') String? avatarUrl,@JsonKey(name: 'is_admin') bool isAdmin,@JsonKey(name: 'is_online') bool? isOnline,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$ProfileModelCopyWithImpl<$Res>
    implements _$ProfileModelCopyWith<$Res> {
  __$ProfileModelCopyWithImpl(this._self, this._then);

  final _ProfileModel _self;
  final $Res Function(_ProfileModel) _then;

/// Create a copy of ProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? nickname = freezed,Object? avatarUrl = freezed,Object? isAdmin = null,Object? isOnline = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ProfileModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,isOnline: freezed == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
