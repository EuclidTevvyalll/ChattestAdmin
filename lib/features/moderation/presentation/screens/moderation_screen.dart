import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/video_player_bubble.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../theme/theme_colors.dart';
import '../../../../theme/text_theme.dart';
import '../../../../widgets/glass_box.dart';
import '../../domain/models/report_model.dart';
import '../providers/moderation_providers.dart';

class ModerationScreen extends HookConsumerWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedReport = useState<ReportModel?>(null);
    final filterStatus = useState<String>('pending'); // 'all', 'pending', 'handled'

    // Слушаем ошибки контроллера
    ref.listen<AsyncValue<void>>(moderationControllerProvider, (prev, next) {
      next.when(
        data: (_) {},
        error: (err, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка выполнения: $err'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        loading: () {},
      );
    });

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Модерация контента', style: ThemeTextStyles.h1(isDark: isDark)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: () => ref.invalidate(reportsProvider),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _FilterChip(
                          label: 'Новые',
                          isSelected: filterStatus.value == 'pending',
                          onTap: () => filterStatus.value = 'pending',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 12),
                        _FilterChip(
                          label: 'Обработанные',
                          isSelected: filterStatus.value == 'handled',
                          onTap: () => filterStatus.value = 'handled',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 12),
                        _FilterChip(
                          label: 'Все',
                          isSelected: filterStatus.value == 'all',
                          onTap: () => filterStatus.value = 'all',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: reportsAsync.when(
                  data: (reports) {
                    // Фильтрация
                    var filtered = reports.where((r) {
                      if (filterStatus.value == 'pending') return r.status == 'pending';
                      if (filterStatus.value == 'handled') return r.status != 'pending';
                      return true;
                    }).toList();

                    // Сортировка: сначала pending, затем по дате
                    filtered.sort((a, b) {
                      if (a.status == 'pending' && b.status != 'pending') return -1;
                      if (a.status != 'pending' && b.status == 'pending') return 1;
                      return (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now());
                    });

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.filter_list_off_rounded, 
                                 size: 64, color: isDark ? Colors.white24 : Colors.black26),
                            const SizedBox(height: 16),
                            Text('В этой категории ничего не найдено', 
                                 style: ThemeTextStyles.bodyLarge(isDark: isDark, color: isDark ? Colors.white38 : Colors.black38)),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => _ReportCard(
                        report: filtered[index],
                        onTap: () => selectedReport.value = filtered[index],
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Ошибка: $err')),
                ),
              ),
            ],
          ),
        ),
        
        // Внутреннее модальное окно (Overlay)
        if (selectedReport.value != null)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => selectedReport.value = null,
              child: Container(
                color: Colors.black.withAlpha(100),
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {}, // Предотвращаем закрытие при клике на само окно
                  child: _ReportDetailView(
                    report: selectedReport.value!,
                    onClose: () => selectedReport.value = null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReportCard extends ConsumerWidget {
  final ReportModel report;
  final VoidCallback onTap;
  const _ReportCard({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = report.createdAt != null 
        ? DateFormat('dd.MM.yyyy HH:mm').format(report.createdAt!.toLocal()) 
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: GlassBox(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTypeBadge(report.targetType),
                  const SizedBox(width: 12),
                  Text(date, style: ThemeTextStyles.caption(isDark: isDark)),
                  const Spacer(),
                  _buildStatusBadge(report.status),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoLabel('Отправитель', report.reporterName ?? 'ID: ${report.reporterId}', isDark),
                        const SizedBox(height: 16),
                        _buildInfoLabel('Причина', report.localizedReason, isDark, isBold: true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoLabel(
                          report.targetType == 'user' ? 'Цель (Пользователь)' : 'Цель (Сообщение от)', 
                          report.targetName ?? 'ID: ${report.targetId}', 
                          isDark
                        ),
                        if (report.targetType == 'message' && report.reportedContent != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            report.reportedContent!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: ThemeTextStyles.bodySmall(isDark: isDark, color: isDark ? Colors.white54 : Colors.black54),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportDetailView extends ConsumerWidget {
  final ReportModel report;
  final VoidCallback onClose;

  const _ReportDetailView({required this.report, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 700,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: GlassBox(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Детали жалобы', style: ThemeTextStyles.h2(isDark: isDark)),
                const Spacer(),
                _buildStatusBadge(report.status),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
            const Divider(height: 40),
            
            // Прокручиваемая часть
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Информация о репорте
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildInfoLabel('Отправитель', report.reporterName ?? report.reporterId, isDark),
                        ),
                        Expanded(
                          child: _buildInfoLabel('Тип нарушения', report.localizedReason, isDark, isBold: true),
                        ),
                        Expanded(
                          child: _buildInfoLabel(
                            'Дата подачи', 
                            report.createdAt != null ? DateFormat('dd.MM.yyyy HH:mm').format(report.createdAt!.toLocal()) : 'Неизвестно', 
                            isDark
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (report.details != null && report.details!.isNotEmpty) ...[
                      _buildInfoLabel('Дополнительные детали', report.details!, isDark),
                      const SizedBox(height: 24),
                    ],
                    
                    // Информация о цели
                    Text(report.targetType == 'user' ? 'Профиль нарушителя' : 'Контент нарушения', 
                         style: ThemeTextStyles.caption(isDark: isDark)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(report.targetName ?? report.targetId, 
                               style: ThemeTextStyles.bodyLarge(isDark: isDark, fontWeight: FontWeight.bold)),
                          if (report.targetType == 'message' && report.reportedContent != null) ...[
                            const SizedBox(height: 12),
                            
                            // Если это ответ (Reply)
                            if (report.replyToContent != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.only(left: 12),
                                decoration: const BoxDecoration(
                                  border: Border(left: BorderSide(color: ThemeColors.blue, width: 3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(report.replyToAuthor ?? 'Автор', 
                                         style: ThemeTextStyles.caption(isDark: isDark, color: ThemeColors.blue)),
                                    const SizedBox(height: 4),
                                    Text(
                                      report.replyToContent!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: ThemeTextStyles.bodySmall(isDark: isDark, color: isDark ? Colors.white54 : Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
        
                            // Текст сообщения
                            Text(report.reportedContent!, style: ThemeTextStyles.bodyMedium(isDark: isDark)),
                            
                            // Медиа контент
                            if (report.mediaUrl != null) ...[
                              const SizedBox(height: 16),
                              if (report.mediaType?.startsWith('image') ?? false)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: InkWell(
                                    onTap: () => _showMediaDetail(context, isDark, report.mediaUrl!),
                                    child: Image.network(
                                      report.mediaUrl!,
                                      width: 300,
                                      height: 300,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => 
                                        const Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
                                    ),
                                  ),
                                )
                              else if (report.mediaType?.startsWith('video') ?? false)
                                VideoPlayerBubble(
                                  videoUrl: report.mediaUrl!,
                                  maxWidth: 300,
                                )
                              else
                                _buildMediaPlaceholder(report.mediaType ?? 'file'),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 40),
            
            // Кнопки действий
            if (report.status == 'pending')
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Действие: Удалить сообщение
                      if (report.targetType == 'message')
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ref.read(moderationControllerProvider.notifier).deleteMessage(report.id, report.targetId).then((_) => onClose()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Удалить сообщение'),
                          ),
                        ),
                      if (report.targetType == 'message') const SizedBox(width: 16),
                      
                      // Действие: Заблокировать пользователя
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final targetUserId = report.targetType == 'user' 
                                ? report.targetId 
                                : report.targetAuthorId;
                            
                            if (targetUserId == null) return;

                            _showBlockDurationDialog(
                              context, 
                              report.id,
                              targetUserId,
                              report.localizedReason,
                              ref,
                              onClose,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Заблокировать нарушителя'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => ref.read(moderationControllerProvider.notifier).updateStatus(report.id, 'dismissed').then((_) => onClose()),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                          ),
                          child: Text('Отклонить жалобу', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withAlpha(50)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text('Обработано', style: ThemeTextStyles.bodyMedium(isDark: isDark, color: Colors.green)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMediaDetail(BuildContext context, bool isDark, String mediaUrl) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black.withAlpha(128),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: const [],
        ),
        body: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: mediaUrl.startsWith('data:image')
                ? Image.memory(
                    // ignore: always_specify_types
                    const Base64Decoder().convert(mediaUrl.split(',').last),
                    fit: BoxFit.contain,
                  )
                : Image.network(
                    mediaUrl,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 64,
                    ),
                    fit: BoxFit.contain,
                  ),
          ),
        ),
      ),
    );
  }

  void _confirmAction(BuildContext context, String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Закрыть диалог подтверждения
              onConfirm();
              onClose(); // Закрыть окно деталей
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }

  void _showBlockDurationDialog(BuildContext context, String reportId, String userId, String reason, WidgetRef ref, VoidCallback onClose) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Заблокировать пользователя?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Выберите продолжительность блокировки:'),
            const SizedBox(height: 16),
            _buildDurationOption(context, 'На 1 час', const Duration(hours: 1), reportId, userId, reason, ref, onClose),
            _buildDurationOption(context, 'На 1 день', const Duration(days: 1), reportId, userId, reason, ref, onClose),
            _buildDurationOption(context, 'На 1 неделю', const Duration(days: 7), reportId, userId, reason, ref, onClose),
            _buildDurationOption(context, 'На 1 месяц', const Duration(days: 30), reportId, userId, reason, ref, onClose),
            _buildDurationOption(context, 'Навсегда', null, reportId, userId, reason, ref, onClose),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationOption(BuildContext context, String label, Duration? duration, String reportId, String userId, String reason, WidgetRef ref, VoidCallback onClose) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Закрыть диалог
        ref.read(moderationControllerProvider.notifier).blockUser(reportId, userId, duration: duration, reason: reason);
        onClose(); // Закрыть окно деталей
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            const Icon(Icons.block, color: Colors.redAccent, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

Widget _buildInfoLabel(String label, String value, bool isDark, {bool isBold = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: ThemeTextStyles.caption(isDark: isDark)),
      const SizedBox(height: 4),
      Text(value, style: ThemeTextStyles.bodyMedium(isDark: isDark, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
    ],
  );
}

Widget _buildMediaPlaceholder(String type) {
  IconData icon;
  String label;
  
  if (type.startsWith('video')) {
    icon = Icons.play_circle_outline_rounded;
    label = 'Видео';
  } else if (type.startsWith('audio')) {
    icon = Icons.audiotrack_rounded;
    label = 'Аудио';
  } else if (type.startsWith('image')) {
    icon = Icons.image_outlined;
    label = 'Изображение';
  } else {
    icon = Icons.insert_drive_file_rounded;
    label = 'Файл';
  }

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white.withAlpha(10),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: ThemeColors.blue),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}

Widget _buildTypeBadge(String type) {
  final color = type == 'user' ? Colors.orange : Colors.blue;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withAlpha(40),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withAlpha(100)),
    ),
    child: Text(
      type.toUpperCase(),
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildStatusBadge(String status) {
  Color color;
  String text;
  switch (status) {
    case 'resolved':
      color = Colors.green;
      text = 'РЕШЕНО';
      break;
    case 'dismissed':
      color = Colors.grey;
      text = 'ОТКЛОНЕНО';
      break;
    default:
      color = Colors.orange;
      text = 'ОЖИДАЕТ';
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withAlpha(40),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withAlpha(100)),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? ThemeColors.blue 
              : (isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ThemeColors.blue : (isDark ? Colors.white10 : Colors.black12),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: ThemeColors.blue.withAlpha(80),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: ThemeTextStyles.bodySmall(
            isDark: isDark, 
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

extension RoundedRectangle on RoundedRectangleBorder {
  static RoundedRectangleBorder circular(double radius) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
}
