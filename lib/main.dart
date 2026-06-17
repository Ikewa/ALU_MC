import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // <--- NEW
import 'screens/home_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/tasbih_screen.dart';
import 'services/notification_service.dart';

// --- BACKGROUND HANDLER (Must be outside main class) ---
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you want to do something specific when app is closed, do it here.
  // For now, just printing is fine.
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // --- FCM SETUP ---
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 1. Request Permission (Crucial for iOS/Android 13+)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // 2. Background Handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 3. Subscribe to Topic "updates"
  // This means anyone with the app is automatically in the "updates" group
  await messaging.subscribeToTopic('updates');

  // --- LOCAL NOTIFICATIONS ---
  await NotificationService.init();
  await NotificationService.scheduleDailyTenAM();

  runApp(const MuslimCommunityApp());
}

class MuslimCommunityApp extends StatelessWidget {
  const MuslimCommunityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Muslim Community ALU',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFbf8a2b)),
        useMaterial3: true,
      ),
      home: const MainScaffold(),
    );
  }
}

// ... (Rest of MainScaffold and _MainScaffoldState stays exactly the same) ...
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const QiblaScreen(),
    const TasbihScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFbf8a2b),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.mosque),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Qibla',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fingerprint),
            label: 'Tasbih',
          ),
        ],
      ),
    );
  }
}