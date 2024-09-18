import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../componen/remender.dart';
import '../controllers/reminder_controller.dart';

class ReminderView extends StatefulWidget {
  const ReminderView({Key? key}) : super(key: key);

  @override
  _ReminderViewState createState() => _ReminderViewState();
}

class _ReminderViewState extends State<ReminderView> {
  final ReminderController controller = Get.put(ReminderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: const Text('Your Reminders'),
        centerTitle: true,
      ),
      body: Obx(() {
        return controller.notes.isEmpty
            ? const Center(
          child: Text(
            'No Reminders available. Click + to add a new Reminder.',
            style: TextStyle(fontSize: 16),
          ),
        )
            : ListView.builder(
          itemCount: controller.notes.length,
          itemBuilder: (context, index) {
            final note = controller.notes[index];
            final priority = note['priority'] ?? 'Low';
            final reminderDate = note['reminderDate'] != null
                ? DateTime.parse(note['reminderDate'])
                : null;
            final formattedDate = reminderDate != null
                ? DateFormat('yyyy-MM-dd HH:mm').format(reminderDate)
                : 'No Date';

            // Cek status notifikasi, jika aktif tampilkan tanda
            final isNotificationActive = note['isPressed'] == true;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: ListTile(
                    leading: _buildPriorityIndicator(priority),
                    title: Text(
                      note['title'] ?? '',
                      style: GoogleFonts.nunito(
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(note['note'] ?? ''),
                        const SizedBox(height: 5),
                        Text('Reminder Date: $formattedDate'),
                      ],
                    ),
                    onTap: () {
                      Get.to(() => AddNoteView(
                        index: index,
                        initialTitle: note['title'] ?? '',
                        initialNote: note['note'] ?? '',
                        initialPriority: priority,
                        initialReminderDate: reminderDate,
                      ));
                    },
                  ),
                ),
              ],
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddNoteView());
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Metode untuk menampilkan indikator prioritas
  Widget _buildPriorityIndicator(String priority) {
    Color color;
    switch (priority) {
      case 'High':
        color = Colors.red;
        break;
      case 'Medium':
        color = Colors.orange;
        break;
      case 'Low':
      default:
        color = Colors.green;
        break;
    }
    return CircleAvatar(
      radius: 5,
      backgroundColor: color,
    );
  }
}
