import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/providers/network/supabase_provider.dart';
import '../../../../core/models/profile_model.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/supabase_user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseUserRepository(client);
});

final userProfileProvider = FutureProvider.family<ProfileModel?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getProfile(id);
});
