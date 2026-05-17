import '../models/stat_group_model.dart';

abstract class StatisticsRepository {
  Future<List<StatGroupModel>> getReportsByStatus();
  Future<List<StatGroupModel>> getReportsByReason();
  Future<List<StatGroupModel>> getUsersByStatus();
  Future<List<StatGroupModel>> getRoomsByType();
  Future<List<StatGroupModel>> getRevenueByMonth();
}
