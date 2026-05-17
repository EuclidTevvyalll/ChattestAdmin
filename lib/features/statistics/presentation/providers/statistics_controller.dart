import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/stat_group_model.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../data/repositories/supabase_statistics_repository.dart';

enum StatGroupType {
  reportsByStatus('Жалобы по статусу'),
  reportsByReason('Жалобы по причине'),
  usersByStatus('Пользователи по статусу'),
  roomsByType('Чаты по типу'),
  revenueByMonth('Выручка по месяцам');

  final String label;
  const StatGroupType(this.label);
}

enum StatSortType {
  countAsc('По количеству (возр.)'),
  countDesc('По количеству (убыв.)'),
  labelAsc('По названию (А-Я)'),
  labelDesc('По названию (Я-А)');

  final String label;
  const StatSortType(this.label);
}

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return SupabaseStatisticsRepository(Supabase.instance.client);
});

class StatGroupTypeNotifier extends Notifier<StatGroupType> {
  @override
  StatGroupType build() => StatGroupType.reportsByStatus;

  void setType(StatGroupType newType) => state = newType;
}

final statGroupTypeProvider =
    NotifierProvider<StatGroupTypeNotifier, StatGroupType>(
      () => StatGroupTypeNotifier(),
    );

class StatSortTypeNotifier extends Notifier<StatSortType> {
  @override
  StatSortType build() => StatSortType.countDesc;

  void setType(StatSortType newType) => state = newType;
}

final statSortTypeProvider =
    NotifierProvider<StatSortTypeNotifier, StatSortType>(
      () => StatSortTypeNotifier(),
    );

final statisticsProvider = FutureProvider<List<StatGroupModel>>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  final groupType = ref.watch(statGroupTypeProvider);
  final sortType = ref.watch(statSortTypeProvider);

  List<StatGroupModel> data = [];

  switch (groupType) {
    case StatGroupType.reportsByStatus:
      data = await repository.getReportsByStatus();
      break;
    case StatGroupType.reportsByReason:
      data = await repository.getReportsByReason();
      break;
    case StatGroupType.usersByStatus:
      data = await repository.getUsersByStatus();
      break;
    case StatGroupType.roomsByType:
      data = await repository.getRoomsByType();
      break;
    case StatGroupType.revenueByMonth:
      data = await repository.getRevenueByMonth();
      break;
  }

  // Sorting
  switch (sortType) {
    case StatSortType.countAsc:
      data.sort((a, b) => a.count.compareTo(b.count));
      break;
    case StatSortType.countDesc:
      data.sort((a, b) => b.count.compareTo(a.count));
      break;
    case StatSortType.labelAsc:
      data.sort((a, b) => a.label.compareTo(b.label));
      break;
    case StatSortType.labelDesc:
      data.sort((a, b) => b.label.compareTo(a.label));
      break;
  }

  return data;
});
