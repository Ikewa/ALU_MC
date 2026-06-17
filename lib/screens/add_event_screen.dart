import 'package:flutter/material.dart';
import '../services/event_service.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;

  // Icon Selector
  int _selectedIconCode = 58778;
  final List<IconData> _icons = [
    Icons.mosque,
    Icons.groups,
    Icons.laptop_mac,
    Icons.restaurant,
    Icons.sports_soccer,
  ];

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() { _selectedDate = picked; });
    }
  }

  void _saveEvent() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) return;

    final newEvent = {
      "title": _titleController.text,
      "desc": _descController.text,
      "iconCode": _selectedIconCode,
      "isWeekly": false,
      "date": _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };

    await EventService.addEvent(newEvent);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Event")),
      // --- THE FIX: SingleChildScrollView makes it scrollable ---
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Event Title", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              const Text("Select Icon:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _icons.map((icon) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconCode = icon.codePoint),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _selectedIconCode == icon.codePoint
                            ? const Color(0xFFbf8a2b)
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: _selectedIconCode == icon.codePoint ? Colors.white : Colors.grey),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              ListTile(
                title: Text(_selectedDate == null
                    ? "Pick a Date"
                    : "Date: ${_selectedDate.toString().split(' ')[0]}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _saveEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFbf8a2b),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Post to Cloud", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),

              // Extra space at bottom so you can scroll past the keyboard
              const SizedBox(height: 300),
            ],
          ),
        ),
      ),
    );
  }
}