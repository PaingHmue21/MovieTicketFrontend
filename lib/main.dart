import 'dart:async'; // For StreamSubscription
import 'package:connectivity_plus/connectivity_plus.dart'; // For internet checking
import 'package:flutter/material.dart';
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
  int _selectedIndex = 0;
  User? loggedInUser;
  bool get isLoggedIn => loggedInUser != null;
  int _unreadNotificationCount = 0;
  NotificationService? _notificationService;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    _checkLoginStatus();
  }

  Future<void> _checkInternetConnection() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      // if (!_isDialogShowing) {
      //   _showNoInternetDialog();
      // }
      _showNoInternetDialog();
      _notificationService?.disconnect();
    } else {
      if (_isDialogShowing) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
        _isDialogShowing = false;
      }
      if (loggedInUser != null && _notificationService == null) {
        _startNotificationListener(loggedInUser!.userid);
      }
    }
  }

  void _showNoInternetDialog() {
    _isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false, // prevent dismiss by tapping outside
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
            'Please check your Wi-Fi or mobile data connection.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final result = await _connectivity.checkConnectivity();
                if (result != ConnectivityResult.none) {
                  if (_isDialogShowing) {
                    try {
                      Navigator.of(context, rootNavigator: true).pop();
                    } catch (_) {}
                    _isDialogShowing = false;
                  }
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkLoginStatus() async {
    final user = await UserStorage.getUser();
    setState(() {
      loggedInUser = user;
    });
    if (user != null) {
      _startNotificationListener(user.userid);
      _loadUnreadCount(user.userid);
    }
  }

  void _startNotificationListener(int userId) async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      _notificationService = NotificationService();
      _notificationService!.connectWebSocket(userId, (notification) {
        setState(() {
          _unreadNotificationCount++;
        });
      });
    } else {
      if (!_isDialogShowing) {
        _showNoInternetDialog();
      }
    }
  }

  void _loadUnreadCount(int userId) async {
    try {
      final notifications = await _notificationService!.fetchNotifications(
        userId,
      );
      final unread = notifications.where((n) => !n.readStatus).length;
      print(notifications);
      setState(() {
        _unreadNotificationCount = unread;
      });
    } catch (e) {
      print("⚠️ Failed to load unread notifications: $e");
    }
  }

  void _onLogin(User user) async {
    await UserStorage.saveUser(user);
    setState(() {
      loggedInUser = user;
    });
    _startNotificationListener(user.userid);
  }

  void _onLogout() async {
    await UserStorage.clearUser();
    _notificationService?.disconnect();
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
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
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
