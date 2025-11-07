import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notificationapp.dart';
import '../utils/constants.dart';
import '../services/WebSocketService.dart';

class NotificationService {
  final WebSocketService _webSocketService;
  NotificationService(this._webSocketService);
  void subscribeToNotifications(
    int userId,
    Function(NotificationApp) onNotify,
  ) {
    if (_webSocketService.client == null || !_webSocketService.isConnected) {
      print("⚠️ WebSocket not ready, skipping subscribe");
      return;
    }
    print("✅ Subscribing to: /user/queue/notifications");
    _webSocketService.client!.subscribe(
      destination: "/user/queue/notifications", // ✅ Correct
      headers: {
        "id": userId.toString(), // ✅ Important for user queue routing
      },
      callback: (frame) {
        print("📩 FRAME: ${frame.body}");
        if (frame.body == null) return;
        final data = jsonDecode(frame.body!);
        onNotify(NotificationApp.fromJson(data));
      },
    );
  }

  Future<List<NotificationApp>> fetchNotifications(int userId) async {
    final response = await http.get(
      Uri.parse("${AppConstants.apiBaseUrl}/notifications/$userId"),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> jsonList = decoded is List
          ? decoded
          : decoded["notifications"];
      return jsonList.map((e) => NotificationApp.fromJson(e)).toList();
    }

    throw Exception("Failed to load notifications: ${response.statusCode}");
  }
}
