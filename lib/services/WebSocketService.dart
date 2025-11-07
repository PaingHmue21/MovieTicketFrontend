// websocket_service.dart
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class WebSocketService {
  final String wsUrl = "https://movieticket-production-6023.up.railway.app";

  StompClient? _client;
  bool _isManuallyDisconnected = false;
  bool get isConnected => _client?.connected ?? false;

  void connect({
    required int userId,
    required Function(StompFrame) onConnected,
    required Function(dynamic) onError,
    required Function(StompFrame) onDisconnect,
  }) {
    if (isConnected) return;
    _client = StompClient(
      config: StompConfig.sockJS(
        url: "$wsUrl/ws?login=$userId",
        onConnect: (frame) {
          print("✅ STOMP Connected!");
          onConnected(frame);
        },
        stompConnectHeaders: {
          "login": userId.toString(), // ✅ VERY IMPORTANT
          "passcode": "guest", // required but value not checked
        },
        onWebSocketError: (err) => onError(err),
        onDisconnect: (f) => onDisconnect(f),
      ),
    );
    _client!.activate();
    print("🔌 WebSocket connecting...");
  }

  void disconnect({bool manual = true}) {
    _isManuallyDisconnected = manual;
    _client?.deactivate();
  }

  bool get shouldAutoReconnect => !_isManuallyDisconnected;
  StompClient? get client => _client;
}
