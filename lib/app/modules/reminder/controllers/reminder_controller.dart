import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReminderController extends GetxController {
  var notes = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotes();
  }

  // Metode untuk menambah catatan baru di awal daftar
  void addNote(String title, String note, String priority) {
    notes.insert(0, {'title': title, 'note': note, 'priority': priority});
    _saveNotes();
  }

  // Metode untuk memperbarui catatan
  void updateNote(int index, String title, String note, String priority) {
    notes[index] = {'title': title, 'note': note, 'priority': priority};
    _saveNotes();
  }

  // Metode untuk menyimpan catatan ke SharedPreferences
  void _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonNotes = jsonEncode(notes);
    prefs.setString('notes', jsonNotes);
  }

  // Metode untuk memuat catatan dari SharedPreferences
  void _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonNotes = prefs.getString('notes');
    if (jsonNotes != null) {
      final List<dynamic> decodedNotes = jsonDecode(jsonNotes);
      notes.value = decodedNotes.map((item) => item as Map<String, dynamic>).toList();
    }
  }
}
