import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:community_repair_hub/core/network/api_service.dart'; // Ensure this path is correct
import '../../../../core/network/api_service_provider.dart';

// Define a simple User model (you might want to expand this)
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profileImageUrl; // Assuming backend might return this

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '', // Adjust based on your backend response
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      profileImageUrl: json['imageUrl'] ?? json['profileImage'], // Check for 'imageUrl' from backend
    );
  }
}

// Define the state for authentication
class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.token,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    String? token,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false, // Flag to explicitly nullify user
    bool clearToken = false, // Flag to explicitly nullify token
    bool clearErrorMessage = false, // Flag to explicitly nullify error message
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: clearUser ? null : user ?? this.user,
      token: clearToken ? null : token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// AuthNotifier class
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final SharedPreferences _sharedPreferences;

  AuthNotifier(this._apiService, this._sharedPreferences) : super(AuthState()) {
    _loadToken(); // Attempt to load token on initialization
  }

  Future<void> _loadToken() async {
    final token = _sharedPreferences.getString('authToken');
    if (token != null) {
      try {
        // Simplified: if token exists, assume authenticated for now.
        // In a real app, you'd fetch user data using the token.
        state = state.copyWith(isAuthenticated: true, token: token);
        debugPrint("Token loaded: $token");

      } catch (e) {
        await _sharedPreferences.remove('authToken'); // Clear invalid token
        state = state.copyWith(isAuthenticated: false, token: null, clearUser: true);
         debugPrint("Failed to validate token or fetch user: $e");
      }
    }
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String region,
    required String city,
    File? profileImageFile,
  }) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    debugPrint("[AuthNotifier] Attempting registration for email: $email");

    try {
      debugPrint("[AuthNotifier] Preparing FormData...");
      Map<String, dynamic> mapData = {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'region': region,
        'city': city,
      };

      if (profileImageFile != null) {
        debugPrint("[AuthNotifier] Profile image file provided: ${profileImageFile.path}");
        if (await profileImageFile.exists()) {
          debugPrint("[AuthNotifier] Profile image file exists at path: ${profileImageFile.path}");
          try {
            String fileName = profileImageFile.path.split('/').last;
            debugPrint("[AuthNotifier] Attempting to create MultipartFile with filename: $fileName from path ${profileImageFile.path}");
            MediaType? contentType;
            if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg')) {
              contentType = MediaType('image', 'jpeg');
            } else if (fileName.toLowerCase().endsWith('.png')) {
              contentType = MediaType('image', 'png');
            } else if (fileName.toLowerCase().endsWith('.gif')) {
              contentType = MediaType('image', 'gif');
            }
            // Add more types if needed

            mapData['image'] = await MultipartFile.fromFile(
              profileImageFile.path,
              filename: fileName,
              contentType: contentType, // Explicitly set content type
            );
            debugPrint("[AuthNotifier] MultipartFile created successfully for image.");
          } catch (e, s) {
            debugPrint("[AuthNotifier] CRITICAL ERROR creating MultipartFile: $e");
            debugPrint("[AuthNotifier] Stacktrace: $s");
            state = state.copyWith(isLoading: false, errorMessage: "Error preparing profile image for upload: $e");
            return false;
          }
        } else {
          debugPrint("[AuthNotifier] CRITICAL ERROR: Profile image file does NOT exist at path: ${profileImageFile.path}");
          state = state.copyWith(isLoading: false, errorMessage: "Selected profile image file not found.");
          return false;
        }
      } else {
        debugPrint("[AuthNotifier] No profile image file provided.");
      }

      final formData = FormData.fromMap(mapData);
      debugPrint("[AuthNotifier] FormData prepared. Fields: ${formData.fields.map((e) => e.key).toList()}, Files: ${formData.files.map((e) => e.key).toList()}");

      debugPrint("[AuthNotifier] Sending request to /auth/register...");
      final response = await _apiService.postFormData('/auth/register', formData: formData);

      debugPrint('[AuthNotifier] Registration Response status code: ${response.statusCode}');
      debugPrint('[AuthNotifier] Registration Response data runtimeType: ${response.data?.runtimeType}');
      debugPrint('[AuthNotifier] Registration Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final token = responseData['token'] as String?;
          final userData = responseData['user'] as Map<String, dynamic>? ?? responseData['data']?['user'] as Map<String, dynamic>?;

          if (token != null && userData != null) {
            await _sharedPreferences.setString('authToken', token);
            state = state.copyWith(
              isAuthenticated: true,
              user: UserModel.fromJson(userData),
              token: token,
              isLoading: false,
            );
            debugPrint("[AuthNotifier] Registration successful. Token: $token, User: ${userData['name']}");
            return true;
          } else {
            debugPrint("[AuthNotifier] Token or user data missing in successful registration response. Response data: $responseData");
            throw DioException(requestOptions: response.requestOptions, message: "Token or user data missing in successful registration response. Response data: $responseData");
          }
        } else {
          debugPrint("[AuthNotifier] Successful registration response data is not a Map. Received: $responseData");
          throw DioException(requestOptions: response.requestOptions, message: "Successful registration response data is not a Map. Received: $responseData");
        }
      } else {
        String detailMessage = 'Registration request failed with status ${response.statusCode}.';
        if (response.data is Map<String, dynamic>) {
          detailMessage = response.data['message'] as String? ?? response.statusMessage ?? detailMessage;
        } else if (response.data is String && (response.data as String).isNotEmpty) {
          String responseSnippet = response.data as String;
          detailMessage = 'Server returned non-JSON error (status ${response.statusCode}). Snippet: ${responseSnippet.substring(0, responseSnippet.length < 150 ? responseSnippet.length : 150)}...';
        } else if (response.statusMessage != null && response.statusMessage!.isNotEmpty) {
          detailMessage = response.statusMessage!;
        }
        debugPrint("[AuthNotifier] Registration failed with status ${response.statusCode}. Detail: $detailMessage. Response data: ${response.data}");
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: detailMessage,
        );
      }
    } on DioException catch (e) {
      String extractedMessage = "An unknown error occurred during registration.";

      debugPrint("---------------------------------------------------------");
      debugPrint("[AuthNotifier] DioException caught during registration:");
      debugPrint("Type: ${e.type}");
      debugPrint("Message from DioException object: ${e.message}");
      debugPrint("Error object: ${e.error}");
      debugPrint("Response Status Code: ${e.response?.statusCode}");
      debugPrint("Response Data Type: ${e.response?.data?.runtimeType}");
      debugPrint("Response Data Raw: ${e.response?.data}");
      debugPrint("Response Headers: ${e.response?.headers}");
      debugPrint("Request Path: ${e.requestOptions.path}");
      debugPrint("---------------------------------------------------------");

      if (e.response != null) {
        if (e.response!.data is Map<String, dynamic>) {
          final responseMap = e.response!.data as Map<String, dynamic>; 
          extractedMessage = responseMap['error']?.toString() ?? 
                             responseMap['message']?.toString() ?? 
                             e.message ??
                             "Server returned JSON, but no 'error' or 'message' field found.";
        } else if (e.response!.data is String && (e.response!.data as String).isNotEmpty) {
          String responseSnippet = e.response!.data as String;
          int snippetLength = responseSnippet.length < 250 ? responseSnippet.length : 250;
          extractedMessage = 'Server returned non-JSON error (status ${e.response?.statusCode}). Response snippet: ${responseSnippet.substring(0, snippetLength)}...';
        } else {
          String rawDataStr = e.response!.data?.toString() ?? "[null response data]";
          int snippetLength = rawDataStr.length < 250 ? rawDataStr.length : 250;
          extractedMessage = 'Server returned non-JSON error (status ${e.response?.statusCode}). Response data snippet: ${rawDataStr.substring(0, snippetLength)}...';
          if (e.message != null && e.message!.isNotEmpty && extractedMessage.length > 150) { 
            extractedMessage += " (DioException message: ${e.message})";
          } else if (e.message != null && e.message!.isNotEmpty) {
            extractedMessage = e.message!;
          }
        }
      } else if (e.message != null && e.message!.isNotEmpty) {
        extractedMessage = e.message!;
      }

      state = state.copyWith(isLoading: false, errorMessage: "Registration failed: $extractedMessage");
      return false;
    } catch (e, s) { // General catch block for any other unexpected errors
      debugPrint("[AuthNotifier] UNEXPECTED CRITICAL ERROR during registration process: $e");
      debugPrint("[AuthNotifier] Stacktrace: $s");
      state = state.copyWith(isLoading: false, errorMessage: "A critical unexpected error occurred: $e");
      state = state.copyWith(isLoading: false, errorMessage: "Registration failed: An unexpected error occurred: ${e.toString()}");
      debugPrint("Final extracted error for UI (Other Exception): ${e.toString()}");
      return false;
    }
  }

  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final response = await _apiService.post(
        '/auth/login', // Your backend login endpoint
        data: {
          'email': email,
          'password': password,
        },
      );

      debugPrint('Login Response status code: ${response.statusCode}');
      debugPrint('Login Response data runtimeType: ${response.data.runtimeType}');
      debugPrint('Login Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final token = responseData['token'] as String?;
          final userData = responseData['user'] as Map<String, dynamic>? ?? responseData['data']?['user'] as Map<String, dynamic>?;

          if (token != null && userData != null) {
            await _sharedPreferences.setString('authToken', token);
            state = state.copyWith(
              isAuthenticated: true,
              user: UserModel.fromJson(userData),
              token: token,
              isLoading: false,
            );
            debugPrint("Login successful. Token: $token, User: ${userData['name']}");
            return true;
          } else {
            throw DioException(requestOptions: response.requestOptions, message: "Token or user data missing in login response. Response data: $responseData");
          }
        } else {
           throw DioException(requestOptions: response.requestOptions, message: "Login response data is not a Map. Received: $responseData");
        }
      } else {
        String detailMessage;
        if (response.data is Map<String, dynamic>) {
          detailMessage = response.data['message'] as String? ?? response.statusMessage ?? 'Unknown error from server.';
        } else if (response.data is String && response.data.isNotEmpty) {
          String responseSnippet = response.data as String;
          if (responseSnippet.length > 150) { 
            responseSnippet = '${responseSnippet.substring(0, 150)}...';
          }
          detailMessage = 'Server returned a non-JSON response (status ${response.statusCode}). Response body: $responseSnippet';
        } else {
          detailMessage = response.statusMessage ?? 'Request failed with status ${response.statusCode}.';
        }
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: "Login failed: $detailMessage",
        );
      }
    } on DioException catch (e) {
      String extractedMessage;
      if (e.response?.data is Map<String, dynamic>) {
        extractedMessage = (e.response!.data as Map<String, dynamic>)['message'] as String? ?? e.message ?? "Unknown error from server.";
      } else if (e.response?.data is String && (e.response!.data as String).isNotEmpty) {
        String responseSnippet = e.response!.data as String;
        if (responseSnippet.length > 200) { 
          responseSnippet = '${responseSnippet.substring(0, 200)}...';
        }
        extractedMessage = 'Server error (status ${e.response?.statusCode}). Response body: $responseSnippet';
      } else {
        extractedMessage = e.message ?? "An unknown Dio error occurred during login.";
      }
      state = state.copyWith(isLoading: false, errorMessage: extractedMessage);
      debugPrint("Login DioException: $extractedMessage");
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: "An unexpected error occurred during login: ${e.toString()}");
      debugPrint("Login Exception: ${e.toString()}");
      return false;
    }
  }

  Future<void> logout() async {
    await _sharedPreferences.remove('authToken');
    state = AuthState(); // Reset to initial state
    debugPrint("User logged out.");
  }
}

// Provider for SharedPreferences
// This provider expects SharedPreferences to be initialized and overridden in main.dart's ProviderScope.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences has not been initialized and overridden in ProviderScope.');
});


// AuthNotifierProvider
// It depends on apiServiceProvider (from dio_client.dart or similar) and sharedPreferencesProvider.
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider); // Ensure apiServiceProvider is defined and provides ApiService
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(apiService, sharedPreferences);
});
