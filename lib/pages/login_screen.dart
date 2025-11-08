import 'package:flutter/material.dart';
import 'package:test_app/main.dart';
import '../services/auth_service.dart'; // import your AuthService
import '../models/user.dart';
import '../utils/user_storage.dart';

class AuthScreen extends StatefulWidget {
  final Function(User user) onLogin; // ✅ take a User instead of VoidCallback
  const AuthScreen({super.key, required this.onLogin});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignupActive = false;
  bool showForgotPassword = false;
  bool isLoading = false; // loading indicator

  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  final signupNameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();

  final forgotPasswordController = TextEditingController();

  final AuthService authService = AuthService();

  void _toggleSignup() => setState(() => isSignupActive = !isSignupActive);

  void _showForgotPasswordDialog() => setState(() => showForgotPassword = true);

  Future<void> loginProcess() async {
    setState(() => isLoading = true);
    try {
      final user = await authService.login(
        loginEmailController.text,
        loginPasswordController.text,
      );
      await UserStorage.saveUser(user);
      //widget.onLogin(user); // send user to HomePage
      // Navigator.pop(context, user);
      widget.onLogin(user);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Successful ✅")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Register using API
  Future<void> registerProcess() async {
    setState(() => isLoading = true);
    try {
      final result = await authService.register(
        signupNameController.text,
        signupEmailController.text,
        signupPasswordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Registered Successfully 🎉"),
        ),
      );
      final user = await authService.login(
        signupEmailController.text,
        signupPasswordController.text,
      );
      await UserStorage.saveUser(user);
      // widget.onLogin(user); // ✅ Send to HomePage & mark logged in
      widget.onLogin(user);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shadowColor: Colors.deepPurple.withOpacity(0.4),
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );
  }

  Widget _buildLoginCard() {
    return _buildCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Sign In",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: loginEmailController,
            decoration: _inputDecoration("Email", Icons.email),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: loginPasswordController,
            obscureText: true,
            decoration: _inputDecoration("Password", Icons.lock),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              child: const Text("Forgot Password?"),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.deepPurple,
            ),
            onPressed: isLoading ? null : loginProcess,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
          ),
          TextButton(
            onPressed: _toggleSignup,
            child: const Text("Don't have an account? Sign Up"),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupCard() {
    return _buildCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Create Account",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: signupNameController,
            decoration: _inputDecoration("Name", Icons.person),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: signupEmailController,
            decoration: _inputDecoration("Email", Icons.email),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: signupPasswordController,
            obscureText: true,
            decoration: _inputDecoration("Password", Icons.lock),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.deepPurple,
            ),
            onPressed: isLoading ? null : registerProcess,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
          ),
          TextButton(
            onPressed: _toggleSignup,
            child: const Text("Already have an account? Sign In"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: showForgotPassword
              ? _buildForgotPasswordCard()
              : isSignupActive
              ? _buildSignupCard()
              : _buildLoginCard(),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordCard() {
    return _buildCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Reset Password",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "Enter your email to receive password reset instructions.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: forgotPasswordController,
            decoration: _inputDecoration("Email", Icons.email),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.deepPurple,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Reset link sent to ${forgotPasswordController.text}",
                  ),
                ),
              );
              setState(() => showForgotPassword = false);
              forgotPasswordController.clear();
            },
            child: const Text(
              "Submit",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => showForgotPassword = false),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}
