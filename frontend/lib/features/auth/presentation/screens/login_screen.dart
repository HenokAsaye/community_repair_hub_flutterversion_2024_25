import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:community_repair_hub/config/routes/app_router.dart';
import 'package:community_repair_hub/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      // No need for _formKey.currentState!.save(); as controllers hold the values.
      // setState for _loginInProgress and _loginError is handled by Riverpod.
      await ref.read(authNotifierProvider.notifier).loginUser(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      // Navigation and error display will be handled by ref.listen
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    // final authNotifier = ref.read(authNotifierProvider.notifier); // authNotifier is not used, can be removed

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (!mounted) return; // Ensure widget is still in the tree

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
        // Consider adding a way to clear the error in AuthNotifier after it's shown
        // e.g., ref.read(authNotifierProvider.notifier).clearErrorMessage();
      }
      if (next.isAuthenticated && next.user != null) {
        // Navigate based on role
        final userRole = next.user!.role.toLowerCase();
        if (userRole == 'repairteam' || userRole == 'team') {
          context.go(AppRoutes.repairTeamDashboard);
        } else if (userRole == 'citizen') {
          context.go(AppRoutes.home); // Assuming AppRoutes.home is citizen dashboard
        } else {
          // Fallback or error for unknown role
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unknown user role: ${next.user!.role}')),
          );
          context.go(AppRoutes.login); // Or a generic error page
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 32.0,
            top: 72.0,
            right: 32.0,
            bottom: 52.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  "Welcome back to the Community Repair Hub",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35.0,
                    fontFamily: 'Cursive',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  "Empowering Communities, One Fix at a Time!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: 'Cursive',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFF7CFC00)),
                    ),
                  ),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFF7CFC00)),
                    ),
                  ),
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30.0),
                // Error messages are now handled by SnackBar via ref.listen
                SizedBox(
                  height: 60.0,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7CFC00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: authState.isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2.0,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                "Logging in...",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'SansSerif',
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SansSerif',
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to password reset screen
                  },
                  child: const Text(
                    "Need help with your password?",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                      fontFamily: 'SansSerif',
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account yet? ",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Assumes '/signup' route will be defined in GoRouter
                        // Replace with context.go('/signup') if using GoRouter directly here
                        context.go(AppRoutes.signup);
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        "Join us now!",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Color(0xFF00C853),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}