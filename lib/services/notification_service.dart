import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:http/http.dart' as http;
import '../models/notificationapp.dart';
import '../services/local_notification_service.dart';

class NotificationService {
  StompClient? _client;
  void connectWebSocket(int userId, Function(NotificationApp) onNotification) {
    _client = StompClient(
      config: StompConfig.sockJS(
        url: 'http://10.0.2.2:8080/ws',
        onConnect: (StompFrame frame) {
          _client!.subscribe(
            destination: '/user/$userId/queue/notifications',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                final data = jsonDecode(frame.body!);
                final notification = NotificationApp.fromJson(data);
                onNotification(notification);
                LocalNotificationService.showNotification(
                  title: notification.title,
                  body: notification.message,
                );
              }
            },
          );
          
        },
        onWebSocketError: (error) => print('❌ WebSocket Error: $error'),
        onDisconnect: (frame) => print('⚠️ Disconnected from WebSocket'),
        onStompError: (frame) =>
            print('⚠️ STOMP Error: ${frame.body ?? "unknown error"}'),
      ),
    );
    _client!.activate();
  }

  Future<List<NotificationApp>> fetchNotifications(int userId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/notifications/$userId'),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> jsonList;
      if (decoded is List) {
        jsonList = decoded;
      } else if (decoded is Map && decoded.containsKey('notifications')) {
        jsonList = decoded['notifications'];
      } else {
        throw Exception('Unexpected JSON format: ${response.body}');
      }
      return jsonList.map((e) => NotificationApp.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load notifications: ${response.statusCode}');
    }
  }

  void disconnect() {
    _client?.deactivate();
  }
}
