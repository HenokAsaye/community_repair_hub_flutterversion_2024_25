// Auth Repository Interface
import 'package:community_repair_hub/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? imageUrl,
    Map<String, String>? address,
  });
  Future<Map<String, List<String>>> getRegionsAndCities();
}
