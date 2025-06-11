// Team Dashboard Screen 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/dashboard_drawer.dart';
import '../widgets/dashboard_filter.dart';
import '../widgets/team_report_card.dart';
import '../providers/team_dashboard_provider.dart';
import '../../../../../config/routes/app_router.dart'; // For AppRoutes
import 'package:go_router/go_router.dart'; // For context.push

class RepairTeamDashboard extends ConsumerStatefulWidget {
  const RepairTeamDashboard({super.key});

  @override
  ConsumerState<RepairTeamDashboard> createState() => _RepairTeamDashboardState();
}

class _RepairTeamDashboardState extends ConsumerState<RepairTeamDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  IssueStatus _selectedStatus = IssueStatus.all;

  @override
  void initState() {
    super.initState();
    // Fetch issues when the screen loads
    Future.microtask(() => ref.read(teamIssuesProvider.notifier).fetchIssues());
  }

  void _onViewReportDetails(String? reportId) {
    if (reportId == null) return;
    
    // Find the issue with the matching ID
    final issues = ref.read(teamIssuesProvider).issues;
    final issue = issues.firstWhere(
      (issue) => issue.id == reportId,
      orElse: () => throw Exception('Issue not found'),
    );
    
    // Navigate to the Repair Team Detail screen using GoRouter
    if (issue.id == null) {
      print("Error: Issue ID is null, cannot navigate to details.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Cannot view details for an issue with no ID.'), backgroundColor: Colors.red),
      );
      return;
    }
    context.push(AppRoutes.repairTeamReportDetailsPath(issue.id!), extra: issue);
  }

  // Helper method to determine priority based on category
  String getPriorityFromCategory(String category) {
    // This is a simple example - you can customize this logic
    switch (category.toLowerCase()) {
      case 'road':  // Assuming 'road' is a category for potholes, etc.
        return 'High';
      case 'electricity': // For street lights, etc.
        return 'Medium';
      case 'waste': // For garbage issues
        return 'Low';
      default:
        return 'Medium';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: DashboardAppBar(
        title: 'Repair Team Dashboard',
        isRepairTeam: true,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        onProfilePressed: () {
          // Navigate to profile screen
          // Navigator.push(context, MaterialPageRoute(
          //   builder: (context) => ProfileScreen(),
          // ));
        },
      ),
      drawer: const DashboardDrawer(userRole: 'repair_team'),
      body: Column(
        children: [
          // Search and Filter Bar
          DashboardFilter(
            searchQuery: _searchQuery,
            selectedStatus: _selectedStatus,
            onSearchChanged: (query) {
              setState(() => _searchQuery = query);
              ref.read(teamIssuesProvider.notifier).setSearchQuery(query);
            },
            onStatusChanged: (status) {
              setState(() => _selectedStatus = status);
              // Map IssueStatus enum to backend status string if needed
              String statusFilter = '';
              if (status != IssueStatus.all) {
                statusFilter = status.toString().split('.').last;
              }
              ref.read(teamIssuesProvider.notifier).setStatusFilter(statusFilter);
            },
          ),
          
          // Filter indicator
          Consumer(builder: (context, ref, child) {
            final filteredIssues = ref.watch(filteredTeamIssuesProvider);
            
            if (_selectedStatus != IssueStatus.all || _searchQuery.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                width: double.infinity,
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Text(
                      'Showing ${filteredIssues.length} ${filteredIssues.length == 1 ? 'result' : 'results'}\n',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  if (_selectedStatus != IssueStatus.all)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Status: ${_selectedStatus.toString().split('.').last}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => _selectedStatus = IssueStatus.all),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  if (_searchQuery.isNotEmpty || _selectedStatus != IssueStatus.all)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedStatus = IssueStatus.all;
                        });
                        ref.read(teamIssuesProvider.notifier).clearFilters();
                      },
                      child: const Text('Clear all', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          
          // Reports List
          Expanded(
            child: Consumer(builder: (context, ref, child) {
              final issuesState = ref.watch(teamIssuesProvider);
              final filteredIssues = ref.watch(filteredTeamIssuesProvider);
              
              // Show loading indicator
              if (issuesState.status == TeamIssuesStateStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              // Show error message
              if (issuesState.status == TeamIssuesStateStatus.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading issues',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        issuesState.errorMessage ?? 'Unknown error',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(teamIssuesProvider.notifier).fetchIssues(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              
              // Show empty state
              if (filteredIssues.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reports found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty || _selectedStatus != IssueStatus.all)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _selectedStatus = IssueStatus.all;
                              });
                              ref.read(teamIssuesProvider.notifier).clearFilters();
                            },
                            child: const Text('Clear filters'),
                          ),
                        ),
                    ],
                  ),
                );
              }
              
              // Show issues list
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: filteredIssues.length,
                itemBuilder: (context, index) {
                  final issue = filteredIssues[index];
                  return TeamReportCard(
                    title: issue.category,
                    location: '${issue.locations.city}, ${issue.locations.specificArea}',
                    status: issue.status.toLowerCase(),
                    date: issue.createdAt,
                    imageUrl: issue.imageURL, // The TeamReportCard will handle the URL formatting
                    priority: getPriorityFromCategory(issue.category), // Determine priority from category
                    onViewPressed: () => _onViewReportDetails(issue.id),
                    onStatusChanged: (newStatus) {
                      // Update issue status in the backend
                      if (issue.id != null) {
                        ref.read(teamIssuesProvider.notifier).updateIssueStatus(issue.id!, newStatus);
                      }
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Refresh the issues list
          ref.read(teamIssuesProvider.notifier).fetchIssues();
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}