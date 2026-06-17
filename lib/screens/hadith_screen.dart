import 'package:flutter/material.dart';
import '../services/hadith_service.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  int _dayOffset = 0; // 0 = Today, -1 = Yesterday, etc.
  Map<String, dynamic>? _currentHadith;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHadith();
  }

  // Fetch data based on the offset (Today or Past)
  void _loadHadith() async {
    setState(() { _isLoading = true; });

    Map<String, dynamic>? data;

    // Simulate fetching (or use the Service we built)
    // Note: This relies on the HadithService we created in the previous step
    if (_dayOffset == 0) {
      data = await HadithService.getTodayHadith();
    } else {
      // Fetch history (convert negative offset to positive "days ago")
      data = await HadithService.getHadithForDate(_dayOffset.abs());
    }

    if (mounted) {
      setState(() {
        _currentHadith = data ?? {
          "source": "System",
          "text": "No Hadith saved for this date.",
          "translation": ""
        };
        _isLoading = false;
      });
    }
  }

  void _goPrevious() {
    setState(() { _dayOffset--; });
    _loadHadith();
  }

  void _goNext() {
    if (_dayOffset == 0) return; // Can't go to tomorrow
    setState(() { _dayOffset++; });
    _loadHadith();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Light Cream Background
      appBar: AppBar(
        title: const Text("Daily Inspiration"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- DATE HEADER ---
            Text(
              _dayOffset == 0
                  ? "Today's Message"
                  : _dayOffset == -1
                  ? "Yesterday"
                  : "${_dayOffset.abs()} Days Ago",
              style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            // --- THE CARD ---
            _isLoading
                ? const CircularProgressIndicator(color: Color(0xFFbf8a2b))
                : Container(
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFbf8a2b).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.format_quote, size: 50, color: Color(0xFFbf8a2b)),
                  const SizedBox(height: 20),

                  // Arabic or English Text
                  Text(
                    _currentHadith!['text'] ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Translation (if available)
                  if (_currentHadith!['translation'] != null) ...[
                    Text(
                      _currentHadith!['translation'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Source
                  Text(
                    "- ${_currentHadith!['source']} -",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFbf8a2b),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // --- NAVIGATION BUTTONS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton.extended(
                  heroTag: "prev",
                  onPressed: _goPrevious,
                  label: const Text("Previous"),
                  icon: const Icon(Icons.arrow_back),
                  backgroundColor: const Color(0xFFbf8a2b),
                  foregroundColor: Colors.white,
                ),

                // Hide NEXT button if we are on Today
                Opacity(
                  opacity: _dayOffset < 0 ? 1.0 : 0.0,
                  child: FloatingActionButton.extended(
                    heroTag: "next",
                    onPressed: _dayOffset < 0 ? _goNext : null,
                    label: const Text("Next"),
                    icon: const Icon(Icons.arrow_forward),
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFbf8a2b),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}