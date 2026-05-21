import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import '../../../../theme/theme_colors.dart';
import '../../../../theme/text_theme.dart';
import '../../../../widgets/glass_box.dart';
import '../providers/statistics_controller.dart';
import '../../domain/models/stat_group_model.dart';
import '../utils/statistics_pdf_export.dart';
import '../../../../widgets/custom_dialog.dart';

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
                style: ThemeTextStyles.h1(isDark: isDark),
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
                    width: 280,
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
                    width: 220,
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
                              final startDate = ref.read(startDateProvider);
                              final endDate = ref.read(endDateProvider);
                              final hasDates = groupType != StatGroupType.reportsByStatus &&
                                  groupType != StatGroupType.usersByStatus;

                              await StatisticsPdfExport.export(
                                statsAsync.value!,
                                groupType.label,
                                startDate: hasDates ? startDate : null,
                                endDate: hasDates ? endDate : null,
                              );
                              if (context.mounted) {
                                showCustomDialog(
                                  context: context,
                                  title: 'Успешно',
                                  message: 'Отчет успешно экспортирован',
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                showCustomDialog(
                                  context: context,
                                  title: 'Ошибка',
                                  message: 'Ошибка экспорта: $e',
                                  isError: true,
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
          if (groupType != StatGroupType.reportsByStatus &&
              groupType != StatGroupType.usersByStatus) ...[
            const SizedBox(height: 24),
            _buildDateRangeSelector(context, ref),
          ],
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

    final hasNoData = data.isEmpty || data.every((e) => e.count == 0);

    if (hasNoData) {
      return GlassBox(
        padding: const EdgeInsets.all(32),
        opacity: isDark ? 0.05 : 0.02,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: ThemeTextStyles.h3(isDark: isDark)),
            if (title.contains('Жалобы по статусу') || title.contains('Пользователи по статусу')) ...[
              const SizedBox(height: 12),
              Text(
                'Текущее время: ${DateFormat('dd.MM.yyyy HH:mm', 'ru').format(DateTime.now())}',
                style: ThemeTextStyles.bodyMedium(
                  isDark: isDark,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
            const SizedBox(height: 80),
            Center(
              child: Text(
                'нет данных',
                style: ThemeTextStyles.h3(
                  isDark: isDark,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
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
              if (title.contains('Жалобы по статусу') || title.contains('Пользователи по статусу')) ...[
                const SizedBox(height: 12),
                Text(
                  'Текущее время: ${DateFormat('dd.MM.yyyy HH:mm', 'ru').format(DateTime.now())}',
                  style: ThemeTextStyles.bodyMedium(
                    isDark: isDark,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
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
    double? width,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
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

  Widget _buildDateRangeSelector(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final startDate = ref.watch(startDateProvider);
    final endDate = ref.watch(endDateProvider);
    final groupType = ref.watch(statGroupTypeProvider);
    final isMonthly = groupType == StatGroupType.revenueByMonth;

    return GlassBox(
      padding: const EdgeInsets.all(16),
      opacity: isDark ? 0.05 : 0.02,
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            isMonthly ? 'Период отчета (в месяцах):' : 'Период отчета:',
            style: ThemeTextStyles.bodyMedium(
              isDark: isDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildDatePickerButton(
            context: context,
            label: isMonthly
                ? 'С: ${_formatMonthLabel(startDate)}'
                : 'С: ${DateFormat('dd.MM.yyyy', 'ru').format(startDate)}',
            onTap: () async {
              if (isMonthly) {
                final picked = await _showMonthYearPicker(
                  context: context,
                  initialDate: startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  maxSelectableDate: endDate,
                );
                if (picked != null) {
                  ref.read(startDateProvider.notifier).setDate(DateTime(picked.year, picked.month, 1));
                }
              } else {
                final now = DateTime.now();
                final lastPossible = endDate.subtract(const Duration(days: 1));
                final picked = await showDatePicker(
                  context: context,
                  initialDate: startDate.isAfter(lastPossible) ? lastPossible : startDate,
                  firstDate: DateTime(2020),
                  lastDate: lastPossible.isAfter(now) ? now : lastPossible,
                  locale: const Locale('ru', 'RU'),
                );
                if (picked != null) {
                  ref.read(startDateProvider.notifier).setDate(picked);
                }
              }
            },
          ),
          _buildDatePickerButton(
            context: context,
            label: isMonthly
                ? 'По: ${_formatMonthLabel(endDate)}'
                : 'По: ${DateFormat('dd.MM.yyyy', 'ru').format(endDate)}',
            onTap: () async {
              if (isMonthly) {
                final picked = await _showMonthYearPicker(
                  context: context,
                  initialDate: endDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  minSelectableDate: startDate,
                );
                if (picked != null) {
                  ref.read(endDateProvider.notifier).setDate(DateTime(picked.year, picked.month + 1, 0));
                }
              } else {
                final now = DateTime.now();
                final firstPossible = startDate.add(const Duration(days: 1));
                final picked = await showDatePicker(
                  context: context,
                  initialDate: endDate.isBefore(firstPossible) ? firstPossible : (endDate.isAfter(now) ? now : endDate),
                  firstDate: firstPossible,
                  lastDate: now,
                  locale: const Locale('ru', 'RU'),
                );
                if (picked != null) {
                  ref.read(endDateProvider.notifier).setDate(picked);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.black.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: ThemeTextStyles.bodyMedium(
                isDark: isDark,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMonthLabel(DateTime date) {
    final raw = DateFormat('MMMM yyyy', 'ru').format(date);
    if (raw.isEmpty) return '';
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }

  Future<DateTime?> _showMonthYearPicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? minSelectableDate,
    DateTime? maxSelectableDate,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        return _MonthYearPickerDialog(
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
          minSelectableDate: minSelectableDate,
          maxSelectableDate: maxSelectableDate,
        );
      },
    );
  }
}

class _MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? minSelectableDate;
  final DateTime? maxSelectableDate;

  const _MonthYearPickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.minSelectableDate,
    this.maxSelectableDate,
  });

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
  }

  static const List<String> _months = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];

  bool _isMonthEnabled(int month) {
    final monthDate = DateTime(_selectedYear, month);
    final firstDateBound = DateTime(widget.firstDate.year, widget.firstDate.month);
    final lastDateBound = DateTime(widget.lastDate.year, widget.lastDate.month);

    if (monthDate.isBefore(firstDateBound) || monthDate.isAfter(lastDateBound)) {
      return false;
    }

    if (widget.minSelectableDate != null) {
      final minBound = DateTime(widget.minSelectableDate!.year, widget.minSelectableDate!.month);
      if (monthDate.isBefore(minBound)) {
        return false;
      }
    }

    if (widget.maxSelectableDate != null) {
      final maxBound = DateTime(widget.maxSelectableDate!.year, widget.maxSelectableDate!.month);
      if (monthDate.isAfter(maxBound)) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        child: GlassBox(
          padding: const EdgeInsets.all(24),
          opacity: isDark ? 0.15 : 0.08,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    onPressed: _selectedYear > widget.firstDate.year
                        ? () {
                            setState(() {
                              _selectedYear--;
                            });
                          }
                        : null,
                  ),
                  Text(
                    '$_selectedYear',
                    style: ThemeTextStyles.h3(isDark: isDark),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    onPressed: _selectedYear < widget.lastDate.year
                        ? () {
                            setState(() {
                              _selectedYear++;
                            });
                          }
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isEnabled = _isMonthEnabled(month);
                  final isSelected = widget.initialDate.year == _selectedYear &&
                      widget.initialDate.month == month;

                  return InkWell(
                    onTap: isEnabled
                        ? () {
                            Navigator.of(context).pop(DateTime(_selectedYear, month));
                          }
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ThemeColors.blue
                            : (isEnabled
                                ? (isDark ? Colors.white10 : Colors.black.withAlpha(10))
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? ThemeColors.blue
                              : (isEnabled
                                  ? (isDark ? Colors.white24 : Colors.black12)
                                  : Colors.transparent),
                        ),
                      ),
                      child: Text(
                        _months[index],
                        style: ThemeTextStyles.bodyMedium(
                          isDark: isDark,
                          color: isSelected
                              ? Colors.white
                              : (isEnabled
                                  ? (isDark ? Colors.white : Colors.black87)
                                  : (isDark ? Colors.white24 : Colors.black26)),
                        ).copyWith(
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Отмена',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
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
