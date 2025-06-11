
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_repair_hub/config/routes/app_router.dart';
import 'package:community_repair_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String? _selectedRole;
  File? _profileImageFile; // Kept for logic, but UI is removed

  final List<String> _regions = ['Addis Ababa', 'Dire Dawa', 'Bahir Dar', 'Hawassa', 'Mekelle', 'Jimma', 'Gondar', 'Adama', 'Dessie', 'Harar'];
  String? _selectedRegion;
  final Map<String, List<String>> _citiesByRegion = {
    "Addis Ababa": ["Bole", "Sarbet", "Summit", "CMC", "Ayat", "Gerji", "Saris", "Megenagna", "Merkato"],
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
  List<String> _currentCities = [];
  String? _selectedCity;

  // The _pickImage function is kept for potential future use but is not called from the UI.
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_selectedRole == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a role.')),
        );
        return;
      }
      if (_selectedRegion == null || _selectedCity == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select region and city.')),
        );
        return;
      }

      final success = await ref.read(authNotifierProvider.notifier).registerUser(
        name: _name,
        email: _email,
        password: _password,
        role: _selectedRole!,
        region: _selectedRegion!,
        city: _selectedCity!,
        profileImageFile: _profileImageFile,
      );

      if (!mounted) return;

      if (success) {
        final user = ref.read(authNotifierProvider).user;
        if (user != null) {
          final userRole = user.role.toLowerCase().replaceAll(' ', '');
          if (userRole == 'repairteam') {
            context.go(AppRoutes.repairTeamDashboard);
          } else if (userRole == 'citizen') {
            context.go(AppRoutes.home);
          } else {
            context.go(AppRoutes.login);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration reported success, but user data is missing. Please login.')),
          );
          context.go(AppRoutes.login);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (!mounted) return;

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty && (previous?.errorMessage != next.errorMessage || (previous?.isLoading == true && next.isLoading == false))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }

      if (next.isAuthenticated && next.user != null && previous?.isAuthenticated != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup Successful!')),
        );
        final userRole = next.user!.role.toLowerCase().replaceAll(' ', '');
        if (userRole == 'repairteam') {
          context.go(AppRoutes.repairTeamDashboard);
        } else if (userRole == 'citizen') {
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.login);
        }
      }
    });

    final authState = ref.watch(authNotifierProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "Welcome to Community Repair Hub",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Center(
                    child: Text(
                      "Empowering Communities, One Fix at a Time!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Color(0xFF007BFF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),

                  // Circular image picker
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _profileImageFile != null ? FileImage(_profileImageFile!) : null,
                        child: _profileImageFile == null
                            ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  _buildLabel("Full Name"),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: _inputDecoration('Full name'),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 20.0),

                  _buildLabel("Email"),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: _inputDecoration('Email address'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || !value.contains('@')) ? 'Please enter a valid email' : null,
                    onSaved: (value) => _email = value!,
                  ),
                  const SizedBox(height: 20.0),

                  _buildLabel("Password"),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    decoration: _inputDecoration('Password'),
                    obscureText: true,
                    validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
                    onSaved: (value) => _password = value!,
                  ),
                  const SizedBox(height: 25.0),

                  _buildLabel("Role Selection"),
                  const SizedBox(height: 8.0),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _buildRoleRadio(title: 'Citizen', value: 'Citizen'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildRoleRadio(title: 'Repairing Team', value: 'RepairTeam'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25.0),

                  _buildLabel("Address"),
                  const SizedBox(height: 15.0),

                  _buildLabel("Region"),
                  const SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Select Region'),
                    value: _selectedRegion,
                    items: _regions.map((String region) {
                      return DropdownMenuItem<String>(value: region, child: Text(region));
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedRegion = newValue;
                        _currentCities = _citiesByRegion[newValue!] ?? [];
                        _selectedCity = null;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a region' : null,
                  ),
                  const SizedBox(height: 20.0),

                  _buildLabel("City"),
                  const SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Select City'),
                    value: _selectedCity,
                    items: _currentCities.map((String city) {
                      return DropdownMenuItem<String>(value: city, child: Text(city));
                    }).toList(),
                    onChanged: (newValue) => setState(() => _selectedCity = newValue),
                    validator: (value) => value == null ? 'Please select a city' : null,
                    disabledHint: _selectedRegion == null ? const Text("Select a region first") : null,
                  ),
                  const SizedBox(height: 40.0),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7DDE81),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                      onPressed: authState.isLoading ? null : _signup,
                      child: authState.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text(
                        'Already have an account? Login',
                        style: TextStyle(color: Color(0xFF007BFF)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleRadio({required String title, required String value}) {
    return InkWell(
      onTap: () => setState(() => _selectedRole = value),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _selectedRole,
            onChanged: (String? newValue) {
              setState(() {
                _selectedRole = newValue;
              });
            },
            activeColor: const Color(0xFF007BFF),
          ),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      fillColor: const Color(0xFFF2F2F7),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
    );
  }
}

