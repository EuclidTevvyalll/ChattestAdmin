import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/models/report_model.dart';
import '../../domain/repositories/moderation_repository.dart';
import '../../data/repositories/supabase_moderation_repository.dart';
import '../../../../core/providers/network/supabase_provider.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  return SupabaseModerationRepository(ref.watch(supabaseClientProvider));
});

final reportsProvider = FutureProvider<List<ReportModel>>((ref) {
  return ref.watch(moderationRepositoryProvider).getReports();
});

class ModerationController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> updateStatus(String reportId, String status) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(moderationRepositoryProvider).updateStatus(reportId, status);
      ref.invalidate(reportsProvider);
    });
  }

  Future<void> blockUser(String reportId, String userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(moderationRepositoryProvider);
      await repository.blockUser(userId);
      await repository.updateStatus(reportId, 'resolved');
      ref.invalidate(reportsProvider);
    });
  }

  Future<void> deleteMessage(String reportId, String messageId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(moderationRepositoryProvider);
      await repository.deleteMessage(messageId);
      await repository.updateStatus(reportId, 'resolved');
      ref.invalidate(reportsProvider);
    });
  }
}

final moderationControllerProvider = NotifierProvider<ModerationController, AsyncValue<void>>(() {
  return ModerationController();
});
