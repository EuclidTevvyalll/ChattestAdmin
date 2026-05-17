import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/report_model.dart';
import '../../domain/repositories/moderation_repository.dart';

class SupabaseModerationRepository implements ModerationRepository {
  final SupabaseClient _client;

  SupabaseModerationRepository(this._client);

  @override
  Future<List<ReportModel>> getReports() async {
    try {
      final response = await _client
          .from('reports')
          .select()
          .order('created_at', ascending: false);

      final List<ReportModel> reports = [];

      for (var item in response) {
        String? reporterName;
        String? targetName;
        String? reportedContent;

        try {
          if (item['reporter_id'] != null) {
            final reporter = await _client
                .from('profiles')
                .select('nickname, username')
                .eq('id', item['reporter_id'])
                .maybeSingle();
            reporterName =
                reporter?['nickname'] ?? reporter?['username'] ?? 'User';
          }

          if (item['target_type'] == 'user') {
            final targetUser = await _client
                .from('profiles')
                .select('nickname, username')
                .eq('id', item['target_id'])
                .maybeSingle();
            targetName =
                targetUser?['nickname'] ??
                targetUser?['username'] ??
                'Unknown User';
          } else if (item['target_type'] == 'message') {
            final targetMsg = await _client
                .from('messages')
                .select(
                  'content, profile_id, is_deleted, media_type, media_url, reply_to_message_id',
                )
                .eq('id', item['target_id'])
                .maybeSingle();

            if (targetMsg != null) {
              final isDeleted = targetMsg['is_deleted'] == true;
              reportedContent = isDeleted
                  ? '${targetMsg['content']} [УДАЛЕНО ПОЛЬЗОВАТЕЛЕМ]'
                  : targetMsg['content'];

              item['target_author_id'] = targetMsg['profile_id'];
              item['media_type'] = targetMsg['media_type'];
              item['media_url'] = targetMsg['media_url'];

              if (targetMsg['reply_to_message_id'] != null) {
                final replyMsg = await _client
                    .from('messages')
                    .select('content, profile_id')
                    .eq('id', targetMsg['reply_to_message_id'])
                    .maybeSingle();

                if (replyMsg != null) {
                  item['reply_to_content'] = replyMsg['content'];
                  final replyAuthor = await _client
                      .from('profiles')
                      .select('nickname, username')
                      .eq('id', replyMsg['profile_id'])
                      .maybeSingle();
                  item['reply_to_author'] =
                      replyAuthor?['nickname'] ??
                      replyAuthor?['username'] ??
                      'Author';
                }
              }

              final msgAuthor = await _client
                  .from('profiles')
                  .select('nickname, username')
                  .eq('id', targetMsg['profile_id'])
                  .maybeSingle();
              targetName =
                  msgAuthor?['nickname'] ??
                  msgAuthor?['username'] ??
                  'Message Author';
            } else {
              targetName = 'Deleted Message';
              reportedContent = '[Сообщение полностью удалено из БД]';
            }
          }
        } catch (e) {
          // Игнорируем ошибки подгрузки связанных данных
        }

        reports.add(
          ReportModel.fromJson({
            ...item,
            'reporter_name': reporterName,
            'target_name': targetName,
            'reported_content': reportedContent,
          }),
        );
      }

      return reports;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateStatus(String reportId, String status) async {
    try {
      await _client
          .from('reports')
          .update({'status': status})
          .eq('id', reportId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> blockUser(
    String userId, {
    Duration? duration,
    String? reason,
  }) async {
    try {
      final updateData = <String, dynamic>{'is_banned': true};
      if (duration != null) {
        updateData['banned_until'] = DateTime.now()
            .toUtc()
            .add(duration)
            .toIso8601String();
      }
      if (reason != null) {
        updateData['banned_reason'] = reason;
      }

      await _client.from('profiles').update(updateData).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await _client
          .from('messages')
          .update({
            'is_deleted': true,
            'deleted_at': DateTime.now().toUtc().toIso8601String(),
            'deleted_by': _client.auth.currentUser?.id,
          })
          .eq('id', messageId);
    } catch (e) {
      rethrow;
    }
  }
}
