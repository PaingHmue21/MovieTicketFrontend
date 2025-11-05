import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:http/http.dart' as http;
import '../models/notificationapp.dart';
import '../services/local_notification_service.dart';
import '../utils/constants.dart';

class NotificationService {
  final String wsUrl = "https://movieticket-production-6023.up.railway.app/ws";
  StompClient? _client;
  void connectWebSocket(
    int userId,
    Function(NotificationApp) onNotification,
  ) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('⚠️ Skipping WebSocket connection: No internet');
      return;
    }
    _client = StompClient(
      config: StompConfig.sockJS(
        url: wsUrl,
        onConnect: (StompFrame frame) {
          _client!.subscribe(
            destination: '/user/$userId/queue/notifications',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                try {
                  final data = jsonDecode(frame.body!);
                  final notification = NotificationApp.fromJson(data);
                  onNotification(notification);
                  LocalNotificationService.showNotification(
                    title: notification.title,
                    body: notification.message,
                  );
                  print('⚠️ Disconnected from WebSocket');
                } catch (_) {
                  print('⚠️ JSON decode error in WebSocket message');
                }
              }
            },
          );
        },
        onWebSocketError: (error) {
          Connectivity().checkConnectivity().then((result) {
            if (result != ConnectivityResult.none) {
              print('❌ WebSocket Error: $error');
            }
          });
        },
        onDisconnect: (frame) => print('⚠️ Disconnected from WebSocket'),
        onStompError: (frame) =>
            print('⚠️ STOMP Error: ${frame.body ?? "unknown error"}'),
      ),
    );

    _client!.activate();
  }

  Future<List<NotificationApp>> fetchNotifications(int userId) async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/notifications/$userId'),
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
