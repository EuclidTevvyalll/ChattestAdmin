import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/profile_model.dart';

abstract class AuthRepository {
  Stream<AuthState> get onAuthStateChange;
  Future<ProfileModel?> login(String email, String password);
  Future<void> logout();
  User? get currentUser;
  Future<ProfileModel?> getProfile(String id);
}
