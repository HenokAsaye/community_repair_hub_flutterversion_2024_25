import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/report.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_service_provider.dart';

// Team Issues state
enum TeamIssuesStateStatus { initial, loading, success, error }

class TeamIssuesState {
  final TeamIssuesStateStatus status;
  final List<Issue> issues;
  final String? errorMessage;
  final String? searchQuery;
  final String? statusFilter;
  final String? priorityFilter;

  TeamIssuesState({
    this.status = TeamIssuesStateStatus.initial,
    this.issues = const [],
    this.errorMessage,
    this.searchQuery,
    this.statusFilter,
    this.priorityFilter,
  });

  TeamIssuesState copyWith({
    TeamIssuesStateStatus? status,
    List<Issue>? issues,
    String? errorMessage,
    String? searchQuery,
    String? statusFilter,
    String? priorityFilter,
  }) {
    return TeamIssuesState(
      status: status ?? this.status,
      issues: issues ?? this.issues,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      priorityFilter: priorityFilter ?? this.priorityFilter,
    );
  }

  List<Issue> get filteredIssues {
    if ((searchQuery == null || searchQuery!.isEmpty) && 
        (statusFilter == null || statusFilter!.isEmpty) && 
        (priorityFilter == null || priorityFilter!.isEmpty)) {
      return issues;
    }

    return issues.where((issue) {
      // Apply search query filter
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        final query = searchQuery!.toLowerCase();
        if (!issue.description.toLowerCase().contains(query) &&
            !issue.category.toLowerCase().contains(query) &&
            !issue.locations.city.toLowerCase().contains(query) &&
            !issue.locations.specificArea.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Apply status filter
      if (statusFilter != null && statusFilter!.isNotEmpty) {
        if (!issue.status.toLowerCase().contains(statusFilter!.toLowerCase())) {
          return false;
        }
      }

      // Apply priority filter (assuming we add priority to the Issue model later)
      // For now, we'll skip this filter

      return true;
    }).toList();
  }
}

// Team Issues notifier provider
class TeamIssuesNotifier extends StateNotifier<TeamIssuesState> {
  final ApiService _apiService;

  TeamIssuesNotifier(this._apiService) : super(TeamIssuesState());

  Future<void> fetchIssues() async {
    state = state.copyWith(status: TeamIssuesStateStatus.loading);
    
    try {
      final response = await _apiService.get('/team/issues');
      final List<dynamic> issuesJson = response.data['data'];
      final issues = issuesJson.map((json) => Issue.fromJson(json)).toList();
      
      state = state.copyWith(
        status: TeamIssuesStateStatus.success,
        issues: issues,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: TeamIssuesStateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatusFilter(String status) {
    state = state.copyWith(statusFilter: status);
  }

  void setPriorityFilter(String priority) {
    state = state.copyWith(priorityFilter: priority);
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      statusFilter: '',
      priorityFilter: '',
    );
  }

  Future<void> updateIssueStatus(String issueId, String newStatus) async {
    try {
      await _apiService.put(
        '/team/issues/$issueId/status',
        data: {'status': newStatus},
      );
      // Refresh the issues list after updating
      await fetchIssues();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to update issue status: ${e.toString()}',
      );
    }
  }

  
}

// Team Issues provider
final teamIssuesProvider = StateNotifierProvider<TeamIssuesNotifier, TeamIssuesState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TeamIssuesNotifier(apiService);
});

// Filtered team issues provider
final filteredTeamIssuesProvider = Provider<List<Issue>>((ref) {
  final issuesState = ref.watch(teamIssuesProvider);
  return issuesState.filteredIssues;
});