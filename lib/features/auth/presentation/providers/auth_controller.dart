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
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      state = await AsyncValue.guard(
          () => ref.read(authRepositoryProvider).getProfile(user.id));
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final profile =
          await ref.read(authRepositoryProvider).login(email, password);
      if (profile != null && !profile.isAdmin) {
        await ref.read(authRepositoryProvider).logout();
        throw Exception('Access denied: User is not an admin');
      }
      return profile;
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
