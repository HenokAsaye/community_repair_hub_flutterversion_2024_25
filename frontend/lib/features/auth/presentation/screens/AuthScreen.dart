import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:community_repair_hub/config/routes/app_router.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // Ensures content is not obscured by system UI
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // To make buttons fill width easily
              children: <Widget>[
                // Image
                Container(
                  height: 300.0,
                  padding: const EdgeInsets.all(10.0), // Emulates Compose padding on Image
                  child: Image.asset(
                    'assets/images/community1.png', // Ensure this path is correct
                    fit: BoxFit.contain, // Equivalent to ContentScale.Fit
                  ),
                ),
                // No spacer needed for 0.dp height

                // Title Text
                const Text(
                  "Community Repair Hub",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Monospace', // Ensure 'Monospace' font is available or use a specific one
                  ),
                ),
                const SizedBox(height: 10.0),

                // Subtitle Text
                const Text(
                  "Empowering Communities, One Fix at a Time!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w300, // FontWeight.Light
                    fontFamily: 'Cursive', // Ensure 'Cursive' font is available or use a specific one
                  ),
                ),
                const SizedBox(height: 20.0),

                // Login Button
                SizedBox(
                  height: 80.0,
                  child: ElevatedButton(
                    onPressed: () {
                      // Assuming you have named routes like '/login'
                      context.go(AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7CFC00), // Lawn Green
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0), // Padding for button content
                    ),
                    child: const Text(
                      "Login",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w600, // FontWeight.SemiBold
                        fontFamily: 'SansSerif', // Ensure 'SansSerif' font is available or use a specific one
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),

                // Register Button
                SizedBox(
                  height: 80.0,
                  child: ElevatedButton(
                    onPressed: () {
                      // Assuming you have named routes like '/signup'
                      context.go(AppRoutes.signup);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7CFC00), // Lawn Green
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0), // Padding for button content
                    ),
                    child: const Text(
                      "Register",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w600, // FontWeight.SemiBold
                        fontFamily: 'SansSerif', // Ensure 'SansSerif' font is available or use a specific one
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
