import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/report_form_provider.dart';

class ReportFormScreen extends ConsumerStatefulWidget {
  const ReportFormScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends ConsumerState<ReportFormScreen> {
  File? _imageFile;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  String _category = '';
  String _city = '';
  String _specificAddress = '';
  String _description = '';
  String _date = '';
  bool _isLoading = false;

  final List<String> _cities = [
    "Addis Ababa","Dire Dawa","Bahir Dar","Hawassa","Mekelle","Jimma","Gondar","Adama","Dessie","Harar"
  ];

  final Map<String, List<String>> _citySpecificAreas = {
    "Addis Ababa": ["Bole", "Sarbet", "Summit", "CMC", "Ayat", "Gerji", "CMC", "Saris", "Megenagna", "Merkato"],
    "Dire Dawa": ["Keble 01", "Keble 02", "Keble 03", "Keble 04", "Keble 05", "Industrial Area"],
    "Bahir Dar": ["Tana", "Gish Abay", "Tis Abay", "Lake Side", "University Area", "Central Market"],
    "Hawassa": ["Lake Side", "University Area", "Industrial Zone", "Central Market", "Tabor"],
    "Mekelle": ["Ayder", "Adi Haki", "Industrial Area", "Central Market", "Semien"],
    "Jimma": ["Abay", "Bishoftu", "Central Market", "University Area", "Airport Road"],
    "Gondar": ["Fasil", "Azezo", "Central Market", "University Area", "Maraki"],
    "Adama": ["Central Market", "Industrial Zone", "University Area", "Lake Side", "Airport Road"],
    "Dessie": ["Central Market", "University Area", "Industrial Zone", "Airport Road", "Lake Side"],
    "Harar": ["Jugol", "New Town", "Industrial Zone", "University Area", "Airport Road"]
  };

  Future<void> _pickImage() async {
    try {
      // Use gallery with higher quality and explicitly set image format
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileExtension = pickedFile.path.split('.').last.toLowerCase();
        
        // Verify the file has a valid image extension
        if (!['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a JPG, PNG or GIF image')),
          );
          return;
        }
        
        print('Selected image: ${pickedFile.path}');
        print('File extension: $fileExtension');
        
        setState(() {
          _imageFile = file;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _date = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _submitForm() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;
    
    // Check if image is selected
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image of the issue')),
      );
      return;
    }
    
    // Parse date string to DateTime
    final dateParts = _date.split('/');
    if (dateParts.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid date')),
      );
      return;
    }
    
    final day = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);
    final issueDate = DateTime(year, month, day);
    
    // Show loading indicator
    setState(() { _isLoading = true; });
    
    try {
      // Submit report using the provider
      final success = await ref.read(reportFormProvider.notifier).submitReport(
        category: _category,
        city: _city,
        specificAddress: _specificAddress,
        description: _description,
        issueDate: issueDate,
        imageFile: _imageFile!,
      );
      
      // Hide loading indicator
      setState(() { _isLoading = false; });
      
      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!')),
        );
        
        // Return to previous screen
        Navigator.of(context).pop();
      } else {
        // Show error message from provider state
        final errorMessage = ref.read(reportFormProvider).errorMessage ?? 'Failed to submit report';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // Hide loading indicator
      setState(() { _isLoading = false; });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final specificAreas = _citySpecificAreas[_city] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Issue'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xFF7CFC00),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null
                        ? const Icon(Icons.add, size: 48, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Category (e.g., Road, Electrical)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => setState(() => _category = val),
                validator: (val) => val == null || val.isEmpty ? 'Enter a category' : null,
              ),
              const SizedBox(height: 16),
              const Text('Location', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _city.isNotEmpty ? _city : null,
                decoration: const InputDecoration(
                  labelText: 'Select City',
                  border: OutlineInputBorder(),
                ),
                items: _cities.map((city) => DropdownMenuItem(
                  value: city,
                  child: Text(city),
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    _city = val!;
                    _specificAddress = '';
                  });
                },
                validator: (val) => val == null || val.isEmpty ? 'Select a city' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _specificAddress.isNotEmpty ? _specificAddress : null,
                decoration: const InputDecoration(
                  labelText: 'Select Address',
                  border: OutlineInputBorder(),
                ),
                items: specificAreas.map((area) => DropdownMenuItem(
                  value: area,
                  child: Text(area),
                )).toList(),
                onChanged: _city.isNotEmpty ? (val) => setState(() => _specificAddress = val!) : null,
                validator: (val) => _city.isNotEmpty && (val == null || val.isEmpty) ? 'Select an address' : null,
                disabledHint: const Text('Select a city first'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description of Issue',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                onChanged: (val) => setState(() => _description = val),
                validator: (val) => val == null || val.isEmpty ? 'Enter a description' : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Date of Issue (dd/MM/yyyy)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.date_range),
                    ),
                    controller: TextEditingController(text: _date),
                    validator: (val) => val == null || val.isEmpty ? 'Select a date' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.yellow[100],
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    '⚠️ Important Notice:\nSubmit accurate and clear reports to ensure timely repairs. False or incomplete information may delay responses. Misuse of this form will not be processed. Your cooperation helps keep our community safe.',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7CFC00),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 