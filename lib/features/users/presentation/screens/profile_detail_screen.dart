import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../theme/theme_colors.dart';
import '../../../../theme/text_theme.dart';
import '../../../../widgets/glass_box.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../providers/user_providers.dart';

class ProfileDetailScreen extends ConsumerWidget {
  final String userId;

  const ProfileDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider(userId));
    final currentAuth = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentUserId = currentAuth.maybeWhen(
      data: (user) => user?.id,
      orElse: () => null,
    );
    final isOwnProfile = currentUserId == userId;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('Детали профиля', style: ThemeTextStyles.h3(isDark: isDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Пользователь не найден'));
          }

          final registrationDate = user.createdAt ?? user.updatedAt;
          final formattedDate = registrationDate != null
              ? DateFormat('dd MMMM yyyy, HH:mm', 'ru').format(registrationDate)
              : 'Неизвестно';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, user, isDark),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildMainInfo(context, user, formattedDate, isDark),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Ошибка: $err')),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, bool isDark) {
    return GlassBox(
      padding: const EdgeInsets.all(40),
      child: Row(
        children: [
          Hero(
            tag: 'avatar_${user.id}',
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: ThemeColors.blue.withAlpha(30),
                shape: BoxShape.circle,
                border: Border.all(color: ThemeColors.blue.withAlpha(50), width: 2),
                image: user.avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(user.avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: user.avatarUrl == null
                  ? const Icon(Icons.person, size: 60, color: ThemeColors.blue)
                  : null,
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.nickname ?? user.username,
                      style: ThemeTextStyles.h1(isDark: isDark),
                    ),
                    const SizedBox(width: 16),
                    if (user.isAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: ThemeColors.blue.withAlpha(40),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: ThemeColors.blue.withAlpha(100)),
                        ),
                        child: Text(
                          'ADMIN',
                          style: ThemeTextStyles.caption(
                            isDark: isDark,
                            color: ThemeColors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '@${user.username}',
                  style: ThemeTextStyles.bodyLarge(
                    isDark: isDark,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatusBadge(user.isOnline ?? false),
                    const SizedBox(width: 24),
                    Text(
                      'ID: ${user.id}',
                      style: ThemeTextStyles.caption(isDark: isDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isOnline) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isOnline ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
            boxShadow: [
              if (isOnline)
                BoxShadow(
                  color: Colors.green.withAlpha(100),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isOnline ? 'В сети' : 'Не в сети',
          style: TextStyle(
            color: isOnline ? Colors.green : Colors.grey,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMainInfo(BuildContext context, dynamic user, String date, bool isDark) {
    return GlassBox(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Основная информация', style: ThemeTextStyles.h3(isDark: isDark)),
          const SizedBox(height: 32),
          _buildInfoRow('Имя пользователя', user.username, Icons.alternate_email, isDark),
          _buildInfoRow('Отображаемое имя', user.nickname ?? 'Не задано', Icons.face, isDark),
          _buildInfoRow('Дата регистрации', date, Icons.calendar_today, isDark),
          _buildInfoRow('Последнее обновление', 
            user.updatedAt != null ? DateFormat('dd.MM.yyyy').format(user.updatedAt!) : 'Нет данных', 
            Icons.update, isDark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withAlpha(12) : Colors.black.withAlpha(12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: ThemeColors.blue),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: ThemeTextStyles.caption(isDark: isDark)),
              const SizedBox(height: 4),
              Text(value, style: ThemeTextStyles.bodyLarge(isDark: isDark, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, dynamic user, bool isDark) {
    return GlassBox(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Действия', style: ThemeTextStyles.h3(isDark: isDark)),
          const SizedBox(height: 24),
          _buildActionButton(
            'Заблокировать', 
            Icons.block, 
            Colors.redAccent, 
            () {},
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            user.isAdmin ? 'Снять права админа' : 'Сделать админом', 
            Icons.security, 
            user.isAdmin ? Colors.orange : Colors.blueGrey, 
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: color.withAlpha(50)),
          borderRadius: BorderRadius.circular(12),
          color: color.withAlpha(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnProfileNotice(bool isDark) {
    return GlassBox(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeColors.blue.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_rounded, color: ThemeColors.blue, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            'Это ваш профиль',
            style: ThemeTextStyles.h3(isDark: isDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Вы просматриваете свои данные. Управление собственным аккаунтом через панель действий ограничено в целях безопасности.',
            style: ThemeTextStyles.caption(
              isDark: isDark,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
