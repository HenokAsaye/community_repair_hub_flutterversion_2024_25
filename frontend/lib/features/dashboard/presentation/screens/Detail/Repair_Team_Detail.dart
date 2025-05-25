import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RepairTeamDetailScreen extends StatelessWidget {
  final Map<String, dynamic> report;

  const RepairTeamDetailScreen({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                        image: NetworkImage(report['imageUrl']),
                        fit: BoxFit.cover,
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
                  _buildStatusChip(report['status']),
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
                report['title'] ?? 'Untitled Report',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Report Location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    report['location'] ?? 'Location not specified',
                    style: const TextStyle(color: Colors.grey),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(
                report['description'] ?? 'No description provided.',
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            
            // Status Updates Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(
                'Status Updates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Status Update Items
            _buildStatusUpdateItem(
              status: 'Reported',
              date: 'May 10, 2023',
              description: 'Issue has been reported and is under review.',
              isFirst: true,
              isLast: false,
              isCompleted: true,
            ),
            _buildStatusUpdateItem(
              status: 'In Progress',
              date: 'May 12, 2023',
              description: 'A technician has been assigned to investigate the issue.',
              isFirst: false,
              isLast: false,
              isCompleted: true,
            ),
            _buildStatusUpdateItem(
              status: 'Completed',
              date: 'May 15, 2023',
              description: 'The pothole has been filled and the issue is now resolved.',
              isFirst: false,
              isLast: true,
              isCompleted: true,
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Chat Button
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Handle chat
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                label: Text(
                  'Chat',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Mark as Resolved Button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  // Handle mark as resolved
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Mark as Resolved',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color statusColor;
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
      default:
        statusColor = Colors.grey;
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
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
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
          // Timeline
          Column(
            children: [
              // Top line (only if not first)
              if (!isFirst)
                Container(
                  width: 2,
                  height: 16,
                  color: isCompleted ? Colors.green : Colors.grey[300],
                ),
              // Dot
              Container(
                width: 14,
                height: 14,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.grey[300],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
              // Bottom line (only if not last)
              if (!isLast)
                Container(
                  width: 2,
                  height: 60, // Adjust based on content
                  color: isCompleted ? Colors.green : Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
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
