import 'package:get/get.dart';

class ReminderController extends GetxController {
  // Daftar catatan yang disimpan
  var notes = <Map<String, dynamic>>[].obs;

  // Metode untuk menambah catatan baru di awal daftar
  void addNote(String title, String note, String priority) {
    notes.insert(0, {'title': title, 'note': note, 'priority': priority}); // Masukkan catatan di awal daftar
  }

  // Metode untuk memperbarui catatan
  void updateNote(int index, String title, String note, String priority) {
    notes[index] = {'title': title, 'note': note, 'priority': priority};
  }
}
