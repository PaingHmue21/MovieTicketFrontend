import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
class ProfileEditScreen extends StatefulWidget {
  final User user;
  const ProfileEditScreen({super.key, required this.user});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _profileImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.useremail);
    _phoneController = TextEditingController(text: widget.user.phoneno ?? "");
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final updatedUser = User(
        userid: widget.user.userid,
        username: _nameController.text.trim(),
        useremail: _emailController.text.trim(),
        phoneno: _phoneController.text.trim(),
        profile: _profileImage != null
            ? base64Encode(await _profileImage!.readAsBytes())
            : widget.user.profile,
      );
      await ApiService().updateUserProfile(updatedUser, _profileImage);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Profile updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to update profile: $e"),
          backgroundColor: Colors.redAccent,
        ),
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
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 250, 249, 248),
        centerTitle: true,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (widget.user.profile != null &&
                              widget.user.profile!.isNotEmpty)
                        ? NetworkImage(
                                "${AppConstants.imageBaseUrl}/images/${widget.user.profile!}",
                              )
                              as ImageProvider
                        : const AssetImage("assets/default_user.png"),
                  ),

                  IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt, color: Colors.amber),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Name Field
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: InputDecoration(
                  labelText: "Username",
                  labelStyle: const TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Colors.amber,
                    size: 30,
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 25),

              // Email Field
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: const TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.email,
                    color: Colors.amber,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  labelStyle: const TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.phone,
                    color: Colors.amber,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving ? "Saving..." : "Save Changes",
                    style: const TextStyle(fontSize: 25, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
