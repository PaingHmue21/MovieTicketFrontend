import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_app/models/changepassword.dart';
import 'package:test_app/pages/home_screen.dart';
import '../models/user.dart';
import '../utils/user_storage.dart';
import '../utils/constants.dart';

class AuthService {
  static final String baseUrl = AppConstants.apiBaseUrl;
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"useremail": email, "password": password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["status"] == "success") {
        final user = User.fromJson(data["user"]);
        await UserStorage.saveUser(user); // ✅ store immediately
        return user;
      } else {
        throw Exception(data["message"] ?? "Login failed");
      }
    } else {
      final data = json.decode(response.body);
      throw Exception(data["message"] ?? "Failed to login");
    }
  }

  // Register
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "username": name,
        "useremail": email,
        "password": password,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body); // success response
    } else if (response.statusCode == 400) {
      final data = json.decode(response.body);
      throw Exception(data['message']); // email already in use
    } else {
      throw Exception("Failed to register");
    }
  }

  static Future<void> sendVerificationCode(int userId, String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/send-verification-code"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userid": userId, "email": email}),
    );
    if (response.statusCode != 200) {
      throw Exception("Error sending code");
    }
  }

  static Future<bool> verifyCode(int userId, String code) async {
    final response = await http.post(
      Uri.parse("$baseUrl/verify-code"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userid": userId, "code": code}),
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result["verified"] == true;
    } else {
      throw Exception("Invalid verification attempt");
    }
  }

  static Future<void> changePassword(
    BuildContext context,
    ChangePassword updatedUser,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/change-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedUser.toJson()),
    );
    if (response.statusCode == 200) {
      await UserStorage.clearUser();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "✅ Password changed successfully. Please log in again.",
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false, // remove all previous routes
      );
    } else {
      throw Exception("Password change failed: ${response.body}");
    }
  }
}
