import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/dashboard/presentation/providers/citizen_dashboard_provider.dart';
import '../../../../core/network/api_service_provider.dart';

class UpdateStatusScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> issue;

  const UpdateStatusScreen({Key? key, required this.issue}) : super(key: key);

  @override
  ConsumerState<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends ConsumerState<UpdateStatusScreen> {
  // Issue details
  late String _issueId;
  late String _issueTitle;
  late String _issueDescription;
  late String _issueLocation;
  late String _currentStatus;
  late String _imageUrl;
  
  // Form state
  String _selectedStatus = '';
  String _additionalNotes = '';
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    // Debug the issue data received
    print('Received issue data in UpdateStatusScreen: ${widget.issue}');
    
    // Initialize issue details from the passed map
    // Check for both 'id' and '_id' as MongoDB often uses '_id'
    _issueId = widget.issue['_id'] ?? widget.issue['id'] ?? '';
    _issueTitle = widget.issue['title'] ?? 'Unknown Issue';
    _issueDescription = widget.issue['description'] ?? 'No description available';
    _issueLocation = widget.issue['location'] ?? 'Unknown location';
    _currentStatus = widget.issue['status'] ?? 'pending';
    _imageUrl = widget.issue['imageUrl'] ?? '';
    
    print('Extracted issue ID: $_issueId');
    
    // Set initial selected status based on current status if not empty
    if (_currentStatus.isNotEmpty) {
      _selectedStatus = _currentStatus;
    }
  }

  void _updateStatus() async {
    setState(() {
      _isLoading = true;
      _isSuccess = false;
      _errorMessage = null;
    });

    try {
      if (_issueId.isEmpty) {
        throw Exception('Issue ID is empty or invalid. Cannot update status.');
      }

      final apiClient = ref.read(citizenApiClientProvider);

      print('Attempting to update issue status for ID: $_issueId with status: $_selectedStatus and notes: $_additionalNotes');

      // Call the new method in CitizenApiClient
      final updatedIssue = await apiClient.updateIssueStatus(
        issueId: _issueId,
        status: _selectedStatus,
        notes: _additionalNotes,
      );

      print('Successfully updated issue: ${updatedIssue.id}');

      setState(() {
        _isSuccess = true;
        _isLoading = false;
        _currentStatus = updatedIssue.status; // Update current status locally if needed
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${_selectedStatus} successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Pop screen after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop(true); // Pass true to indicate success
        }
      });

    } catch (e) {
      print('Error updating status in UI: $e');
      String displayError = e.toString();
      // Refine error message
      if (e is Exception) {
        final message = e.toString();
        if (message.startsWith('Exception: ')) {
          displayError = message.substring('Exception: '.length);
        }
      }
      setState(() {
        _isLoading = false;
        _errorMessage = displayError;
      });
    } finally {
      // Ensure isLoading is set to false if it's still true
      if (_isLoading) {
         setState(() { _isLoading = false; });
      }
    }
  }

  // Helper method to build the issue summary card
  Widget _buildIssueSummaryCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Issue image
                // Image handling with better error fallback
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _imageUrl.isNotEmpty
                    ? Image.network(
                        _imageUrl.startsWith('http') 
                            ? _imageUrl 
                            : '${ref.read(apiServiceProvider).baseUrl}/uploads/${_imageUrl.split('/').last}',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Image error: $error for URL: $_imageUrl');
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 40),
                          );
                        },
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 40),
                      ),
                ),
                const SizedBox(width: 16),
                // Issue details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _issueTitle,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _issueLocation,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_currentStatus),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _currentStatus,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_issueDescription.isNotEmpty) ...[  
              const SizedBox(height: 16),
              const Text(
                'Description:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _issueDescription,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Helper method to get color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'fixed':
        return Colors.green[700]!;
      case 'in progress':
        return Colors.orange[700]!;
      case 'pending':
        return Colors.blue[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Issue Status', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFF7CFC00),
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Issue summary card
                  _buildIssueSummaryCard(),
                  // Status selection section
                  const Text(
                    'Update Issue Status',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select the new status for this issue:',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  
                  // Status options
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Column(
                      children: [
                        // Fixed option
                        RadioListTile<String>(
                          value: 'Fixed',
                          groupValue: _selectedStatus,
                          onChanged: (val) => setState(() => _selectedStatus = val!),
                          activeColor: Colors.green[700],
                          title: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              const Text('Fixed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          subtitle: const Text('The issue has been completely resolved', style: TextStyle(fontSize: 14)),
                          selected: _selectedStatus == 'Fixed',
                          selectedTileColor: Colors.green[50],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        
                        // In Progress option
                        RadioListTile<String>(
                          value: 'In Progress',
                          groupValue: _selectedStatus,
                          onChanged: (val) => setState(() => _selectedStatus = val!),
                          activeColor: Colors.orange[700],
                          title: Row(
                            children: [
                              Icon(Icons.engineering, color: Colors.orange[700]),
                              const SizedBox(width: 8),
                              const Text('In Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          subtitle: const Text('We are actively working on this issue', style: TextStyle(fontSize: 14)),
                          selected: _selectedStatus == 'In Progress',
                          selectedTileColor: Colors.orange[50],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        
                        // Pending option
                        RadioListTile<String>(
                          value: 'Pending',
                          groupValue: _selectedStatus,
                          onChanged: (val) => setState(() => _selectedStatus = val!),
                          activeColor: Colors.blue[700],
                          title: Row(
                            children: [
                              Icon(Icons.pending_actions, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              const Text('Pending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          subtitle: const Text('Issue is waiting to be addressed', style: TextStyle(fontSize: 14)),
                          selected: _selectedStatus == 'Pending',
                          selectedTileColor: Colors.blue[50],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Notes section
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.note_alt, color: Color(0xFF006E2E)),
                              const SizedBox(width: 8),
                              const Text('Additional Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            minLines: 4,
                            maxLines: 8,
                            decoration: InputDecoration(
                              hintText: 'Add details about the repair work or current status...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            onChanged: (val) => setState(() => _additionalNotes = val),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Error message if any
                  if (_errorMessage != null) ...[  
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Error: $_errorMessage',
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Update button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _selectedStatus.isEmpty ? null : _updateStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006E2E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.update),
                          const SizedBox(width: 8),
                          Text(
                            _isSuccess ? 'Updated Successfully!' : 'Update Status',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ),
      );
  }
}