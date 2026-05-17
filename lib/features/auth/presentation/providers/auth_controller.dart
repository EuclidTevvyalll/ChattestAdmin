import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/models/profile_model.dart';
import 'auth_providers.dart';

class AuthController extends Notifier<AsyncValue<ProfileModel?>> {
  @override
  AsyncValue<ProfileModel?> build() {
    _init();
    return const AsyncValue.loading();
  }

  void _init() async {
    await Future.microtask(() {});
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      state = await AsyncValue.guard(
        () => ref.read(authRepositoryProvider).getProfile(user.id),
      );
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw Exception('Заполните поля');
      }
      try {
        final profile = await ref
            .read(authRepositoryProvider)
            .login(email.trim(), password.trim());
        if (profile == null) {
          throw Exception('Неверный логин или пароль');
        }
        if (!profile.isAdmin) {
          await ref.read(authRepositoryProvider).logout();
          throw Exception('У вас нет доступа к программе');
        }
        return profile;
      } catch (e) {
        final errString = e.toString();
        if (errString.contains('Access denied') ||
            errString.contains('User is not an admin') ||
            errString.contains('У вас нет доступа к программе')) {
          throw Exception('У вас нет доступа к программе');
        }
        if (errString.contains('Заполните поля')) {
          throw Exception('Заполните поля');
        }
        throw Exception('Неверный логин или пароль');
      }
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<ProfileModel?>>(
      () => AuthController(),
    );
