import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/models/profile_model.dart';
import '../../domain/models/dashboard_stats.dart';
import 'dashboard_repository_provider.dart';

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  
  final timer = Timer(const Duration(seconds: 5), () {
    ref.invalidateSelf();
  });
  
  ref.onDispose(() {
    timer.cancel();
  });

  return repository.getStats();
});

final recentUsersProvider = FutureProvider<List<ProfileModel>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);

  final timer = Timer(const Duration(seconds: 5), () {
    ref.invalidateSelf();
  });

  ref.onDispose(() {
    timer.cancel();
  });

  return repository.getRecentUsers();
});
