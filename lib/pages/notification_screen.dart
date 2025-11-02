import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/notificationapp.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
class NotificationScreen extends StatefulWidget {
  final User? user;
  final VoidCallback? onViewed; // callback to update badge
  const NotificationScreen({super.key, this.user, this.onViewed});
  @override
  State<NotificationScreen> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationScreen> {
  final _service = NotificationService();
  List<NotificationApp> _notifications = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
    _service.connectWebSocket(widget.user!.userid, (n) {
      setState(() => _notifications.insert(0, n));
    });
  }

  Future<void> loadNotifications() async {
    try {
      final list = await _service.fetchNotifications(widget.user!.userid);
      setState(() => _notifications = list);
      await markAllAsRead(); // mark all as read when page opens
    } catch (e) {
      print("⚠️ Failed to load notifications: $e");
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final url = Uri.parse(
        '${AppConstants.apiBaseUrl}/mark-read/${widget.user!.userid}',
      );
      final response = await http.put(url);
      if (response.statusCode == 200) {
        setState(() {
          _notifications = _notifications
              .map(
                (n) => NotificationApp(
                  id: n.id,
                  userId: n.userId,
                  title: n.title,
                  message: n.message,
                  readStatus: true,
                  createdAt: n.createdAt,
                ),
              )
              .toList();
        });
        widget.onViewed?.call();
      } else {
        print("⚠️ Server responded with ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Failed to mark notifications as read: $e");
    }
  }

  Future<void> markAsRead(NotificationApp n) async {
    if (!n.readStatus) {
      try {
        final url = Uri.parse('${AppConstants.apiBaseUrl}/mark-read/${n.userId}');
        final response = await http.put(url);
        if (response.statusCode == 200) {
          setState(() {
            final index = _notifications.indexWhere((x) => x.id == n.id);
            if (index != -1) {
              _notifications[index] = NotificationApp(
                id: n.id,
                userId: n.userId,
                title: n.title,
                message: n.message,
                readStatus: true,
                createdAt: n.createdAt,
              );
            }
          });
          widget.onViewed?.call();
        } else {
          print("⚠️ Server responded with ${response.statusCode}");
        }
      } catch (e) {
        print("⚠️ Failed to mark notifications as read: $e");
      }
    }
  }

  @override
  void dispose() {
    _service.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _notifications.isEmpty
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
                  onTap: () => markAsRead(n), // mark individual notification
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
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        n.message,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Text(
                        "${n.createdAt.hour.toString().padLeft(2, '0')}:${n.createdAt.minute.toString().padLeft(2, '0')}",
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
