
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/pages/password_change_screen.dart';
import 'package:test_app/pages/profile_edit.dart';
import '../models/user.dart';
import '../pages/bookinghistory_screen.dart';
import '../utils/constants.dart';
class ProfileScreen extends StatefulWidget {
  final User user;
  final VoidCallback onLogout;
  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  late User _currentUser;
  bool _notificationsEnabled = true; // default enabled
  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() => _notificationsEnabled = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? "Notifications enabled ✅"
              : "Notifications disabled 🔕",
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _navigateToEditProfile() async {
    final updatedUser = await Navigator.push<User?>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileEditScreen(user: _currentUser),
      ),
    );
    if (updatedUser != null) {
      setState(() {
        _currentUser = updatedUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // 👤 Profile Header
            Container(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Profile image editing coming soon!"),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 85,
                      backgroundColor: Colors.amber.withOpacity(0.2),
                      backgroundImage: (_currentUser.profile != null &&
                              _currentUser.profile!.isNotEmpty)
                          ? NetworkImage(
                              "${AppConstants.imageBaseUrl}/images/${_currentUser.profile!}",
                            )
                          : null,
                      child: (_currentUser.profile == null ||
                              _currentUser.profile!.isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.amber,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            _buildInfoRow("Name", _currentUser.username),
            _buildInfoRow("Email", _currentUser.useremail),
            _buildInfoRow("Phone", _currentUser.phoneno ?? "Not provided"),

            const SizedBox(height: 20),

            // 🔧 Settings Section
            _buildSectionTitle("Settings"),
            const SizedBox(height: 10),

            // ⚙️ Edit Profile
            _buildSettingTile(
              icon: Icons.edit,
              title: "Edit Profile",
              onTap: _navigateToEditProfile,
            ),

            // 🔒 Change Password
            _buildSettingTile(
              icon: Icons.lock,
              title: "Change Password",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PasswordChangeScreen(user: _currentUser),
                  ),
                );
              },
            ),

            // 🕘 Booking History
            _buildSettingTile(
              icon: Icons.history,
              title: "Booking History",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingHistoryScreen(user: _currentUser),
                  ),
                );
              },
            ),

            // 🔔 Notifications Toggle
            SwitchListTile(
              activeColor: Colors.amber,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.shade700,
              title: const Text(
                "Notifications",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              secondary: Icon(
                _notificationsEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: Colors.amber,
              ),
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),

            const SizedBox(height: 30),

            // 🚪 Logout Button
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.black),
              label: const Text(
                "Logout",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              onPressed: () => _confirmLogout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Logout Confirmation
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Confirm Logout", style: TextStyle(color: Colors.amber)),
        content: const Text(
          "Are you sure you want to log out?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            child: const Text("Logout", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // 🔹 Section Title
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 🔹 Info Row
  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Setting Tile
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Icon(icon, color: Colors.amber),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
      onTap: onTap,
    );
  }
}

// class ProfileScreen extends StatefulWidget {
//   final User user;
//   final VoidCallback onLogout;
//   const ProfileScreen({
//     super.key,
//     required this.user,
//     required this.onLogout,
//   });

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   late User _currentUser;
//   @override
//   void initState() {
//     super.initState();
//     _currentUser = widget.user;
//   }

//   Future<void> _navigateToEditProfile() async {
//     final updatedUser = await Navigator.push<User?>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ProfileEditScreen(user: _currentUser),
//       ),
//     );
//     if (updatedUser != null) {
//       setState(() {
//         _currentUser = updatedUser;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF121212),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(10),
//         child: Column(
//           children: [
//             // 👤 Profile Header
//             Container(
//               child: Column(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Profile image editing coming soon!"),
//                         ),
//                       );
//                     },
//                     child: CircleAvatar(
//                       radius: 85,
//                       backgroundColor: Colors.amber.withOpacity(0.2),
//                       backgroundImage: (_currentUser.profile != null &&
//                               _currentUser.profile!.isNotEmpty)
//                           ? NetworkImage(
//                               "${AppConstants.imageBaseUrl}/images/${_currentUser.profile!}",
//                             )
//                           : null,
//                       child: (_currentUser.profile == null ||
//                               _currentUser.profile!.isEmpty)
//                           ? const Icon(
//                               Icons.person,
//                               size: 80,
//                               color: Colors.amber,
//                             )
//                           : null,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 30),
//             _buildInfoRow("Name", _currentUser.username),
//             _buildInfoRow("Email", _currentUser.useremail),
//             _buildInfoRow("Phone", _currentUser.phoneno ?? "Not provided"),

//             const SizedBox(height: 20),

//             // 🔧 Settings Section
//             _buildSectionTitle("Settings"),
//             const SizedBox(height: 10),

//             _buildSettingTile(
//               icon: Icons.edit,
//               title: "Edit Profile",
//               onTap: _navigateToEditProfile,
//             ),

//             _buildSettingTile(
//               icon: Icons.lock,
//               title: "Change Password",
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => PasswordChangeScreen(user: _currentUser),
//                   ),
//                 );
//               },
//             ),
//             _buildSettingTile(
//               icon: Icons.history,
//               title: "Booking History",
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => BookingHistoryScreen(user: _currentUser),
//                   ),
//                 );
//               },
//             ),

//             const SizedBox(height: 30),

//             // 🚪 Logout Button
//             ElevatedButton.icon(
//               icon: const Icon(Icons.logout, color: Colors.black),
//               label: const Text(
//                 "Logout",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               onPressed: () => _confirmLogout(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.amber,
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // 🔹 Logout Confirmation
//   void _confirmLogout(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: const Color(0xFF1E1E1E),
//         title: const Text("Confirm Logout", style: TextStyle(color: Colors.amber)),
//         content: const Text(
//           "Are you sure you want to log out?",
//           style: TextStyle(color: Colors.white70),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
//             onPressed: () {
//               Navigator.pop(context);
//               widget.onLogout();
//             },
//             child: const Text("Logout", style: TextStyle(color: Colors.black)),
//           ),
//         ],
//       ),
//     );
//   }

//   // 🔹 Section Title
//   Widget _buildSectionTitle(String title) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Text(
//         title,
//         style: const TextStyle(
//           color: Colors.amber,
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   // 🔹 Info Row
//   Widget _buildInfoRow(String label, String value) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1A1A1A),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.amber.withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.white70)),
//           Flexible(
//             child: Text(
//               value,
//               textAlign: TextAlign.end,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 color: Colors.amber,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 🔹 Setting Tile
//   Widget _buildSettingTile({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//       leading: Icon(icon, color: Colors.amber),
//       title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
//       trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
//       onTap: onTap,
//     );
//   }
// }
