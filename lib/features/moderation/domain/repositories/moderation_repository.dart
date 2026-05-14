import '../models/report_model.dart';

abstract class ModerationRepository {
  Future<List<ReportModel>> getReports();
  Future<void> updateStatus(String reportId, String status);
  Future<void> blockUser(String userId, {Duration? duration, String? reason});
  Future<void> deleteMessage(String messageId);
}
