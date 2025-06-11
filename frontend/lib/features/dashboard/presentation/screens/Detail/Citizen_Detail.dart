import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// Citizen API client is used via the provider
import '../../../../../shared/models/report.dart';

import '../../../../../core/network/api_service_provider.dart';


// Provider for fetching a single issue
final issueDetailProvider = FutureProvider.family<Issue, String>((ref, id) async {
  final apiService = ref.read(apiServiceProvider);
  final response = await apiService.get('/citizens/issues/$id');
  // Assuming the issue is nested under a 'data' key
  return Issue.fromJson(response.data['data']);
});

class CitizenDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? report;

  const CitizenDetailScreen({
    Key? key,
    this.report,
  }) : super(key: key);

  @override
  ConsumerState<CitizenDetailScreen> createState() => _CitizenDetailScreenState();
}

class _CitizenDetailScreenState extends ConsumerState<CitizenDetailScreen> {
  String? issueId;

  @override
  void initState() {
    super.initState();
    issueId = widget.report?['id'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    print('Building CitizenDetailScreen with issueId: $issueId');
    if (issueId != null && issueId!.isNotEmpty) {
      print('Watching issueDetailProvider for ID: $issueId');
      return ref.watch(issueDetailProvider(issueId!)).when(
        data: (issue) => _buildDetailScreen(context, issue),
        loading: () => Scaffold(
          appBar: AppBar(
            title: const Text('Report Details'),
            centerTitle: true,
            elevation: 0,
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading report details...'),
              ],
            ),
          ),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(
            title: const Text('Report Details'),
            centerTitle: true,
            elevation: 0,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${error.toString()}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(issueDetailProvider(issueId!)),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return _buildDetailScreenFromMap(context);
    }
  }

  Widget _buildDetailScreen(BuildContext context, Issue issue) {
    print('Building detail screen for issue:');
    print('  ID: ${issue.id}');
    print('  Category: ${issue.category}');
    print('  Image URL: ${issue.imageURL}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: issue.imageURL.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_camera_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No Image Available', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : Image.network(
                      _buildSimpleImageUrl(ref, issue.imageURL),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / 
                                  loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red),
                              SizedBox(height: 8),
                              Text('Error Loading Image', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            // Report Status and Date
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildStatusChip(issue.status),
                  const Spacer(),
                  Text(
                    DateFormat('MMM d, y').format(issue.createdAt),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Report Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                issue.category,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            // Report Location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${issue.locations.city}, ${issue.locations.specificArea}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Divider(height: 1, thickness: 1),
            ),
            // Report Description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(issue.description),
                ],
              ),
            ),
            // Status Updates Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(
                'Status Updates',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Status Update Items
            _buildStatusUpdateItem(
              status: 'Reported',
              date: DateFormat('MMM d, y').format(issue.createdAt),
              description: 'Issue has been reported and is under review.',
              isFirst: true,
              isLast: issue.status.toLowerCase() == 'pending',
              isCompleted: true,
            ),
            if (issue.status.toLowerCase() == 'in progress' ||
                issue.status.toLowerCase() == 'completed')
              _buildStatusUpdateItem(
                status: 'In Progress',
                date: DateFormat('MMM d, y').format(issue.updatedAt),
                description: 'A technician has been assigned to investigate the issue.',
                isFirst: false,
                isLast: issue.status.toLowerCase() == 'in progress',
                isCompleted: true,
              ),
            if (issue.status.toLowerCase() == 'completed')
              _buildStatusUpdateItem(
                status: 'Completed',
                date: DateFormat('MMM d, y').format(issue.updatedAt),
                description: 'The issue has been resolved.',
                isFirst: false,
                isLast: true,
                isCompleted: true,
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailScreenFromMap(BuildContext context) {
    final report = widget.report ?? {};
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                image: report['imageUrl'] != null
                  ? DecorationImage(
                      image: NetworkImage(
                        (report['imageUrl'] as String).startsWith('http')
                            ? (report['imageUrl'] as String)
                            : '${ref.read(apiServiceProvider).baseUrl}/${report['imageUrl']}'
                      ),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        print('Error loading image: $exception');
                        return null;
                      },
                    )
                  : null,
              ),
              child: report['imageUrl'] == null
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_camera_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No Image Available', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : null,
            ),
            // Report Status and Date
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildStatusChip(report['status']?.toString() ?? 'Pending'),
                  const Spacer(),
                  Text(
                    DateFormat('MMM d, y').format(report['date'] ?? DateTime.now()),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Report Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                report['title']?.toString() ?? 'Untitled Report',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            // Report Location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      (report['location']?.toString() ?? 'Location not specified'),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Divider(height: 1, thickness: 1),
            ),
            // Report Description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(report['description']?.toString() ?? 'No description provided.'),
                ],
              ),
            ),
            // Status Updates Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(
                'Status Updates',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Status Update Items
            _buildStatusUpdateItem(
              status: 'Reported',
              date: DateFormat('MMM d, y').format(report['date'] ?? DateTime.now()),
              description: 'Issue has been reported and is under review.',
              isFirst: true,
              isLast: (report['status']?.toString().toLowerCase() ?? 'pending') == 'pending',
              isCompleted: true,
            ),
            if ((report['status']?.toString().toLowerCase() ?? 'pending') == 'in progress' ||
                (report['status']?.toString().toLowerCase() ?? 'pending') == 'completed')
              _buildStatusUpdateItem(
                status: 'In Progress',
                date: DateFormat('MMM d, y').format(report['date'] ?? DateTime.now()),
                description: 'A technician has been assigned to investigate the issue.',
                isFirst: false,
                isLast: (report['status']?.toString().toLowerCase() ?? 'pending') == 'in progress',
                isCompleted: true,
              ),
            if ((report['status']?.toString().toLowerCase() ?? 'pending') == 'completed')
              _buildStatusUpdateItem(
                status: 'Completed',
                date: DateFormat('MMM d, y').format(report['date'] ?? DateTime.now()),
                description: 'The issue has been resolved.',
                isFirst: false,
                isLast: true,
                isCompleted: true,
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // Removed Edit Report button as it's not a function for citizens
    );
  }

  // Simple helper method to build image URLs directly
  String _buildSimpleImageUrl(WidgetRef ref, String imageUrl) {
    final baseUrl = ref.read(apiServiceProvider).baseUrl;
    
    // Handle empty URL
    if (imageUrl.isEmpty) return '';
    
    // If already a full URL, return as is
    if (imageUrl.startsWith('http')) return imageUrl;
    
    // Get just the filename
    final filename = imageUrl.split('/').last;
    
    // Construct direct URL to the image
    final fullUrl = '$baseUrl/uploads/$filename';
    
    print('Image URL: $fullUrl');
    return fullUrl;
  }

  Widget _buildStatusChip(String status) {
    Color statusColor = Colors.grey;
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'in progress':
        statusColor = Colors.blue;
        break;
      case 'completed':
        statusColor = Colors.green;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateItem({
    required String status,
    required String date,
    required String description,
    required bool isFirst,
    required bool isLast,
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              if (!isFirst)
                Container(width: 2, height: 16, color: isCompleted ? Colors.green : Colors.grey[300]),
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.grey[300],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              if (!isLast)
                Container(width: 2, height: 60, color: isCompleted ? Colors.green : Colors.grey[300]),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: isCompleted ? Colors.black87 : Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}