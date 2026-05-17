import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/profile_model.dart';
import '../../domain/repositories/user_repository.dart';

class SupabaseUserRepository implements UserRepository {
  final SupabaseClient _client;

  SupabaseUserRepository(this._client);

  @override
  Future<ProfileModel?> getProfile(String id) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  @override
  Future<List<ProfileModel>> getAllUsers({
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await _client
        .from('profiles')
        .select()
        .order('updated_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((json) => ProfileModel.fromJson(json)).toList();
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    final updateData = Map<String, dynamic>.from(profile.toJson())
      ..remove('created_at');
    await _client.from('profiles').update(updateData).eq('id', profile.id);
  }
}
