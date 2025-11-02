import 'package:flutter/material.dart';
import 'package:test_app/models/user.dart';
import 'package:test_app/models/changepassword.dart';
import 'package:test_app/services/auth_service.dart';

class PasswordChangeScreen extends StatefulWidget {
  final User user;
  const PasswordChangeScreen({super.key, required this.user});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _codeSent = false;
  bool _isSendingCode = false;
  bool _isVerifyingCode = false;
  bool _isVerified = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _codeController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // Step 1 - Send Code
  Future<void> _sendCode() async {
    setState(() => _isSendingCode = true);
    try {
      await AuthService.sendVerificationCode(widget.user.userid, widget.user.useremail);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Verification code sent to your email."),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _codeSent = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to send code: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isSendingCode = false);
    }
  }

  // Step 2 - Verify Code
  Future<void> _verifyCode() async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please enter the code."), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isVerifyingCode = true);
    try {
      bool verified = await AuthService.verifyCode(widget.user.userid, _codeController.text.trim());
      if (verified) {
        setState(() => _isVerified = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Email verified successfully!"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Invalid or expired verification code."), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Verification failed: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isVerifyingCode = false);
    }
  }

  // Step 3 - Change Password
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please verify your email first."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final updatedUser = ChangePassword(
        userid: widget.user.userid,
        useremail: widget.user.useremail,
        oldpassword: _oldPasswordController.text.trim(),
        newpassword: _newPasswordController.text.trim(),
      );
      await AuthService.changePassword(context,updatedUser);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Password changed successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to change password: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Change Password", style: TextStyle(color: Colors.black)),
        backgroundColor: const Color.fromARGB(255, 250, 249, 247),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextFormField(
              initialValue: widget.user.useremail,
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: const TextStyle(color: Colors.amber),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // Step 1 & 2
            if (!_isVerified)
              Column(
                children: [
                  if (_codeSent)
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Enter 4-digit code",
                        labelStyle: const TextStyle(color: Colors.amber),
                        prefixIcon: const Icon(Icons.verified, color: Colors.amber),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: _isSendingCode || _isVerifyingCode
                        ? null
                        : _codeSent
                            ? _verifyCode
                            : _sendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isSendingCode || _isVerifyingCode
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_codeSent ? "Verify Code" : "Send Code",
                            style: const TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),

            if (_isVerified) ...[
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _oldPasswordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Old Password", Icons.lock_outline),
                      validator: (v) => v == null || v.isEmpty ? "Enter old password" : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("New Password", Icons.lock),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Enter new password";
                        if (v.length < 6) return "Password must be at least 6 characters";
                        if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)').hasMatch(v)) {
                          return "Include upper, lower case & number";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _changePassword,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _isSaving ? "Saving..." : "Change Password",
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amber),
      prefixIcon: Icon(icon, color: Colors.amber),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}
