// Team Dashboard Screen 

import 'package:flutter/material.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/dashboard_drawer.dart';
import '../widgets/dashboard_filter.dart';
import '../widgets/team_report_card.dart';

class RepairTeamDashboard extends StatefulWidget {
  const RepairTeamDashboard({super.key});

  @override
  State<RepairTeamDashboard> createState() => _RepairTeamDashboardState();
}

class _RepairTeamDashboardState extends State<RepairTeamDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  IssueStatus _selectedStatus = IssueStatus.all;

  // Sample data - replace with your actual data source
  final List<Map<String, dynamic>> _reports = [
    {
      'id': '1',
      'title': 'Pothole on Main Street',
      'description': 'Large pothole causing traffic issues and potential damage to vehicles. Needs immediate attention.',
      'status': 'pending',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'location': 'Main Street, Downtown',
      'imageUrl': null, // No image for this report
      'priority': 'High',
    },
    {
      'id': '2',
      'title': 'Broken Street Light',
      'description': 'Street light not working for 3 days, making the area unsafe at night.',
      'status': 'in progress',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'location': 'Oak Avenue, Near Central Park',
      'imageUrl': 'https://example.com/streetlight.jpg',
      'priority': 'Medium',
    },
    {
      'id': '3',
      'title': 'Garbage Pile-up',
      'description': 'Garbage has been piling up for over a week, causing bad odor and attracting pests.',
      'status': 'completed',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'location': 'Elm Street, Block 4',
      'imageUrl': 'https://example.com/garbage.jpg',
      'priority': 'Low',
    },
  ];

  List<Map<String, dynamic>> get _filteredReports {
    return _reports.where((report) {
      final searchLower = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          report['title'].toLowerCase().contains(searchLower) ||
          report['description'].toLowerCase().contains(searchLower) ||
          report['location'].toLowerCase().contains(searchLower);

      final matchesStatus = _selectedStatus == IssueStatus.all ||
          report['status'] == _selectedStatus.toString().split('.').last;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _onViewReportDetails(String reportId) {
    // Navigate to report details screen
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (context) => ReportDetailsScreen(reportId: reportId),
    // ));
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
      drawer: const DashboardDrawer(),
      body: Column(
        children: [
          // Search and Filter Bar
          DashboardFilter(
            searchQuery: _searchQuery,
            selectedStatus: _selectedStatus,
            onSearchChanged: (query) {
              setState(() => _searchQuery = query);
            },
            onStatusChanged: (status) {
              setState(() => _selectedStatus = status);
            },
          ),
          
          // Filter indicator
          if (_selectedStatus != IssueStatus.all || _searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              color: Colors.grey[100],
              child: Row(
                children: [
                  Text(
                    'Showing ${_filteredReports.length} ${_filteredReports.length == 1 ? 'result' : 'results'}\n',
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
                      },
                      child: const Text('Clear all', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ),
          
          // Reports List
          Expanded(
            child: _filteredReports.isEmpty
                ? Center(
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
                              },
                              child: const Text('Clear filters'),
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: _filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = _filteredReports[index];
                      return TeamReportCard(
                        title: report['title'],
                        location: report['location'],
                        status: report['status'],
                        date: report['date'],
                        priority: report['priority'],
                        imageUrl: report['imageUrl'],
                        onViewPressed: () => _onViewReportDetails(report['id']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}