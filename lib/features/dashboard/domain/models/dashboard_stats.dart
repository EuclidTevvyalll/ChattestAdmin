import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats.freezed.dart';
part 'dashboard_stats.g.dart';

@freezed
abstract class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    required int totalUsers,
    required int activeNow,
    required int totalMessages,
    required double revenue,
    required String userTrend,
    required String activeTrend,
    required String messageTrend,
    required String revenueTrend,
    @Default([]) List<double> activityData,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
}
