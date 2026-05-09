import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/providers/network/supabase_provider.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(client);
});

final authStateProvider = StreamProvider((ref) {
  return ref.watch(authRepositoryProvider).onAuthStateChange;
});
