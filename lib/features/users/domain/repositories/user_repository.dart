import '../../../../core/models/profile_model.dart';

abstract class UserRepository {
  Future<ProfileModel?> getProfile(String id);
  Future<List<ProfileModel>> getAllUsers({int limit = 50, int offset = 0});
  Future<void> updateProfile(ProfileModel profile);
}
