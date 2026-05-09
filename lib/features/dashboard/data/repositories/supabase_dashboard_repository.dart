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
    final usersRes = await _client
        .from('profiles')
        .select()
        .count(CountOption.exact);
    final totalUsers = usersRes.count;

    // 2. Active Now
    final activeRes = await _client
        .from('profiles')
        .select()
        .eq('is_online', true)
        .count(CountOption.exact);
    final activeNow = activeRes.count;

    // 3. Total Messages
    final messagesRes = await _client
        .from('messages')
        .select()
        .count(CountOption.exact);
    final totalMessages = messagesRes.count;

    // 4. Trends (Simple 24h comparison)
    // New users last 24h
    final newUsersRes = await _client
        .from('profiles')
        .select()
        .gte('updated_at', dayAgo.toIso8601String())
        .count(CountOption.exact);
    final newUsers = newUsersRes.count;

    // Users 24h-48h ago
    final prevNewUsersRes = await _client
        .from('profiles')
        .select()
        .gte('updated_at', twoDaysAgo.toIso8601String())
        .lt('updated_at', dayAgo.toIso8601String())
        .count(CountOption.exact);
    final prevNewUsers = prevNewUsersRes.count;

    final userTrend = _calculateTrend(newUsers, prevNewUsers);

    // New messages last 24h
    final newMessagesRes = await _client
        .from('messages')
        .select()
        .gte('created_at', dayAgo.toIso8601String())
        .count(CountOption.exact);
    final newMessages = newMessagesRes.count;

    final messageTrend = _calculateTrend(newMessages, 0); // Comparing to 0 for now as an example

    // 5. Activity Chart (Messages in last 7 days)
    final activityData = <double>[];
    for (int i = 6; i >= 0; i--) {
      final start = now.subtract(Duration(days: i + 1));
      final end = now.subtract(Duration(days: i));
      final res = await _client
          .from('messages')
          .select()
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.toIso8601String())
          .count(CountOption.exact);
      activityData.add(res.count.toDouble());
    }

    return DashboardStats(
      totalUsers: totalUsers,
      activeNow: activeNow,
      totalMessages: totalMessages,
      revenue: 0.0, // Mocked as no revenue table found
      userTrend: userTrend,
      activeTrend: '+0%', // Mocked
      messageTrend: messageTrend,
      revenueTrend: '+0%', // Mocked
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

  String _calculateTrend(int current, int previous) {
    if (previous == 0) return current > 0 ? '+$current' : '0%';
    final diff = ((current - previous) / previous * 100).toStringAsFixed(0);
    return current >= previous ? '+$diff%' : '$diff%';
  }
}
