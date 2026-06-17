import 'package:cloud_firestore/cloud_firestore.dart';

class EventService {
  // Point to the 'events' collection in your new database
  static final CollectionReference _eventsRef =
  FirebaseFirestore.instance.collection('events');

  // --- 1. Load Events (Live Stream) ---
  // This listens for changes. If you add an event, it updates instantly.
  static Stream<QuerySnapshot> getEventsStream() {
    return _eventsRef.orderBy('date').snapshots();
  }

  // --- 2. Add Event ---
  static Future<void> addEvent(Map<String, dynamic> newEvent) async {
    await _eventsRef.add(newEvent);
  }

  // --- 3. Delete Event ---
  static Future<void> deleteEvent(String documentId) async {
    await _eventsRef.doc(documentId).delete();
  }
}