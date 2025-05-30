import 'package:dio/dio.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/report.dart';

class CitizenApiClient {
  final ApiService _apiService;

  CitizenApiClient(this._apiService);

  // Get all issues
  Future<List<Issue>> getIssues() async {
    try {
      // First, verify the backend is reachable
      print('Verifying backend connection at ${_apiService.baseUrl}');
      try {
        // Simple ping to check if server is reachable
        await _apiService.get('/', 
          options: Options(validateStatus: (_) => true)
        );
        print('Backend server is reachable');
      } catch (pingError) {
        print('WARNING: Backend server ping failed: $pingError');
        print('Will still attempt to fetch issues...');
      }
      
      print('Fetching issues from /citizens/issues');
      print('Using API base URL: ${_apiService.baseUrl}');
      final response = await _apiService.get('/citizens/issues');
      
      print('Response status code: ${response.statusCode}');
      print('Full response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        print('Success: ${data['success']}');
        print('Message: ${data['message']}');
        print('Data: ${data['data']}');
        print('Data type: ${data['data']?.runtimeType ?? 'null'}');
        print('Data length: ${data['data']?.length ?? 0}');
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> issuesJson = data['data'];
          if (issuesJson.isEmpty) {
            print('No issues found in the response');
            return [];
          }
          
          print('First issue: ${issuesJson.first}');
          return issuesJson.map((json) => Issue.fromJson(json)).toList();
        } else {
          print('Data is null or success is false');
          print('Response body: $data');
          return [];
        }
      }
      
      print('Non-200 status code: ${response.statusCode}');
      print('Response body: ${response.data}');
      throw Exception('Failed to load issues: ${response.statusCode}');
    } catch (e) {
      print('Exception in getIssues: $e');
      throw Exception('Failed to load issues: $e');
    }
  }

  // Search issues by category
  Future<List<Issue>> searchByCategory(String category) async {
    try {
      final response = await _apiService.get(
        '/citizens/issues/category',
        queryParameters: {'category': category},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> issuesJson = data['data'];
          return issuesJson.map((json) => Issue.fromJson(json)).toList();
        }
      }
      
      throw Exception('Failed to search issues by category: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to search issues by category: $e');
    }
  }

  // Search issues by location
  Future<List<Issue>> searchByLocation(String location) async {
    try {
      final response = await _apiService.get(
        '/citizens/issues/location',
        queryParameters: {'location': location},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> issuesJson = data['data'];
          return issuesJson.map((json) => Issue.fromJson(json)).toList();
        }
      }
      
      throw Exception('Failed to search issues by location: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to search issues by location: $e');
    }
  }

  // Report a new issue
  Future<Issue> reportIssue({
    required String category,
    required String city,
    required String specificAddress,
    required String description,
    required DateTime issueDate,
    required MultipartFile imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'category': category,
        'city': city,
        'specificAddress': specificAddress,
        'description': description,
        'issueDate': issueDate.toIso8601String(),
        'image': imageFile,
      });

      final response = await _apiService.postFormData('/citizens/report', formData: formData);
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return Issue.fromJson(data['data']);
        }
      }
      
      throw Exception('Failed to report issue: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to report issue: $e');
    }
  }

  // Get a single issue by ID
  Future<Issue> getIssueById(String id) async {
    try {
      print('Fetching issue with ID: $id');
      final response = await _apiService.get('/citizens/issues/$id');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return Issue.fromJson(data['data']);
        }
      }
      
      throw Exception('Failed to load issue details: ${response.statusCode}');
    } catch (e) {
      print('Exception in getIssueById: $e');
      throw Exception('Failed to load issue details: $e');
    }
  }
}
