import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../componen/remender.dart';
import '../controllers/reminder_controller.dart';

class ReminderView extends StatelessWidget {
  const ReminderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReminderController controller = Get.put(ReminderController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        centerTitle: true,
      ),
      body: Obx(() {
        return controller.notes.isEmpty
            ? const Center(
          child: Text(
            'No notes available. Click + to add a new note.',
            style: TextStyle(fontSize: 16),
          ),
        )
            : ListView.builder(
          itemCount: controller.notes.length,
          itemBuilder: (context, index) {
            final note = controller.notes[index];
            final priority = note['priority'] ?? 'Low';

            return Card(
              child: ListTile(
                leading: _buildPriorityIndicator(priority),
                title: Text(note['title'] ?? ''),
                subtitle: Text(note['note'] ?? ''),
                onTap: () {
                  Get.to(() => AddNoteView(
                    index: index,
                    initialTitle: note['title'] ?? '',
                    initialNote: note['note'] ?? '',
                    initialPriority: priority,
                  ));
                },
              ),
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
