import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../../../shared/models/report.dart';
import '../../data/citizen_api_client.dart';
import '../../data/mock_data.dart';

// API Service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  // Use localhost since it was working before
  const serverPort = '5500';
  
  // Determine the correct base URL based on the platform
  String baseUrl;
  
  // Check if we're running on web
  if (kIsWeb) {
    // For web, use the current origin
    baseUrl = 'http://localhost:$serverPort';
  } else {
    // For physical devices, use your computer's actual IP address
    // This is your Wi-Fi IP address from ipconfig
    baseUrl = 'http://192.168.209.57:$serverPort';
    
    // For Android emulator, you can use 10.0.2.2 which is a special alias
    // baseUrl = 'http://10.0.2.2:$serverPort';
  }
  
  // For debugging purposes only
  print('Using API base URL: $baseUrl');
  
  // Return the API service with the appropriate URL
  return ApiService(baseUrl: baseUrl);
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
  final ApiService _apiService;

  IssuesNotifier(this._apiClient, this._apiService) : super(IssuesState());

  Future<void> fetchIssues() async {
    state = state.copyWith(status: IssuesStateStatus.loading);
    
    try {
      // Log the base URL
      print('Attempting to fetch issues from API at ${_apiService.baseUrl}');
      
      // Fetch issues from the API
      print('Calling getIssues() method...');
      final issues = await _apiClient.getIssues();
      
      if (issues.isEmpty) {
        print('API returned empty issues list');
        print('WARNING: Using mock data instead of real data');
        final mockIssues = MockDataProvider.getMockIssues();
        state = state.copyWith(
          status: IssuesStateStatus.success,
          issues: mockIssues,
          errorMessage: 'No data from server - using mock data',
        );
      } else {
        print('API returned ${issues.length} issues');
        print('First issue: ${issues.isNotEmpty ? issues.first.category : "none"}');
        state = state.copyWith(
          status: IssuesStateStatus.success,
          issues: issues,
          errorMessage: null,
        );
      }
    } catch (e) {
      print('Error fetching issues: $e');
      print('ERROR DETAILS: ${e.toString()}');
      print('WARNING: Using mock data as fallback due to error');
      final mockIssues = MockDataProvider.getMockIssues();
      state = state.copyWith(
        status: IssuesStateStatus.error,
        issues: mockIssues,
        errorMessage: 'Connection error: ${e.toString()}',
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
  final apiService = ref.watch(apiServiceProvider);
  return IssuesNotifier(apiClient, apiService);
});

// Filtered issues provider
final filteredIssuesProvider = Provider<List<Issue>>((ref) {
  final issuesState = ref.watch(issuesProvider);
  return issuesState.filteredIssues;
});