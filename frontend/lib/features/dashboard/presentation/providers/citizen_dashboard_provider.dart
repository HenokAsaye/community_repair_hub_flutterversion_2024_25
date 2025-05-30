import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../../../shared/models/report.dart';
import '../../data/citizen_api_client.dart';
import '../../data/mock_data.dart';

// API Service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  // For web testing (Chrome) - ensure this matches your backend server port
  return ApiService(baseUrl: 'http://localhost:5500');
});

// Citizen API Client provider
final citizenApiClientProvider = Provider<CitizenApiClient>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CitizenApiClient(apiService);
});

// Issues state
enum IssuesStateStatus { initial, loading, success, error }

class IssuesState {
  final IssuesStateStatus status;
  final List<Issue> issues;
  final String? errorMessage;
  final String? searchQuery;
  final String? categoryFilter;
  final String? locationFilter;

  IssuesState({
    this.status = IssuesStateStatus.initial,
    this.issues = const [],
    this.errorMessage,
    this.searchQuery,
    this.categoryFilter,
    this.locationFilter,
  });

  IssuesState copyWith({
    IssuesStateStatus? status,
    List<Issue>? issues,
    String? errorMessage,
    String? searchQuery,
    String? categoryFilter,
    String? locationFilter,
  }) {
    return IssuesState(
      status: status ?? this.status,
      issues: issues ?? this.issues,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      locationFilter: locationFilter ?? this.locationFilter,
    );
  }

  List<Issue> get filteredIssues {
    if ((searchQuery == null || searchQuery!.isEmpty) && 
        (categoryFilter == null || categoryFilter!.isEmpty) && 
        (locationFilter == null || locationFilter!.isEmpty)) {
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

      // Apply category filter
      if (categoryFilter != null && categoryFilter!.isNotEmpty) {
        if (!issue.category.toLowerCase().contains(categoryFilter!.toLowerCase())) {
          return false;
        }
      }

      // Apply location filter
      if (locationFilter != null && locationFilter!.isNotEmpty) {
        if (!issue.locations.city.toLowerCase().contains(locationFilter!.toLowerCase()) &&
            !issue.locations.specificArea.toLowerCase().contains(locationFilter!.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}

// Issues notifier provider
class IssuesNotifier extends StateNotifier<IssuesState> {
  final CitizenApiClient _apiClient;

  IssuesNotifier(this._apiClient) : super(IssuesState());

  Future<void> fetchIssues() async {
    state = state.copyWith(status: IssuesStateStatus.loading);
    
    try {
      print('Attempting to fetch issues from API');
      final issues = await _apiClient.getIssues();
      
      if (issues.isEmpty) {
        print('API returned empty issues list, using mock data instead');
        final mockIssues = MockDataProvider.getMockIssues();
        state = state.copyWith(
          status: IssuesStateStatus.success,
          issues: mockIssues,
          errorMessage: null,
        );
      } else {
        print('API returned ${issues.length} issues');
        state = state.copyWith(
          status: IssuesStateStatus.success,
          issues: issues,
          errorMessage: null,
        );
      }
    } catch (e) {
      print('Error fetching issues: $e');
      print('Using mock data as fallback');
      final mockIssues = MockDataProvider.getMockIssues();
      state = state.copyWith(
        status: IssuesStateStatus.success,
        issues: mockIssues,
        errorMessage: null,
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoryFilter(String category) {
    state = state.copyWith(categoryFilter: category);
  }

  void setLocationFilter(String location) {
    state = state.copyWith(locationFilter: location);
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      categoryFilter: '',
      locationFilter: '',
    );
  }

  Future<void> searchByCategory(String category) async {
    state = state.copyWith(status: IssuesStateStatus.loading);
    
    try {
      final issues = await _apiClient.searchByCategory(category);
      
      state = state.copyWith(
        status: IssuesStateStatus.success,
        issues: issues,
        errorMessage: null,
        categoryFilter: category,
      );
    } catch (e) {
      state = state.copyWith(
        status: IssuesStateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> searchByLocation(String location) async {
    state = state.copyWith(status: IssuesStateStatus.loading);
    
    try {
      final issues = await _apiClient.searchByLocation(location);
      
      state = state.copyWith(
        status: IssuesStateStatus.success,
        issues: issues,
        errorMessage: null,
        locationFilter: location,
      );
    } catch (e) {
      state = state.copyWith(
        status: IssuesStateStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

// Issues provider
final issuesProvider = StateNotifierProvider<IssuesNotifier, IssuesState>((ref) {
  final apiClient = ref.watch(citizenApiClientProvider);
  return IssuesNotifier(apiClient);
});

// Filtered issues provider
final filteredIssuesProvider = Provider<List<Issue>>((ref) {
  final issuesState = ref.watch(issuesProvider);
  return issuesState.filteredIssues;
});