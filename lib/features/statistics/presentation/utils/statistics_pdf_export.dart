import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../domain/models/stat_group_model.dart';

class StatisticsPdfExport {
  static Future<void> export(List<StatGroupModel> data, String title) async {
    final pdf = pw.Document();
    
    final pw.Font font;
    final pw.Font fontBold;
    final pw.Font fontItalic;

    try {
      font = await PdfGoogleFonts.robotoRegular();
      fontBold = await PdfGoogleFonts.robotoBold();
      fontItalic = await PdfGoogleFonts.robotoItalic();
    } catch (e) {
      throw Exception('Не удалось загрузить шрифты с серверов Google. Пожалуйста, проверьте подключение к Интернету.');
    }

    final maxVal = data.isEmpty
        ? 10.0
        : data.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();

    final List<double> yTicks;
    if (maxVal == 0) {
      yTicks = [0, 2, 4, 6, 8, 10];
    } else {
      double rawStep = maxVal / 5;
      double step;
      if (rawStep <= 1) {
        step = 1;
      } else if (rawStep <= 2) {
        step = 2;
      } else if (rawStep <= 5) {
        step = 5;
      } else if (rawStep <= 10) {
        step = 10;
      } else {
        String expString = rawStep.toStringAsExponential();
        int exponent = int.parse(expString.substring(expString.indexOf('e') + 1));
        double magnitude = double.parse('1e$exponent');
        double normalized = rawStep / magnitude;

        if (normalized <= 1.5) {
          step = 1.0 * magnitude;
        } else if (normalized <= 3.0) {
          step = 2.0 * magnitude;
        } else if (normalized <= 7.0) {
          step = 5.0 * magnitude;
        } else {
          step = 10.0 * magnitude;
        }
      }

      final int steps = (maxVal / step).ceil();
      yTicks = List.generate(steps + 1, (i) => i * step);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
          italic: fontItalic,
        ),
        build: (context) => [
          // Заголовок
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Отчет по статистике: $title',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Text(
                    DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.Divider(thickness: 2, color: PdfColors.blue700),
            ],
          ),
          pw.SizedBox(height: 30),

          // График
          pw.Text(
            'Визуализация данных:',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 15),
          if (data.isEmpty)
            pw.Container(
              height: 100,
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                border: pw.Border.all(color: PdfColors.grey200),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              ),
              child: pw.Text(
                'Нет данных для построения графика',
                style: const pw.TextStyle(color: PdfColors.grey600),
              ),
            )
          else
            pw.Container(
              height: 280,
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                border: pw.Border.all(color: PdfColors.grey200),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              ),
              child: pw.Chart(
                grid: pw.CartesianGrid(
                  xAxis: pw.FixedAxis(
                    data.length == 1
                        ? [0.5, 1.5, 2.5]
                        : List.generate(data.length, (i) => i.toDouble() + 1.5),
                    format: (v) {
                      final index = data.length == 1
                          ? (v == 1.5 ? 0 : -1)
                          : (v - 1.5).round();
                      if (index < 0 || index >= data.length) return "";
                      final label = data[index].label;
                      return label.length > 15
                          ? "${label.substring(0, 12)}..."
                          : label;
                    },
                    ticks: true,
                    textStyle: const pw.TextStyle(fontSize: 9),
                  ),
                  yAxis: pw.FixedAxis(
                    yTicks,
                    format: (v) => v.toInt().toString(),
                    divisions: true,
                    textStyle: const pw.TextStyle(fontSize: 9),
                  ),
                ),
                datasets: [
                  pw.BarDataSet(
                    color: PdfColors.blue700,
                    width: 40,
                    offset: 0,
                    data: List<pw.PointChartValue>.generate(
                      data.length,
                      (i) => pw.PointChartValue(
                        data.length == 1 ? 1.5 : (i.toDouble() + 1.5),
                        data[i].count.toDouble(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          pw.SizedBox(height: 40),

          // Таблица
          pw.Text(
            'Подробные данные:',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 15),
          pw.TableHelper.fromTextArray(
            context: context,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 11,
            ),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headers: ['Категория', 'Количество'],
            data: data
                .map((item) => [item.label, item.count.toString()])
                .toList(),
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.centerLeft,
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FlexColumnWidth(1),
            },
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),

          pw.Spacer(),
          pw.Divider(thickness: 0.5, color: PdfColors.grey400),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Административная панель ForgeLink',
                style: pw.TextStyle(
                  color: PdfColors.grey600,
                  fontSize: 8,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.Text(
                'Страница 1 из 1',
                style: const pw.TextStyle(
                  color: PdfColors.grey600,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Сохраняем во временный файл и открываем
    try {
      final output = await getTemporaryDirectory();
      final filePath = "${output.path}${Platform.pathSeparator}statistics_report_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        throw Exception(result.message);
      }
    } catch (e) {
      throw Exception("Не удалось открыть сгенерированный PDF-файл. Убедитесь, что у вас установлен просмотрщик PDF. Ошибка: $e");
    }
  }
}
