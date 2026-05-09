import '../../../../core/models/profile_model.dart';
import '../models/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<DashboardStats> getStats();
  Future<List<ProfileModel>> getRecentUsers({int limit = 5});
}
