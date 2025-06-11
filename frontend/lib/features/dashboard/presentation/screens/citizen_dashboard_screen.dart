import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/dashboard_drawer.dart';
import '../widgets/dashboard_filter.dart';
import '../widgets/citizen_report_card.dart';
import '../providers/citizen_dashboard_provider.dart';
import 'Detail/Citizen_Detail.dart';
import '../../../../features/reports/presentation/screens/report_form_screen.dart';


class CitizenDashboard extends ConsumerStatefulWidget {
  const CitizenDashboard({super.key});

  @override
  ConsumerState<CitizenDashboard> createState() => _CitizenDashboardState();
}

class _CitizenDashboardState extends ConsumerState<CitizenDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  IssueStatus _selectedStatus = IssueStatus.all;

  @override
  void initState() {
    super.initState();
    // Fetch issues when the screen loads
    print('CitizenDashboard initState called - fetching issues');
    
    // Use a slight delay to ensure the widget is fully mounted
    Future.delayed(Duration.zero, () {
      print('Fetching issues from backend');
      ref.read(issuesProvider.notifier).fetchIssues();
    });
  }

  void _onViewReportDetails(String? reportId) {
    if (reportId == null) return;
    
    // Find the issue in the list
    final issues = ref.read(filteredIssuesProvider);
    final issue = issues.firstWhere(
      (issue) => issue.id == reportId,
      orElse: () => throw Exception('Issue not found'),
    );
    
    // Create a map with the report data for the detail screen
    final reportData = {
      'imageUrl': issue.imageURL.startsWith('http') 
          ? issue.imageURL 
          : 'http://192.168.100.10:5500${issue.imageURL}',
      'title': issue.category,
      'location': '${issue.locations.city}, ${issue.locations.specificArea}',
      'status': issue.status.toLowerCase(),
      'date': issue.createdAt,
      'description': issue.description,
    };
    
    // Navigate to the detail screen using direct navigation
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => CitizenDetailScreen(report: reportData),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    print('Building dashboard screen');


    
    return Scaffold(
      key: _scaffoldKey,
      appBar: DashboardAppBar(
        title: 'Community Repair Hub',
        isRepairTeam: false,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        onProfilePressed: () {
          // Navigate to profile screen
          // Navigator.push(context, MaterialPageRoute(
          //   builder: (context) => ProfileScreen(),
          // ));
        },
      ),
      drawer: const DashboardDrawer(userRole: 'citizen'),
      body: Column(
        children: [
          // Search and Filter Bar
          DashboardFilter(
            searchQuery: _searchQuery,
            selectedStatus: _selectedStatus,
            onSearchChanged: (query) {
              setState(() => _searchQuery = query);
              ref.read(issuesProvider.notifier).setSearchQuery(query);
            },
            onStatusChanged: (status) {
              setState(() => _selectedStatus = status);
              // Map IssueStatus enum to backend status string if needed
              String statusFilter = '';
              if (status != IssueStatus.all) {
                statusFilter = status.toString().split('.').last;
              }
              ref.read(issuesProvider.notifier).setCategoryFilter(statusFilter);
            },
          ),
          
          // Filter indicator
          if (_selectedStatus != IssueStatus.all || _searchQuery.isNotEmpty)
            Consumer(builder: (context, ref, child) {
              final filteredIssues = ref.watch(filteredIssuesProvider);
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
                        ref.read(issuesProvider.notifier).clearFilters();
                      },
                      child: const Text('Clear all', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              );
            }),
          
          // Reports List
          Expanded(
            child: Consumer(builder: (context, ref, child) {
              final issuesState = ref.watch(issuesProvider);
              final filteredIssues = ref.watch(filteredIssuesProvider);
              
              print('Issues state status: ${issuesState.status}');
              print('Filtered issues count: ${filteredIssues.length}');
              
              // Show loading indicator
              if (issuesState.status == IssuesStateStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              // Show error message
              if (issuesState.status == IssuesStateStatus.error) {
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
                        onPressed: () => ref.read(issuesProvider.notifier).fetchIssues(),
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
                              ref.read(issuesProvider.notifier).clearFilters();
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
                  print('Building card for issue: ${issue.category}');
                  return CitizenReportCard(
                    title: issue.category,
                    location: '${issue.locations.city}, ${issue.locations.specificArea}',
                    status: issue.status.toLowerCase(),
                    date: issue.createdAt,
                    imageUrl: issue.imageURL,
                    onViewPressed: () => _onViewReportDetails(issue.id),
                    showChatButton: issue.status.toLowerCase() != 'resolved',
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to report form screen
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => const ReportFormScreen(),
            ),
          ).then((_) {
            // Refresh issues list when returning from report form screen
            ref.read(issuesProvider.notifier).fetchIssues();
          });
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}