import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../theme/theme_colors.dart';
import '../../../../theme/text_theme.dart';
import '../../../../widgets/glass_box.dart';
import '../providers/statistics_controller.dart';
import '../../domain/models/stat_group_model.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statsAsync = ref.watch(statisticsProvider);
    final groupType = ref.watch(statGroupTypeProvider);
    final sortType = ref.watch(statSortTypeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Детальная статистика',
                style: ThemeTextStyles.h2(isDark: isDark),
              ),
              Row(
                children: [
                  _buildDropdown<StatGroupType>(
                    context,
                    value: groupType,
                    items: StatGroupType.values,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(statGroupTypeProvider.notifier).setType(val);
                      }
                    },
                    labelExtractor: (item) => item.label,
                  ),
                  const SizedBox(width: 16),
                  _buildDropdown<StatSortType>(
                    context,
                    value: sortType,
                    items: StatSortType.values,
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(statSortTypeProvider.notifier).setType(val);
                      }
                    },
                    labelExtractor: (item) => item.label,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          statsAsync.when(
            data: (data) => _buildContent(context, data, groupType.label),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(64.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(64.0),
                child: Text('Ошибка загрузки: $err', style: TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<StatGroupModel> data, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(64.0),
          child: Text(
            'Нет данных для отображения',
            style: ThemeTextStyles.h3(isDark: isDark),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: GlassBox(
            padding: const EdgeInsets.all(32),
            opacity: isDark ? 0.05 : 0.02,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ThemeTextStyles.h3(isDark: isDark),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 350,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: data.isEmpty
                          ? 10
                          : data.map((e) => e.count).reduce((a, b) => a > b ? a : b) * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => isDark ? Colors.grey[800]! : Colors.grey[200]!,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${data[groupIndex].label}\n',
                              TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: rod.toY.toInt().toString(),
                                  style: TextStyle(
                                    color: ThemeColors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, _) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  data[value.toInt()].label,
                                  style: ThemeTextStyles.caption(
                                      isDark: isDark,
                                      color: isDark ? Colors.white70 : Colors.black87),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: ThemeTextStyles.caption(
                                  isDark: isDark, color: isDark ? Colors.white38 : Colors.black38),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: isDark ? Colors.white10 : Colors.black12,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: data.asMap().entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.count.toDouble(),
                              color: ThemeColors.blue,
                              width: 32,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 1,
          child: GlassBox(
            padding: const EdgeInsets.all(24),
            opacity: isDark ? 0.05 : 0.02,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Таблица данных',
                  style: ThemeTextStyles.h3(isDark: isDark),
                ),
                const SizedBox(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 32,
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.label,
                          style: ThemeTextStyles.bodyMedium(
                              isDark: isDark, fontWeight: FontWeight.w500),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: ThemeColors.blue.withAlpha(25),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            item.count.toString(),
                            style: ThemeTextStyles.bodyMedium(
                              isDark: isDark,
                              color: ThemeColors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(
    BuildContext context, {
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String Function(T) labelExtractor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: isDark ? const Color(0xFF16213E) : Colors.white,
          icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white70 : Colors.black87),
          style: ThemeTextStyles.bodyMedium(isDark: isDark),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(labelExtractor(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
