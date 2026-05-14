import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/models/report_model.dart';
import '../../domain/repositories/moderation_repository.dart';
import '../../data/repositories/supabase_moderation_repository.dart';
import '../../../../core/providers/network/supabase_provider.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  return SupabaseModerationRepository(ref.watch(supabaseClientProvider));
});

class ReportsNotifier extends AsyncNotifier<List<ReportModel>> {
  @override
  Future<List<ReportModel>> build() async {
    return ref.watch(moderationRepositoryProvider).getReports();
  }

  void optimisticUpdateStatus(String reportId, String newStatus) {
    state.whenData((reports) {
      state = AsyncValue.data(
        reports.map((r) => 
          r.id == reportId ? r.copyWith(status: newStatus) : r
        ).toList(),
      );
    });
  }

  void restoreState(List<ReportModel> reports) {
    state = AsyncValue.data(reports);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(moderationRepositoryProvider).getReports());
  }
}

final reportsProvider = AsyncNotifierProvider<ReportsNotifier, List<ReportModel>>(() {
  return ReportsNotifier();
});

class ModerationController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> updateStatus(String reportId, String status) async {
    final reportsNotifier = ref.read(reportsProvider.notifier);
    
    // Сохраняем текущее состояние для отката
    final previousReports = ref.read(reportsProvider).value;
    
    // Оптимистичное обновление
    reportsNotifier.optimisticUpdateStatus(reportId, status);
    
    state = await AsyncValue.guard(() async {
      try {
        await ref.read(moderationRepositoryProvider).updateStatus(reportId, status);
      } catch (e) {
        // Откат при ошибке
        if (previousReports != null) {
          ref.read(reportsProvider.notifier).restoreState(previousReports);
        }
        rethrow;
      }
    });
  }

  Future<void> blockUser(String reportId, String userId, {Duration? duration, String? reason}) async {
    final reportsNotifier = ref.read(reportsProvider.notifier);
    final previousReports = ref.read(reportsProvider).value;

    reportsNotifier.optimisticUpdateStatus(reportId, 'resolved');

    state = await AsyncValue.guard(() async {
      try {
        final repository = ref.read(moderationRepositoryProvider);
        await repository.blockUser(userId, duration: duration, reason: reason);
        await repository.updateStatus(reportId, 'resolved');
      } catch (e) {
        if (previousReports != null) {
          ref.read(reportsProvider.notifier).restoreState(previousReports);
        }
        rethrow;
      }
    });
  }

  Future<void> deleteMessage(String reportId, String messageId) async {
    final reportsNotifier = ref.read(reportsProvider.notifier);
    final previousReports = ref.read(reportsProvider).value;

    reportsNotifier.optimisticUpdateStatus(reportId, 'resolved');

    state = await AsyncValue.guard(() async {
      try {
        final repository = ref.read(moderationRepositoryProvider);
        await repository.deleteMessage(messageId);
        await repository.updateStatus(reportId, 'resolved');
      } catch (e) {
        if (previousReports != null) {
          ref.read(reportsProvider.notifier).restoreState(previousReports);
        }
        rethrow;
      }
    });
  }
}

final moderationControllerProvider = NotifierProvider<ModerationController, AsyncValue<void>>(() {
  return ModerationController();
});
