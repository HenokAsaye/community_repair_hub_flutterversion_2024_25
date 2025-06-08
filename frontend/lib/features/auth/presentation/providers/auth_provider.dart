import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_repair_hub/features/auth/domain/entities/user.dart';
import 'package:community_repair_hub/features/auth/domain/auth_repository.dart';
import 'package:community_repair_hub/features/auth/data/auth_repository_impl.dart';
import 'package:community_repair_hub/core/utils/storage_service.dart';

// Provider for regions and cities
final regionsProvider = FutureProvider<Map<String, List<String>>>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.getRegionsAndCities();
});

// Provider for the auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(ref, repository);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref ref;
  final AuthRepository repository;

  AuthNotifier(this.ref, this.repository) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await repository.login(email, password);
      await SecureStorage.saveToken(user.token);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? imageUrl,
    Map<String, String>? address,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await repository.register(
        name: name,
        email: email,
        password: password,
        role: role,
        imageUrl: imageUrl,
        address: address,
      );
      await SecureStorage.saveToken(user.token);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await SecureStorage.clearToken();
    state = const AsyncValue.data(null);
  }
}
