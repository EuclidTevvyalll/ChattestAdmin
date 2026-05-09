import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/router.dart';
import 'theme/app_theme.dart';

late final SharedPreferences shared;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru', null);
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(1100, 700),
    center: true,
    title: 'ForgeLink Admin',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await Supabase.initialize(
    url: 'https://qhrcpooazwkdckusqcvx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFocmNwb29hendrZGNrdXNxY3Z4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwNDQ2MTUsImV4cCI6MjA5MzYyMDYxNX0.8XPliDnwo_-63kqqbMRSvC0oi_M8Biw2Rt4hjLpipx8',
  );

  shared = await SharedPreferences.getInstance();

  runApp(const ProviderScope(child: AdminApp()));
}

class AdminApp extends HookConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ForgeLink Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
