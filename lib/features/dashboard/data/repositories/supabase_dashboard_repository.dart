import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/profile_model.dart';
import '../../domain/models/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';

class SupabaseDashboardRepository implements DashboardRepository {
  final SupabaseClient _client;

  SupabaseDashboardRepository(this._client);

  @override
  Future<DashboardStats> getStats() async {
    final now = DateTime.now();
    final dayAgo = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    // 1. Total Users
    final totalUsers = await _client.from('profiles').count(CountOption.exact);

    // 2. Active Now
    final activeNow = await _client
        .from('profiles')
        .count(CountOption.exact)
        .eq('is_online', true);

    // 3. Total Messages
    final totalMessages = await _client
        .from('messages')
        .count(CountOption.exact);

    // 4. Trends (Simple 24h comparison)
    // New users last 24h
    final newUsers = await _client
        .from('profiles')
        .count(CountOption.exact)
        .gte('updated_at', dayAgo.toIso8601String());

    // Users 24h-48h ago
    final prevNewUsers = await _client
        .from('profiles')
        .count(CountOption.exact)
        .gte('updated_at', twoDaysAgo.toIso8601String())
        .lt('updated_at', dayAgo.toIso8601String());

    final userTrend = _calculateTrend(newUsers, prevNewUsers);

    // New messages last 24h
    final newMessages = await _client
        .from('messages')
        .count(CountOption.exact)
        .gte('created_at', dayAgo.toIso8601String());

    final messageTrend = _calculateTrend(
      newMessages,
      0,
    ); // Comparing to 0 for now as an example

    // 5. Activity Chart (Messages in last 7 days)
    final activityData = <double>[];
    for (int i = 6; i >= 0; i--) {
      final start = now.subtract(Duration(days: i + 1));
      final end = now.subtract(Duration(days: i));
      final count = await _client
          .from('messages')
          .count(CountOption.exact)
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.toIso8601String());
      activityData.add(count.toDouble());
    }

    // 6. Revenue from subscriptions
    double totalRevenue = 0.0;
    try {
      final subscriptionData = await _client
          .from('subscriptions')
          .select('amount');
      for (final item in subscriptionData as List) {
        final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
        totalRevenue += amount;
      }
    } catch (e) {
      // Keep totalRevenue = 0.0
    }

    // Revenue trend (last 24h vs previous 24h)
    double newRevenue = 0.0;
    try {
      final newSubsData = await _client
          .from('subscriptions')
          .select('amount')
          .gte('created_at', dayAgo.toIso8601String());
      for (final item in newSubsData as List) {
        final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
        newRevenue += amount;
      }
    } catch (_) {}

    double prevNewRevenue = 0.0;
    try {
      final prevSubsData = await _client
          .from('subscriptions')
          .select('amount')
          .gte('created_at', twoDaysAgo.toIso8601String())
          .lt('created_at', dayAgo.toIso8601String());
      for (final item in prevSubsData as List) {
        final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
        prevNewRevenue += amount;
      }
    } catch (_) {}

    final revenueTrend = _calculateTrend(newRevenue, prevNewRevenue);

    return DashboardStats(
      totalUsers: totalUsers,
      activeNow: activeNow,
      totalMessages: totalMessages,
      revenue: totalRevenue,
      userTrend: userTrend,
      activeTrend: '+0%', // Mocked
      messageTrend: messageTrend,
      revenueTrend: revenueTrend,
      activityData: activityData,
    );
  }

  @override
  Future<List<ProfileModel>> getRecentUsers({int limit = 5}) async {
    final data = await _client
        .from('profiles')
        .select('*')
        .order('updated_at', ascending: false)
        .limit(limit);

    return (data as List).map((json) => ProfileModel.fromJson(json)).toList();
  }

  String _calculateTrend(num current, num previous) {
    if (previous == 0) return current > 0 ? '+${current.toInt()}' : '0%';
    final diff = ((current - previous) / previous * 100).toStringAsFixed(0);
    return current >= previous ? '+$diff%' : '$diff%';
  }
}
