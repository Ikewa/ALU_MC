import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/prayer_service.dart';
import '../services/notification_service.dart';
import '../services/event_service.dart';
import 'hadith_screen.dart';
import 'add_event_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> prayerTimes = [];
  bool isLoading = true;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  void _initApp() async {
    await NotificationService.scheduleFridayMeeting();
    _getUserLocationAndPrayers();
  }

  // --- ADMIN LOGIN (Long Press Title) ---
  void _showAdminLogin() {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Admin Access"),
        content: TextField(
          controller: codeController,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Enter Admin Code"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (codeController.text == "1234") {
                setState(() {
                  isAdmin = true;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Admin Mode Enabled!")),
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }

  Future<void> _getUserLocationAndPrayers() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      final service = PrayerService();

      // Fetch the raw times
      final times = service.getPrayerTimes(
        position.latitude,
        position.longitude,
      );

      setState(() {
        prayerTimes = times;
        isLoading = false;
      });

      // --- AUTOMATICALLY SET ALARMS ---
      _schedulePrayerAlarms(times);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // --- PARSE AND SCHEDULE HELPER ---
  void _schedulePrayerAlarms(List<Map<String, String>> times) {
    final now = DateTime.now();

    // Loop through the list (Fajr, Dhuhr, etc.)
    for (int i = 0; i < times.length; i++) {
      final prayer = times[i];
      final timeString = prayer['time']!; // e.g., "05:30"

      try {
        final parts = timeString.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        // Create a Date object for Today at that time
        final scheduleTime = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );

        // Schedule it (ID starts at 100 to avoid conflicts)
        NotificationService.schedulePrayer(
          scheduleTime,
          prayer['name']!,
          100 + i,
        );
      } catch (e) {
        print("Error parsing time for ${prayer['name']}: $e");
      }
    }

    // Optional: Show a subtle message that alarms are active
    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Prayer alarms updated."), duration: Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String englishDate = DateFormat('EEEE, d MMMM y').format(now);
    HijriCalendar.setLocal('en');
    String islamicDate = HijriCalendar.fromDate(now).toFormat("dd MMMM yyyy");

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: _showAdminLogin,
          child: const Text(
            "Muslim Community (ALU)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getUserLocationAndPrayers,
          ),
        ],
      ),

      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFbf8a2b),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEventScreen(),
                  ),
                );
              },
            )
          : null,

      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  englishDate,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  islamicDate,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFbf8a2b),
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HadithScreen(),
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFbf8a2b), Color(0xFFe5b65e)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFbf8a2b).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Daily Inspiration".toUpperCase(),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '"Tap to read today\'s Hadith"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- FIREBASE STREAM ---
                SizedBox(
                  height: 250,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: EventService.getEventsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return const Center(
                          child: Text("Error loading events"),
                        );
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFbf8a2b),
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty)
                        return const Center(child: Text("No upcoming events."));

                      return PageView.builder(
                        controller: PageController(viewportFraction: 0.9),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final event =
                              docs[index].data() as Map<String, dynamic>;
                          final docId = docs[index].id;

                          final IconData icon = IconData(
                            event['iconCode'] ?? 58778,
                            fontFamily: 'MaterialIcons',
                          );

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFbf8a2b).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFbf8a2b),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      icon,
                                      size: 40,
                                      color: const Color(0xFFbf8a2b),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      event['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      event['desc'],
                                      textAlign: TextAlign.center,
                                    ),

                                    if (event['isWeekly'] == false &&
                                        event['date'] != null) ...[
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () {
                                          final date = DateTime.parse(
                                            event['date'],
                                          );
                                          NotificationService.scheduleEvent(
                                            index,
                                            event['title'],
                                            date,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Alarm set!"),
                                            ),
                                          );
                                        },
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.notifications_active,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            Text(
                                              " Tap to set alarm",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (isAdmin)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          EventService.deleteEvent(docId),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // --- PRAYER LIST ---
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Prayer Times",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFbf8a2b),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: prayerTimes.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 2,
                            child: ListTile(
                              leading: const Icon(
                                Icons.access_time,
                                color: Color(0xFFbf8a2b),
                              ),
                              title: Text(
                                prayerTimes[index]['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(
                                prayerTimes[index]['time']!,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
