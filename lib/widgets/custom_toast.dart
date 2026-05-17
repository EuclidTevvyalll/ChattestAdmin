import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';
import 'glass_box.dart';

enum ToastType { success, error, info, warning }

class CustomToast {
  static void show(
    BuildContext context, {
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color baseColor;
    IconData icon;
    String titleText;

    switch (type) {
      case ToastType.success:
        baseColor = Colors.green;
        icon = Icons.check_circle_outline_rounded;
        titleText = 'Успешно';
        break;
      case ToastType.error:
        baseColor = ThemeColors.red;
        icon = Icons.error_outline_rounded;
        titleText = 'Ошибка';
        break;
      case ToastType.warning:
        baseColor = ThemeColors.orange;
        icon = Icons.warning_amber_rounded;
        titleText = 'Внимание';
        break;
      case ToastType.info:
        baseColor = ThemeColors.blue;
        icon = Icons.info_outline_rounded;
        titleText = 'Информация';
        break;
    }

    // Очищаем предыдущие снэкбары для быстрого отклика
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.05,
          left: MediaQuery.of(context).size.width > 600
              ? MediaQuery.of(context).size.width * 0.35
              : 24,
          right: MediaQuery.of(context).size.width > 600
              ? MediaQuery.of(context).size.width * 0.35
              : 24,
        ),
        padding: EdgeInsets.zero,
        duration: duration,
        content: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GlassBox(
            blur: 20,
            opacity: isDark ? 0.12 : 0.06,
            color: baseColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: baseColor.withAlpha((0.25 * 255).toInt()),
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Иконка с красивым фоновым свечением
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: baseColor.withAlpha((0.15 * 255).toInt()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isDark ? Colors.white : baseColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Текст сообщения
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleText,
                        style: TextStyle(
                          color: isDark ? Colors.white : baseColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: TextStyle(
                          color: isDark ? Colors.white.withAlpha(200) : Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Кнопка закрытия
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white38 : Colors.black38,
                    size: 18,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
