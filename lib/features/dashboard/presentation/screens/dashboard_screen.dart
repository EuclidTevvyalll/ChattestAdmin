import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/theme_colors.dart';
import '../../../../theme/text_theme.dart';
import '../../../../widgets/glass_box.dart';
import '../../domain/models/dashboard_stats.dart';
import '../providers/dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return statsAsync.when(
      data: (stats) => SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статистика системы',
              style: ThemeTextStyles.h2(isDark: isDark),
            ),
            const SizedBox(height: 24),
            _buildStatsGrid(context, stats),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildActivityChart(context, stats)),
                const SizedBox(width: 32),
                Expanded(flex: 1, child: _buildRecentUsers(context, ref)),
              ],
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Ошибка: $err')),
    );
  }

  Widget _buildStatsGrid(BuildContext context, stats) {
    return GridView(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        mainAxisExtent: 140,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          title: 'Пользователи',
          value: stats.totalUsers.toString(),
          icon: Icons.people_rounded,
          trend: stats.userTrend,
          color: ThemeColors.blue,
        ),
        _StatCard(
          title: 'Онлайн',
          value: stats.activeNow.toString(),
          icon: Icons.online_prediction_rounded,
          trend: stats.activeTrend,
          color: Colors.green,
        ),
        _StatCard(
          title: 'Сообщения',
          value: stats.totalMessages.toString(),
          icon: Icons.chat_bubble_rounded,
          trend: stats.messageTrend,
          color: ThemeColors.orange,
        ),
        _StatCard(
          title: 'Доход',
          value: '${stats.revenue.toStringAsFixed(0)} ₽',
          icon: Icons.monetization_on_rounded,
          trend: stats.revenueTrend,
          color: ThemeColors.purple,
        ),
      ],
    );
  }

  Widget _buildActivityChart(BuildContext context, DashboardStats stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activityData = stats.activityData;

    return GlassBox(
      padding: const EdgeInsets.all(32),
      opacity: isDark ? 0.05 : 0.02,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Активность (сообщения)',
            style: ThemeTextStyles.h3(isDark: isDark),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 350,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? Colors.white10 : Colors.black12,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: ThemeTextStyles.caption(
                          isDark: isDark,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= 7) return const SizedBox();
                        final date = DateTime.now().subtract(
                          Duration(days: 6 - index),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            DateFormat('E', 'ru').format(date),
                            style: ThemeTextStyles.caption(
                              isDark: isDark,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: activityData.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value);
                    }).toList(),
                    isCurved: true,
                    color: ThemeColors.blue,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ThemeColors.blue.withAlpha(50),
                          ThemeColors.blue.withAlpha(0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUsers(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usersAsync = ref.watch(recentUsersProvider);

    return GlassBox(
      padding: const EdgeInsets.all(32),
      opacity: isDark ? 0.05 : 0.02,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Новые пользователи', style: ThemeTextStyles.h3(isDark: isDark)),
          const SizedBox(height: 24),
          usersAsync.when(
            data: (users) => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (context, index) => Divider(
                height: 32,
                color: isDark ? Colors.white10 : Colors.black12,
              ),
              itemBuilder: (context, index) {
                final user = users[index];
                final displayDate = user.createdAt ?? user.updatedAt;
                final timeAgo = displayDate != null
                    ? _formatTimeAgo(displayDate)
                    : 'Недавно';

                return InkWell(
                  onTap: () => context.push('/users/${user.id}'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'avatar_${user.id}',
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: ThemeColors.blue.withAlpha(25),
                              shape: BoxShape.circle,
                              image: user.avatarUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(user.avatarUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: user.avatarUrl == null
                                ? const Icon(
                                    Icons.person_outline,
                                    size: 20,
                                    color: ThemeColors.blue,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.nickname ?? user.username,
                                style: ThemeTextStyles.bodyMedium(
                                  isDark: isDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                timeAgo,
                                style: ThemeTextStyles.caption(
                                  isDark: isDark,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Ошибка: $err'),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин. назад';
    if (diff.inHours < 24) return '${diff.inHours} ч. назад';
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String trend;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.trend,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassBox(
      padding: const EdgeInsets.all(20),
      opacity: isDark ? 0.05 : 0.02,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trend,
                    style: ThemeTextStyles.caption(
                      isDark: isDark,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value, style: ThemeTextStyles.h2(isDark: isDark)),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: ThemeTextStyles.caption(
                  isDark: isDark,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
