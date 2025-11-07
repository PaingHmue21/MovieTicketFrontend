import 'dart:async'; // For StreamSubscription
import 'package:connectivity_plus/connectivity_plus.dart'; // For internet checking
import 'package:flutter/material.dart';
import 'package:test_app/services/WebSocketService.dart';
import 'pages/home_screen.dart';
import 'pages/movies_screen.dart';
import 'pages/profile_screen.dart';
import 'pages/login_screen.dart';
import 'pages/tickets_screen.dart';
import 'pages/notification_screen.dart';
import 'models/user.dart';
import 'utils/user_storage.dart';
import 'services/local_notification_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.initialize(); // initialize once
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relax Zone',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? loggedInUser;
  int _selectedIndex = 0;
  int _unreadNotificationCount = 0;
  late WebSocketService _webSocketService;
  NotificationService? _notificationService;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isDialogShowing = false;
  bool get isLoggedIn => loggedInUser != null;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    _initLoginCheck();
  }

  Future<void> _initLoginCheck() async {
    loggedInUser = await UserStorage.getUser();
    setState(() {});
    if (loggedInUser != null) {
      final result = await _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none) {
        _startWebSocketConnection(loggedInUser!.userid);
        _loadUnreadCount(loggedInUser!.userid);
      }
    }
  }

  void _startWebSocketConnection(int userId) {
    _webSocketService = WebSocketService();
    _notificationService = NotificationService(_webSocketService);
    _webSocketService.connect(
      userId: userId,
      onConnected: (_) {
        print("✅ WebSocket Connected");
        Future.delayed(const Duration(seconds: 1), () {
          _notificationService!.subscribeToNotifications(userId, (
            notification,
          ) {
            print("🔔 Local notification triggered");
            setState(() => _unreadNotificationCount++);
            LocalNotificationService.showNotification(
              title: notification.title,
              body: notification.message,
            );
          });
        });
      },
      onError: (error) {
        print("❌ WebSocket Error: $error");
      },
      onDisconnect: (_) {
        print("⚠️ WebSocket Disconnected");
        if (_webSocketService.shouldAutoReconnect && loggedInUser != null) {
          Future.delayed(const Duration(seconds: 5), () {
            print("♻️ Reconnecting WebSocket...");
            _startWebSocketConnection(loggedInUser!.userid);
          });
        }
      },
    );
  }

  Future<void> _loadUnreadCount(int userId) async {
    final notifications = await _notificationService!.fetchNotifications(
      userId,
    );
    setState(
      () => _unreadNotificationCount = notifications
          .where((n) => !n.readStatus)
          .length,
    );
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _showNoInternetDialog();
      _webSocketService.disconnect(manual: false);
    } else {
      if (_isDialogShowing) {
        Navigator.pop(context);
        _isDialogShowing = false;
      }
      if (loggedInUser != null && !_webSocketService.isConnected) {
        _startWebSocketConnection(loggedInUser!.userid);
      }
    }
  }

  void _showNoInternetDialog() {
    if (_isDialogShowing) return;
    _isDialogShowing = true;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("No Internet"),
        content: const Text("Check your connection and try again."),
        actions: [
          TextButton(
            child: const Text("Retry"),
            onPressed: () async {
              final result = await _connectivity.checkConnectivity();
              if (result != ConnectivityResult.none) {
                Navigator.pop(context);
                _isDialogShowing = false;
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _onLogin(User user) async {
    await UserStorage.saveUser(user);
    setState(() {
      loggedInUser = user;
    });
  }

  void _onLogout() async {
    await UserStorage.clearUser();
    setState(() {
      loggedInUser = null;
      _unreadNotificationCount = 0;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;
    switch (_selectedIndex) {
      case 0:
        currentPage = HomeScreen(user: loggedInUser);
        break;
      case 1:
        currentPage = MoviesScreen(user: loggedInUser);
        break;
      case 2:
        currentPage = isLoggedIn
            ? TicketsScreen(user: loggedInUser!, onLogout: _onLogout)
            : const Center(
                child: Text(
                  "Please log in to view tickets",
                  style: TextStyle(
                    color: Color.fromARGB(
                      255,
                      19,
                      221,
                      19,
                    ), // Set your desired color
                    fontSize: 22, // Set your desired font size
                  ),
                ),
              );
        break;
      case 3:
        currentPage = isLoggedIn
            ? NotificationScreen(
                user: loggedInUser,
                onViewed: () {
                  setState(() => _unreadNotificationCount = 0);
                },
                notificationService:
                    _notificationService!, // ✅ pass connected service
              )
            : const Center(
                child: Text(
                  "Please log in to view notifications",
                  style: TextStyle(
                    color: Color.fromARGB(
                      255,
                      13,
                      200,
                      44,
                    ), // Set your desired color
                    fontSize: 22, // Set your desired font size
                  ),
                ),
              );
        break;
      case 4:
        currentPage = isLoggedIn
            ? ProfileScreen(user: loggedInUser!, onLogout: _onLogout)
            : AuthScreen(onLogin: _onLogin);
        break;
      default:
        currentPage = HomeScreen(user: loggedInUser);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Relax Zone")),
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          const BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: "Movies",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num),
            label: "Tickets",
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (_unreadNotificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_unreadNotificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: "Notification",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
