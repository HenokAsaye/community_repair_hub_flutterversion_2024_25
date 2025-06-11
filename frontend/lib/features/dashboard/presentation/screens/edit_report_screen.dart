import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditReportScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> report;

  const EditReportScreen({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  ConsumerState<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends ConsumerState<EditReportScreen> {
  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  String _status = 'Pending';
  
  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _titleController = TextEditingController(text: widget.report['title']?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.report['description']?.toString() ?? '');
    _locationController = TextEditingController(text: widget.report['location']?.toString() ?? '');
    _status = widget.report['status']?.toString() ?? 'Pending';
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Report'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report image preview
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: widget.report['imageUrl'] != null
                    ? DecorationImage(
                        image: NetworkImage(widget.report['imageUrl'].toString()),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.report['imageUrl'] == null
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
            const SizedBox(height: 24),
            
            // Title field
            const Text(
              'Title',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter report title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            
            // Location field
            const Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Enter location',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),
            
            // Description field
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter report description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            
            // Status dropdown
            const Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _status,
                  items: ['Pending', 'In Progress', 'Completed']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement save functionality
                  // This would typically update the report in the backend
                  // For now, just return the updated data to the previous screen
                  final updatedReport = {
                    ...widget.report,
                    'title': _titleController.text,
                    'description': _descriptionController.text,
                    'location': _locationController.text,
                    'status': _status,
                  };
                  
                  Navigator.of(context).pop(updatedReport);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Changes',
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
}
