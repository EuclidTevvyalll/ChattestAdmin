// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
    _DashboardStats(
      totalUsers: (json['totalUsers'] as num).toInt(),
      activeNow: (json['activeNow'] as num).toInt(),
      totalMessages: (json['totalMessages'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
      userTrend: json['userTrend'] as String,
      activeTrend: json['activeTrend'] as String,
      messageTrend: json['messageTrend'] as String,
      revenueTrend: json['revenueTrend'] as String,
      activityData:
          (json['activityData'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DashboardStatsToJson(_DashboardStats instance) =>
    <String, dynamic>{
      'totalUsers': instance.totalUsers,
      'activeNow': instance.activeNow,
      'totalMessages': instance.totalMessages,
      'revenue': instance.revenue,
      'userTrend': instance.userTrend,
      'activeTrend': instance.activeTrend,
      'messageTrend': instance.messageTrend,
      'revenueTrend': instance.revenueTrend,
      'activityData': instance.activityData,
    };
