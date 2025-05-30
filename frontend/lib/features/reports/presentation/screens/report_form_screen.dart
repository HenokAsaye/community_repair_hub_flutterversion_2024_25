import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({Key? key}) : super(key: key);

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
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
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });
    await Future.delayed(const Duration(seconds: 2)); // Simulate network
    setState(() { _isLoading = false; });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report submitted successfully!')),
    );
    Navigator.of(context).pop();
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