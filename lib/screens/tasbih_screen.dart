import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Vibration (HapticFeedback)

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int _count = 0;
  int _round = 0;
  int _phraseIndex = 0;

  final List<String> _phrases = [
    "SubhanAllah",
    "Alhamdulillah",
    "Allahu Akbar",
    "Astaghfirullah"
  ];

  void _incrementCount() {
    // Vibrate lightly on tap - feels like a real button click
    HapticFeedback.lightImpact();

    setState(() {
      _count++;
      if (_count == 33) {
        // Long vibration when you hit 33
        HapticFeedback.heavyImpact();
        _round++;
        _count = 0;

        // Optional: Auto-switch phrase after 33?
        // Let's just show a snackbar for now
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Completed 33! MashaAllah!"),
            duration: Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _count = 0;
      _round = 0;
    });
  }

  void _changePhrase() {
    HapticFeedback.selectionClick();
    setState(() {
      _phraseIndex = (_phraseIndex + 1) % _phrases.length;
      _count = 0; // Reset count for new phrase
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Digital Tasbih", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: _reset,
            tooltip: "Reset Counter",
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // 1. The Phrase Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFbf8a2b).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _phrases[_phraseIndex],
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFbf8a2b)
              ),
            ),
          ),

          // Switch Phrase Button
          TextButton(
            onPressed: _changePhrase,
            child: const Text("Tap to change phrase", style: TextStyle(color: Colors.grey)),
          ),

          const Spacer(),

          // 2. The Big Tappable Counter
          GestureDetector(
            onTap: _incrementCount,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFbf8a2b),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFbf8a2b).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$_count",
                    style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                  const Text(
                    "/ 33",
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // 3. Stats at the bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "Total Rounds: $_round",
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}