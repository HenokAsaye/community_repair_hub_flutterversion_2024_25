import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../config/routes/app_router.dart';
import '../../../../../shared/models/report.dart'; // Corrected Issue model import
import '../../providers/citizen_dashboard_provider.dart';
import '../../../../../core/network/api_service_provider.dart';

class RepairTeamDetailScreen extends ConsumerStatefulWidget {
  final Issue issue;

  const RepairTeamDetailScreen({super.key, required this.issue});

  @override
  ConsumerState<RepairTeamDetailScreen> createState() => _RepairTeamDetailScreenState();
}

class _RepairTeamDetailScreenState extends ConsumerState<RepairTeamDetailScreen> {
  late Issue _displayedIssue;
  bool _issueWasUpdated = false;

  @override
  void initState() {
    super.initState();
    _displayedIssue = widget.issue;
  }

  Future<void> _refreshIssueDetails() async {
    try {
      final apiClient = ref.read(citizenApiClientProvider);
      final freshIssue = await apiClient.getIssueById(widget.issue.id!); // Assuming id is non-null for an existing issue
      if (mounted) {
        setState(() {
          _displayedIssue = freshIssue;
        });
      }
    } catch (e) {
      print("Error refreshing issue details: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not refresh issue details: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _buildSimpleImageUrl(String imageUrl) {
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


  Widget _buildImagePlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('No Image Available', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _issueWasUpdated),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Issue Image
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _displayedIssue.imageURL.isNotEmpty
                          ? Image.network(
                              _buildSimpleImageUrl(_displayedIssue.imageURL),
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                            )
                          : _buildImagePlaceholder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Issue Title
                  Text(
                    _displayedIssue.category, // Using category as title
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Status and Priority
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _displayedIssue.status.toUpperCase(),
                      style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${_displayedIssue.locations.city}, ${_displayedIssue.locations.specificArea}", // Combining city and specific area
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_displayedIssue.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),

                  // Extra padding at bottom for the floating button
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Take Issue Button
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  // Convert the team Issue to a Map for the update status screen
                  final issueMap = <String, dynamic>{
                    '_id': _displayedIssue.id, 
                    'id': _displayedIssue.id,  
                    'title': _displayedIssue.category, // Using category as title for the map
                    'description': _displayedIssue.description,
                    'location': "${_displayedIssue.locations.city}, ${_displayedIssue.locations.specificArea}", // Passing combined location string
                    'status': _displayedIssue.status,
                    // 'priority': _displayedIssue.priority, // Priority field doesn't exist in new model
                    'imageUrl': _displayedIssue.imageURL,
                  };
                  
                  print('Navigating to update status with issue: $issueMap');
                  
                  try {
                    final result = await context.push(AppRoutes.updateStatus, extra: issueMap);
                    if (result == true && mounted) {
                      setState(() {
                        _issueWasUpdated = true;
                      });
                      await _refreshIssueDetails(); // Refresh the details on this screen
                    }
                  } catch (e) {
                    print('Navigation error or error during update process: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error navigating or updating: ${e.toString()}'), backgroundColor: Colors.red),
                      );
                    }
                    // Fallback navigation if go_router fails or other error during push
                    // Consider if this fallback is still needed or if the error should be handled differently
                    /* Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UpdateStatusScreen(issue: issueMap),
                      ),
                    ); */
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Take Issue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
