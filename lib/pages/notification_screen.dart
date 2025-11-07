import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/notificationapp.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'package:intl/intl.dart';
class NotificationScreen extends StatefulWidget {
  final User? user;
  final VoidCallback? onViewed;
  final NotificationService notificationService; // ✅ add this
  const NotificationScreen({
    super.key,
    this.user,
    this.onViewed,
    required this.notificationService, // ✅ receive service
  });
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationApp> _notifications = [];
  bool loading = true;
  late NotificationService _service;

  @override
  void initState() {
    super.initState();
    _service = widget.notificationService;
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final list = await _service.fetchNotifications(widget.user!.userid);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _notifications = list;
        loading = false;
      });
      await markAllAsRead();
    } catch (e) {
      print("⚠️ Error loading notifications: $e");
      setState(() => loading = false);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final url = Uri.parse(
        '${AppConstants.apiBaseUrl}/mark-read/${widget.user!.userid}',
      );
      await http.put(url);
      setState(() {
        for (var n in _notifications) {
          n.readStatus = true;
        }
      });
      widget.onViewed?.call();
    } catch (e) {
      print("⚠️ Failed to mark as read: $e");
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/deletenoti/$id');
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          _notifications.removeWhere((n) => n.id == id);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Notification deleted")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("⚠️ Delete single notification error: $e");
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      final url = Uri.parse(
        '${AppConstants.apiBaseUrl}/deleteallnoti/${widget.user!.userid}',
      );
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() => _notifications.clear());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All notifications deleted")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("⚠️ Delete all notifications error: $e");
    }
  }

  // Confirm delete all
  Future<void> confirmDeleteAll() async {
    if (_notifications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No notifications to delete")),
      );
      return;
    }
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Delete All Notifications",
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to delete all notifications?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete All",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) await deleteAllNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Row(
          children: [
            const Icon(
              Icons.notifications_active,
              color: Colors.amber,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              "Notifications",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            if (_notifications.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${_notifications.length}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            const SizedBox(width: 100),
            TextButton.icon(
              onPressed: confirmDeleteAll, // uses confirmation dialog

              label: const Text(
                "Delete All",
                style: TextStyle(
                  color: Color.fromARGB(255, 52, 242, 18),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 73, 234, 29),
              ),
            )
          : _notifications.isEmpty
          ? const Center(
              child: Text(
                "No notifications yet",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _notifications.length,
              itemBuilder: (context, i) {
                final n = _notifications[i];
                return GestureDetector(
                  onTap: () {},
                  onLongPress: () async {
                    final bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: const Color(0xFF1E1E1E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: const Text(
                          "Delete Notification",
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: const Text(
                          "Are you sure you want to delete this notification?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              "Delete",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await deleteNotification(n.id);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: n.readStatus
                          ? Colors.grey[900]
                          : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: n.readStatus
                            ? Colors.grey.shade700
                            : Colors.amberAccent,
                        width: 1.2,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        n.title,
                        style: TextStyle(
                          color: n.readStatus ? Colors.white70 : Colors.amber,
                          fontWeight: n.readStatus
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        n.message,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(n.createdAt),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}