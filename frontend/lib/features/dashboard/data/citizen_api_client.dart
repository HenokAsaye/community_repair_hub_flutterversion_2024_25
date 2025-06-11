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
      print('Preparing form data for report submission');
      print('Image file name: ${imageFile.filename}');
      print('Image content type: ${imageFile.contentType}');
      
      final formData = FormData.fromMap({
        'category': category,
        'city': city,
        'specificAddress': specificAddress,
        'description': description,
        'issueDate': issueDate.toIso8601String(),
        'image': imageFile,
      });
      
      print('FormData created successfully');
      print('Sending request to /citizens/report');

      final response = await _apiService.postFormData('/citizens/report', formData: formData);
      
      print('Response received: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          print('Successfully created issue with ID: ${data['data']['_id'] ?? 'unknown'}');
          return Issue.fromJson(data['data']);
        } else {
          print('API returned success=false or null data');
          throw Exception('API returned invalid response format: ${response.data}');
        }
      }
      
      print('Non-200 status code: ${response.statusCode}');
      throw Exception('Failed to report issue: ${response.statusCode} - ${response.data}');
    } catch (e) {
      print('Exception in reportIssue: $e');
      throw Exception('Failed to report issue: $e');
    }
  }

  // Get a single issue by ID
  Future<Issue> getIssueById(String id) async {
    try {
      print('===== FRONTEND: FETCHING ISSUE BY ID =====');
      print('Fetching issue with ID: $id');
      print('API base URL: ${_apiService.baseUrl}');
      print('Endpoint: /citizens/issues/$id');
      
      final response = await _apiService.get('/citizens/issues/$id');
      
      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        print('Success: ${data['success']}');
        print('Message: ${data['message']}');
        
        if (data['success'] == true && data['data'] != null) {
          print('Data: ${data['data']}');
          final issue = Issue.fromJson(data['data']);
          print('Parsed issue:');
          print('  ID: ${issue.id}');
          print('  Category: ${issue.category}');
          print('  Image URL: ${issue.imageURL}');
          return issue;
        } else {
          print('Data is null or success is false');
          throw Exception('Invalid response format: ${response.data}');
        }
      }
      
      print('Non-200 status code: ${response.statusCode}');
      throw Exception('Failed to load issue details: ${response.statusCode}');
    } catch (e) {
      print('Exception in getIssueById: $e');
      throw Exception('Failed to load issue details: $e');
    }
  }

  // Update issue status by ID (for repair team)
  Future<Issue> updateIssueStatus({
    required String issueId,
    required String status,
    required String notes,
  }) async {
    try {
      print('===== FRONTEND: UPDATING ISSUE STATUS =====');
      print('Updating issue with ID: $issueId');
      print('New status: $status, Notes: $notes');
      print('API base URL: ${_apiService.baseUrl}');
      print('Endpoint: /team/issues/$issueId/status');

      final response = await _apiService.put(
        '/team/issues/$issueId/status', // Corrected endpoint for team status updates
        data: {
          'status': status,
          'notes': notes,
          'timestamp': DateTime.now().toIso8601String(), // Adding a timestamp for the update
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['success'] == true && data['data'] != null) {
          print('Successfully updated issue: ${data['data']}');
          return Issue.fromJson(data['data']);
        } else {
          print('API returned success=false or null data for update: $data');
          throw Exception('Failed to update issue status: API returned invalid response format.');
        }
      }
      
      print('Non-200 status code for update: ${response.statusCode}');
      throw Exception('Failed to update issue status: ${response.statusCode} - ${response.data}');
    } catch (e) {
      print('Exception in updateIssueStatus: $e');
      // Try to provide more specific error messages based on DioException
      if (e is DioException && e.response != null) {
        print('DioException response data: ${e.response?.data}');
        final errorData = e.response?.data;
        String errorMessage = 'Failed to update issue status.';
        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage += ' Server: ${errorData['message']}';
        } else if (errorData != null) {
          errorMessage += ' Server response: $errorData';
        }
        throw Exception(errorMessage);
      }
      throw Exception('Failed to update issue status: $e');
    }
  }
}
