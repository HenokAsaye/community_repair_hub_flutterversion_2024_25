import '../../../../core/network/api_service.dart';
import '../../../shared/models/report.dart';

class TeamApiClient {
  final ApiService _apiService;

  TeamApiClient(this._apiService);

  // Get all issues for the repair team
  Future<List<Issue>> getIssues() async {
    try {
      // Using the same endpoint as citizen for now, can be customized later
      final response = await _apiService.get('/citizens/issues');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> issuesJson = data['data'];
          return issuesJson.map((json) => Issue.fromJson(json)).toList();
        }
      }
      
      throw Exception('Failed to load issues: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to load issues: $e');
    }
  }

  // Update issue status
  Future<Issue> updateIssueStatus(String issueId, String newStatus) async {
    try {
      final response = await _apiService.post(
        '/citizens/issues/$issueId/status',
        data: {'status': newStatus},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return Issue.fromJson(data['data']);
        }
      }
      
      throw Exception('Failed to update issue status: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to update issue status: $e');
    }
  }

  // Filter issues by status
  Future<List<Issue>> filterByStatus(String status) async {
    try {
      final response = await _apiService.get(
        '/citizens/issues',
        queryParameters: {'status': status},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> issuesJson = data['data'];
          return issuesJson.map((json) => Issue.fromJson(json)).toList();
        }
      }
      
      throw Exception('Failed to filter issues by status: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to filter issues by status: $e');
    }
  }
}
