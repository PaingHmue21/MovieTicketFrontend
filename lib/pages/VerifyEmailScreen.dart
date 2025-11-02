import 'package:flutter/material.dart';
import 'package:test_app/services/auth_service.dart';
import 'password_change_screen.dart';
import '../models/user.dart';

class VerifyEmailScreen extends StatefulWidget {
  final User user;
  const VerifyEmailScreen({super.key, required this.user});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _codeSent = false;
  bool _isLoading = false;

  Future<void> _sendCode() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.sendVerificationCode(widget.user.userid, _emailController.text.trim());
      setState(() => _codeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Verification code sent to email."), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to send code: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    setState(() => _isLoading = true);
    try {
      bool verified = await AuthService.verifyCode(widget.user.userid, _codeController.text.trim());
      if (verified) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PasswordChangeScreen(user: widget.user),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Invalid code."), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Verification failed: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Verify Email", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Enter your registered email",
                labelStyle: TextStyle(color: Colors.amber),
                prefixIcon: Icon(Icons.email, color: Colors.amber),
              ),
            ),
            const SizedBox(height: 20),
            if (_codeSent)
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Enter 4-digit code",
                  labelStyle: TextStyle(color: Colors.amber),
                  prefixIcon: Icon(Icons.lock, color: Colors.amber),
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _codeSent ? _verifyCode : _sendCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_codeSent ? "Verify Code" : "Send Code", style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
