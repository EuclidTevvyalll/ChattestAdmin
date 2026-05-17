import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../theme/theme_colors.dart';
import '../../../../theme/text_theme.dart';
import '../../../../widgets/glass_box.dart';
import '../providers/statistics_controller.dart';
import '../../domain/models/stat_group_model.dart';
import '../utils/statistics_pdf_export.dart';
import '../../../../widgets/custom_toast.dart';

class StatisticsScreen extends HookConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statsAsync = ref.watch(statisticsProvider);
    final groupType = ref.watch(statGroupTypeProvider);
    final sortType = ref.watch(statSortTypeProvider);
    final isExporting = useState(false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 24,
            runSpacing: 16,
            children: [
              Text(
                'Детальная статистика',
                style: ThemeTextStyles.h2(isDark: isDark),
              ),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
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
                  ElevatedButton.icon(
                    onPressed: (statsAsync.hasValue && !isExporting.value)
                        ? () async {
                            isExporting.value = true;
                            try {
                              await StatisticsPdfExport.export(
                                statsAsync.value!,
                                groupType.label,
                              );
                              if (context.mounted) {
                                CustomToast.show(
                                  context,
                                  message: 'Отчет успешно экспортирован',
                                  type: ToastType.success,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                CustomToast.show(
                                  context,
                                  message: 'Ошибка экспорта: $e',
                                  type: ToastType.error,
                                );
                              }
                            } finally {
                              isExporting.value = false;
                            }
                          }
                        : null,
                    icon: isExporting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf, size: 20),
                    label: Text(
                      isExporting.value ? 'Формирование...' : 'Экспорт в PDF',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 19,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                child: Text(
                  'Ошибка загрузки: $err',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<StatGroupModel> data,
    String title,
  ) {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartBox = GlassBox(
          padding: const EdgeInsets.all(32),
          opacity: isDark ? 0.05 : 0.02,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: ThemeTextStyles.h3(isDark: isDark)),
              const SizedBox(height: 32),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  height: 350,
                  width: (data.length * 80.0).clamp(
                    constraints.maxWidth - 64,
                    2000.0,
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: data.isEmpty
                          ? 10
                          : (data
                                        .map((e) => e.count)
                                        .reduce((a, b) => a > b ? a : b) *
                                    1.25)
                                .toDouble(),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipColor: (group) =>
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final value = rod.toY;
                            final formattedValue = title.contains('Выручка')
                                ? '${value.toStringAsFixed(0)} ₽'
                                : value.toInt().toString();
                            return BarTooltipItem(
                              '${data[groupIndex].label}\n',
                              TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: formattedValue,
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                                    fontWeight: FontWeight.bold,
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
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= data.length) {
                                return const SizedBox();
                              }
                              return SideTitleWidget(
                                meta: meta,
                                space: 10,
                                child: SizedBox(
                                  width: 80,
                                  child: Text(
                                    data[index].label,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: ThemeTextStyles.caption(
                                      isDark: isDark,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              final formattedValue = title.contains('Выручка')
                                  ? '${value.toInt()}₽'
                                  : value.toInt().toString();
                              return SideTitleWidget(
                                meta: meta,
                                child: Text(
                                  formattedValue,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
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
              ),
            ],
          ),
        );

        final tableBox = GlassBox(
          padding: const EdgeInsets.all(24),
          opacity: isDark ? 0.05 : 0.02,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Таблица данных', style: ThemeTextStyles.h3(isDark: isDark)),
              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                separatorBuilder: (_, _) => Divider(
                  color: isDark ? Colors.white10 : Colors.black12,
                  height: 32,
                ),
                itemBuilder: (context, index) {
                  final item = data[index];
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          style: ThemeTextStyles.bodyMedium(isDark: isDark),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColors.blue.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          title.contains('Выручка')
                              ? '${item.count.toStringAsFixed(0)} ₽'
                              : item.count.toInt().toString(),
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
        );

        if (constraints.maxWidth < 1000) {
          return Column(
            children: [chartBox, const SizedBox(height: 32), tableBox],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: chartBox),
            const SizedBox(width: 32),
            Expanded(flex: 1, child: tableBox),
          ],
        );
      },
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
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF16213E) : Colors.white,
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          style: ThemeTextStyles.bodyMedium(isDark: isDark),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                labelExtractor(item),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
