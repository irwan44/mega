import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReminderController extends GetxController {
  var notes = <Map<String, dynamic>>[].obs;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
    _loadNotes();
  }

  // Inisialisasi notifikasi dengan callback onDidReceiveNotificationResponse
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Callback untuk menangani interaksi notifikasi
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        print('Notifikasi diklik: ${notificationResponse.payload}');
        // Lakukan aksi yang diinginkan ketika notifikasi diklik
      },
    );
  }

  void addNote(String title, String note, String priority, DateTime? reminderDate) {
    final newNote = {
      'title': title,
      'note': note,
      'priority': priority,
      'reminderDate': reminderDate?.toIso8601String(),
      'isPressed': false // Pastikan isPressed selalu diinisialisasi sebagai false
    };
    notes.insert(0, newNote);

    if (reminderDate != null && reminderDate.isAfter(DateTime.now())) {
      _scheduleNotification(title, note, reminderDate);
    }

    _saveNotes();
  }

  void updateNote(int index, String title, String note, String priority, DateTime? reminderDate) {
    notes[index] = {
      'title': title,
      'note': note,
      'priority': priority,
      'reminderDate': reminderDate?.toIso8601String(),
      'isPressed': notes[index]['isPressed'] ?? false
    };

    if (reminderDate != null && reminderDate.isAfter(DateTime.now())) {
      _scheduleNotification(title, note, reminderDate);
    }

    _saveNotes();
  }

  void markAsPressed(int index) {
    notes[index]['isPressed'] = true;
    _saveNotes(); // Simpan perubahan ke dalam SharedPreferences atau data lain
  }

  Future<void> _scheduleNotification(String title, String note, DateTime reminderDate) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'reminder_channel_id', 'Reminders',
      channelDescription: 'This channel is for reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    final platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await flutterLocalNotificationsPlugin.schedule(
      notificationId,
      title,
      note,
      reminderDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
    );
  }

  Future<void> scheduleManualNotification(String title, String note, DateTime reminderDate) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'manual_reminder_channel_id', 'Manual Reminders',
      channelDescription: 'This channel is for manual reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    final platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await flutterLocalNotificationsPlugin.schedule(
      notificationId,
      title,
      note,
      reminderDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
    );
  }

  void _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonNotes = jsonEncode(notes);
    prefs.setString('notes', jsonNotes);
  }

  void _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonNotes = prefs.getString('notes');
    if (jsonNotes != null) {
      final List<dynamic> decodedNotes = jsonDecode(jsonNotes);
      notes.value = decodedNotes.map((item) => item as Map<String, dynamic>).toList();
    }
  }
}
