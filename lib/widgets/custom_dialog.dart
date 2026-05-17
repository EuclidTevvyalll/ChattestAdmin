import 'package:flutter/material.dart';
import '../theme/text_theme.dart';
import '../theme/theme_colors.dart';
import 'glass_box.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required String message,
  bool isError = false,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // Используем Future.microtask, чтобы избежать ошибки "!_debugLocked"
  // если диалог вызывается во время построения кадра
  Future.microtask(() {
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(128),
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: GlassBox(
              padding: const EdgeInsets.all(24),
              borderRadius: BorderRadius.circular(32),
              opacity: isDark ? 0.12 : 0.06,
              color: isDark ? Colors.white : Colors.black,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isError ? Colors.redAccent : ThemeColors.blue)
                          .withAlpha((0.1 * 255).toInt()),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isError
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      color: isError ? Colors.redAccent : ThemeColors.blue,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: ThemeTextStyles.h3(isDark: isDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: ThemeTextStyles.caption(isDark: isDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isError
                            ? Colors.redAccent
                            : ThemeColors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'ОК',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  });

  return Future.value();
}
