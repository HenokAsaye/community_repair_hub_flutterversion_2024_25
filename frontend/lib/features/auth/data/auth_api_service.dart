import 'package:dio/dio.dart';
import 'package:community_repair_hub/features/auth/domain/entities/user.dart';

class AuthApiService {
  final Dio dio;

  AuthApiService(this.dio);

  Future<User> login(String email, String password) async {
    final response = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return User.fromJson(response.data);
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? imageUrl,
    Map<String, String>? address,
  }) async {
    final response = await dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (address != null) 'Address': address,
      'status': role == 'RepairTeam' ? 'pending_repairteam' : 'approved',
    });
    return User.fromJson(response.data);
  }

  Future<Map<String, List<String>>> getRegionsAndCities() async {
    try {
      final response = await dio.get('/regions');
      final data = response.data as Map<String, dynamic>;
      return Map<String, List<String>>.from(
        data.map((key, value) => MapEntry(
              key,
              (value as List).map((city) => city.toString()).toList(),
            )),
      );
    } catch (e) {
      print('Error fetching regions and cities: $e');
      // Return empty map if API fails
      return {};
    }
  }
}
