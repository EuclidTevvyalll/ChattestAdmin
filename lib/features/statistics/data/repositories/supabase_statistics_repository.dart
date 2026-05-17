import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/stat_group_model.dart';
import '../../domain/repositories/statistics_repository.dart';

class SupabaseStatisticsRepository implements StatisticsRepository {
  final SupabaseClient _client;

  SupabaseStatisticsRepository(this._client);

  @override
  Future<List<StatGroupModel>> getReportsByStatus() async {
    final statuses = ['pending', 'resolved', 'dismissed'];
    final results = <StatGroupModel>[];

    for (final status in statuses) {
      final count = await _client
          .from('reports')
          .count(CountOption.exact)
          .eq('status', status);
      results.add(
        StatGroupModel(label: _formatStatus(status), count: count.toDouble()),
      );
    }
    return results;
  }

  @override
  Future<List<StatGroupModel>> getReportsByReason() async {
    final reasons = [
      'spam',
      'harassment',
      'violence',
      'inappropriate',
      'other',
    ];
    final results = <StatGroupModel>[];

    for (final reason in reasons) {
      final count = await _client
          .from('reports')
          .count(CountOption.exact)
          .eq('reason', reason);
      results.add(
        StatGroupModel(label: _formatReason(reason), count: count.toDouble()),
      );
    }
    return results;
  }

  @override
  Future<List<StatGroupModel>> getUsersByStatus() async {
    final onlineRes = await _client
        .from('profiles')
        .count(CountOption.exact)
        .eq('is_online', true);

    final offlineRes = await _client
        .from('profiles')
        .count(CountOption.exact)
        .eq('is_online', false);

    final bannedRes = await _client
        .from('profiles')
        .count(CountOption.exact)
        .eq('is_banned', true);

    return [
      StatGroupModel(label: 'В сети', count: onlineRes.toDouble()),
      StatGroupModel(label: 'Не в сети', count: offlineRes.toDouble()),
      StatGroupModel(label: 'Заблокирован', count: bannedRes.toDouble()),
    ];
  }

  @override
  Future<List<StatGroupModel>> getRoomsByType() async {
    final types = ['direct', 'group', 'channel'];
    final results = <StatGroupModel>[];

    for (final type in types) {
      final count = await _client
          .from('rooms')
          .count(CountOption.exact)
          .eq('type', type);
      results.add(
        StatGroupModel(label: _formatRoomType(type), count: count.toDouble()),
      );
    }
    return results;
  }

  @override
  Future<List<StatGroupModel>> getRevenueByMonth() async {
    try {
      final response = await _client
          .from('subscriptions')
          .select('amount, created_at');

      final Map<String, double> revenueByMonth = {};

      for (final item in response as List) {
        final createdAt = DateTime.parse(item['created_at'] as String);
        final monthKey =
            '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
        final amount = (item['amount'] as num).toDouble();

        revenueByMonth[monthKey] = (revenueByMonth[monthKey] ?? 0) + amount;
      }

      final sortedKeys = revenueByMonth.keys.toList()..sort();

      return sortedKeys.map((key) {
        final parts = key.split('-');
        final year = parts[0];
        final month = _getMonthName(int.parse(parts[1]));
        return StatGroupModel(
          label: '$month $year',
          count: revenueByMonth[key]!,
        );
      }).toList();
    } catch (e) {
      debugPrint('Supabase: Error fetching revenue: $e');
      return [];
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Янв',
      'Фев',
      'Мар',
      'Апр',
      'Май',
      'Июн',
      'Июл',
      'Авг',
      'Сен',
      'Окт',
      'Ноя',
      'Дек',
    ];
    return months[month - 1];
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

  String _formatReason(String s) {
    switch (s) {
      case 'spam':
        return 'Спам';
      case 'harassment':
        return 'Оскорбление';
      case 'violence':
        return 'Насилие';
      case 'inappropriate':
        return 'Неприемлемый контент';
      case 'other':
        return 'Другое';
      default:
        return _capitalize(s);
    }
  }

  String _formatStatus(String s) {
    switch (s) {
      case 'pending':
        return 'Ожидает';
      case 'resolved':
        return 'Решено';
      case 'dismissed':
        return 'Отклонено';
      default:
        return _capitalize(s);
    }
  }

  String _formatRoomType(String s) {
    switch (s) {
      case 'direct':
        return 'Личные сообщения';
      case 'group':
        return 'Группа';
      case 'channel':
        return 'Канал';
      default:
        return _capitalize(s);
    }
  }
}
