// import 'package:flutter/material.dart';
// import 'pages/home_screen.dart';
// import 'pages/movies_screen.dart';
// import 'pages/profile_screen.dart';
// import 'pages/login_screen.dart'; // AuthScreen
// import 'pages/tickets_screen.dart';
// import 'pages/notification_screen.dart';
// import 'models/user.dart';
// import 'utils/user_storage.dart'; // ✅ import storage helper
// import 'services/local_notification_service.dart';
// import 'services/notification_service.dart';

// // void main() {
// //   runApp(const MyApp());
// // }
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await LocalNotificationService.initialize(); // ✅ init once
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Bottom Nav Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//         scaffoldBackgroundColor: const Color.fromARGB(0, 0, 0, 0),
//       ),
//       home: const HomePage(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _selectedIndex = 0;
//   User? loggedInUser; // ✅ keep user
//   bool get isLoggedIn => loggedInUser != null;

//   bool _hasNewNotification = false; // ✅ track unread notifications
//   NotificationService? _notificationService;

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus(); // ✅ load saved user when app starts
//   }

//   Future<void> _checkLoginStatus() async {
//     final user = await UserStorage.getUser();
//     setState(() {
//       loggedInUser = user;
//     });

//     // ✅ Connect to WebSocket if already logged in
//     if (user != null) {
//       _startNotificationListener(user.userid);
//     }
//   }

//   void _startNotificationListener(int userId) {
//     _notificationService = NotificationService();
//     _notificationService!.connectWebSocket(userId, (notification) {
//       // when new notification arrives
//       setState(() {
//         _hasNewNotification = true;
//       });
//     });
//   }

//   void _onLogin(User user) async {
//     await UserStorage.saveUser(user);
//     setState(() {
//       loggedInUser = user;
//     });
//     _startNotificationListener(user.userid);
//   }

//   void _onLogout() async {
//     await UserStorage.clearUser();
//     _notificationService?.disconnect();
//     setState(() {
//       loggedInUser = null;
//       _hasNewNotification = false;
//     });
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//       // ✅ clear badge when Notification page is opened
//       if (index == 3) _hasNewNotification = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget currentPage;
//     switch (_selectedIndex) {
//       case 0:
//         currentPage = HomeScreen(user: loggedInUser);
//         break;
//       case 1:
//         currentPage = MoviesScreen(user: loggedInUser);
//         break;
//       case 2:
//         currentPage = isLoggedIn
//             ? TicketsScreen(user: loggedInUser!, onLogout: _onLogout)
//             : const Center(child: Text("Please log in to view tickets"));
//         break;

//       case 3:
//         currentPage = isLoggedIn
//             ? NotificationScreen(
//                 user: loggedInUser,
//                 onViewed: () {
//                   setState(
//                     () => _hasNewNotification = false,
//                   ); // ✅ clear badge when viewed
//                 },
//               )
//             : const Center(child: Text("Please log in to view notifications"));
//         break;

//       // case 3:
//       //   currentPage = isLoggedIn
//       //       ? NotificationScreen(user: loggedInUser)
//       //       : const Center(child: Text("Please log in to view notifications"));
//       //   break;
//       case 4:
//         currentPage = isLoggedIn
//             ? ProfileScreen(user: loggedInUser!, onLogout: _onLogout)
//             : AuthScreen(onLogin: _onLogin);
//         break;
//       default:
//         currentPage = HomeScreen(user: loggedInUser);
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text("Relax Zone")),
//       body: currentPage,
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         items: [
//           const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.movie),
//             label: "Movies",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.confirmation_num),
//             label: "Tickets",
//           ),
//           BottomNavigationBarItem(
//             icon: Stack(
//               children: [
//                 const Icon(Icons.notifications),
//                 if (_hasNewNotification) // ✅ red dot badge
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: Container(
//                       width: 10,
//                       height: 10,
//                       decoration: const BoxDecoration(
//                         color: Colors.red,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             label: "Notification",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: "Profile",
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.deepPurple,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }
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

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = await UserStorage.getUser();
    setState(() {
      loggedInUser = user;
    });

    if (user != null) {
      _startNotificationListener(user.userid);
      _loadUnreadCount(user.userid); // optional: load unread count from API
    }
  }

  void _startNotificationListener(int userId) {
    _notificationService = NotificationService();
    _notificationService!.connectWebSocket(userId, (notification) {
      setState(() {
        _unreadNotificationCount++; // increment badge
      });
    });
  }

  void _loadUnreadCount(int userId) async {
    // optional: fetch unread count from server if API exists
    try {
      final notifications =
          await _notificationService!.fetchNotifications(userId);
      final unread = notifications.where((n) => !n.readStatus).length;
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
            : const Center(child: Text("Please log in to view tickets"));
        break;
      case 3:
        currentPage = isLoggedIn
            ? NotificationScreen(
                user: loggedInUser,
                onViewed: () {
                  setState(() => _unreadNotificationCount = 0);
                },
              )
            : const Center(child: Text("Please log in to view notifications"));
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
          const BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.movie), label: "Movies"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_num), label: "Tickets"),
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
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
