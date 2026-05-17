import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/profile_model.dart';
import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository(this._client);

  @override
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<ProfileModel?> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      return getProfile(response.user!.id);
    }
    return null;
  }

  @override
  Future<void> logout() => _client.auth.signOut();

  @override
  Future<ProfileModel?> getProfile(String id) async {
    final data = await _client.from('profiles').select().eq('id', id).single();

    return ProfileModel.fromJson(data);
  }
}
