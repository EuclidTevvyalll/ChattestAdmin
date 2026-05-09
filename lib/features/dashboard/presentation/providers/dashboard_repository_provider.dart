import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/providers/network/supabase_provider.dart';
import '../../data/repositories/supabase_dashboard_repository.dart';
import '../../domain/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  // ignore: unused_local_variable
  final _ = client;
  return SupabaseDashboardRepository(client);
});
