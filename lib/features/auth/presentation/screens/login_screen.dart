import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../theme/theme_colors.dart';
import '../../../../theme/text_theme.dart';
import '../../../../widgets/glass_box.dart';
import '../providers/auth_controller.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (err, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err.toString()),
              backgroundColor: ThemeColors.red,
            ),
          );
        },
      );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [Colors.white, const Color(0xFFF0F2F5)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GlassBox(
              width: 450,
              padding: const EdgeInsets.all(40),
              opacity: isDark ? 0.1 : 0.05,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeColors.blue.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 48,
                      color: ThemeColors.blue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Админ-панель',
                    style: ThemeTextStyles.h1(isDark: isDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Управление ForgeLink',
                    style: ThemeTextStyles.bodyMedium(
                      isDark: isDark,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildTextField(
                    controller: emailController,
                    hintText: 'Электронная почта',
                    icon: Icons.email_outlined,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: passwordController,
                    hintText: 'Пароль',
                    icon: Icons.lock_outline,
                    isDark: isDark,
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              ref.read(authControllerProvider.notifier).login(
                                    emailController.text,
                                    passwordController.text,
                                  );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Войти',
                              style: ThemeTextStyles.bodyLarge(
                                color: Colors.white,
                              ),
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
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
  }) {
    return GlassBox(
      opacity: isDark ? 0.05 : 0.03,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      borderRadius: BorderRadius.circular(16),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: ThemeTextStyles.bodyMedium(isDark: isDark),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: ThemeTextStyles.bodyMedium(
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          icon: Icon(icon, color: isDark ? Colors.white54 : Colors.black54),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
