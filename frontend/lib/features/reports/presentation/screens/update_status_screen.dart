import 'package:flutter/material.dart';

class UpdateStatusScreen extends StatefulWidget {
  const UpdateStatusScreen({Key? key}) : super(key: key);

  @override
  State<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends State<UpdateStatusScreen> {
  String _selectedStatus = '';
  String _additionalNotes = '';
  bool _isLoading = false;

  void _updateStatus() async {
    setState(() { _isLoading = true; });
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _isLoading = false; });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Status updated successfully!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Issue Status', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFF7CFC00),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Issue Status',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: ListTile(
                leading: Radio<String>(
                  value: 'Fixed',
                  groupValue: _selectedStatus,
                  onChanged: (val) => setState(() => _selectedStatus = val!),
                  activeColor: const Color(0xFF006E2E),
                ),
                title: const Text('Fixed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: const Text('The issue has been resolved', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: ListTile(
                leading: Radio<String>(
                  value: 'In Progress',
                  groupValue: _selectedStatus,
                  onChanged: (val) => setState(() => _selectedStatus = val!),
                  activeColor: const Color(0xFF006E2E),
                ),
                title: const Text('In Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: const Text("We're working on fixing this issue", style: TextStyle(fontSize: 18, color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: const Color(0xFFEAEAEA),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Additional Notes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      minLines: 5,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        hintText: 'Add any details about the repair work...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => setState(() => _additionalNotes = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading || _selectedStatus.isEmpty ? null : _updateStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7CFC00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Update Status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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