import '../models/stat_group_model.dart';

abstract class StatisticsRepository {
  Future<List<StatGroupModel>> getReportsByStatus();
  Future<List<StatGroupModel>> getReportsByReason({DateTime? startDate, DateTime? endDate});
  Future<List<StatGroupModel>> getUsersByStatus();
  Future<List<StatGroupModel>> getRoomsByType({DateTime? startDate, DateTime? endDate});
  Future<List<StatGroupModel>> getRevenueByMonth({DateTime? startDate, DateTime? endDate});
}
