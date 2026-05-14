import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../../theme/theme_colors.dart';
import '../../../../theme/text_theme.dart';
import '../../../../widgets/glass_box.dart';

class MainLayoutScreen extends ConsumerWidget {
  final Widget child;

  const MainLayoutScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        child: Row(
          children: [
            const _Sidebar(),
            Expanded(
              child: Column(
                children: [
                  const _Header(),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);

    return GlassBox(
      width: 280,
      borderRadius: BorderRadius.zero,
      border: Border(
        right: BorderSide(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      opacity: isDark ? 0.05 : 0.02,
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Admin Profile Section
          authState.when(
            data: (user) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: InkWell(
              onTap: user != null
                  ? () {
                      final targetPath = '/users/${user.id}';
                      if (GoRouterState.of(context).uri.path != targetPath) {
                        context.go(targetPath);
                      }
                    }
                  : null,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'avatar_${user?.id}',
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: ThemeColors.blue.withAlpha(50),
                            shape: BoxShape.circle,
                            border: Border.all(color: ThemeColors.blue.withAlpha(100), width: 1.5),
                            image: user?.avatarUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(user!.avatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: user?.avatarUrl == null
                              ? const Icon(Icons.person_rounded, color: ThemeColors.blue, size: 24)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.nickname ?? user?.username ?? 'Admin',
                              style: ThemeTextStyles.bodyLarge(
                                isDark: isDark,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Администратор',
                              style: ThemeTextStyles.caption(
                                isDark: isDark,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, _) => const SizedBox(),
          ),
          const SizedBox(height: 32),
          Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
          const SizedBox(height: 32),
          _SidebarItem(
            icon: Icons.dashboard_rounded,
            label: 'Дашборд',
            isSelected: location == '/',
            onTap: () => context.go('/'),
          ),
          _SidebarItem(
            icon: Icons.gavel_rounded,
            label: 'Модерация',
            isSelected: location == '/moderation',
            onTap: () => context.go('/moderation'),
          ),
          _SidebarItem(
            icon: Icons.analytics_rounded,
            label: 'Статистика',
            isSelected: location == '/statistics',
            onTap: () => context.go('/statistics'),
          ),
          const Spacer(),
          _SidebarItem(
            icon: Icons.settings_rounded,
            label: 'Настройки',
            isSelected: location == '/settings',
            onTap: () => context.go('/settings'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? ThemeColors.blue.withAlpha(isDark ? 40 : 25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: ThemeColors.blue.withAlpha(50))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? ThemeColors.blue
                    : (isDark ? Colors.white54 : Colors.black54),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: ThemeTextStyles.bodyMedium(
                  isDark: isDark,
                  color: isSelected
                      ? (isDark ? Colors.white : ThemeColors.blue)
                      : (isDark ? Colors.white54 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Панель управления',
            style: ThemeTextStyles.h3(isDark: isDark),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.logout_rounded,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
            tooltip: 'Выйти из системы',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
