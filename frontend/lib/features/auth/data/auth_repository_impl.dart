// Auth Repository Implementation
import 'package:community_repair_hub/features/auth/data/auth_api_service.dart';
import 'package:community_repair_hub/features/auth/domain/auth_repository.dart';
import 'package:community_repair_hub/features/auth/domain/entities/user.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final _api = AuthApiService(
    Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:3000', // For Android emulator
      // baseUrl: 'http://localhost:3000', // For iOS simulator
    )),
  );

  @override
  Future<User> login(String email, String password) async {
    return await _api.login(email, password);
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? imageUrl,
    Map<String, String>? address,
  }) async {
    return await _api.register(
      name: name,
      email: email,
      password: password,
      role: role,
      imageUrl: imageUrl,
      address: address,
    );
  }

  @override
  Future<Map<String, List<String>>> getRegionsAndCities() async {
    // Temporary hardcoded data while backend endpoint is being set up
    return {
      "Addis Ababa": ["Addis Ababa"],
      "Oromia": ["Adama", "Dire Dawa", "Jimma", "Shashemene"],
      "Amhara": ["Bahir Dar", "Gondar", "Dessie", "Debre Markos"],
      "Tigray": ["Mekelle", "Shire", "Axum", "Adigrat"],
      "Sidama": ["Hawassa"],
      "Somali": ["Jigjiga", "Degehabur", "Gode"],
      "Benishangul-Gumuz": ["Assosa", "Metekel", "Kamashi"],
      "Gambella": ["Gambella", "Abobo", "Itang"],
      "Afar": ["Semera", "Dubti", "Logiya"],
      "Southern Nations, Nationalities, and Peoples' Region (SNNPR)": [
        "Arba Minch",
        "Jinka",
        "Wolayta Sodo"
      ]
    };
  }
}
