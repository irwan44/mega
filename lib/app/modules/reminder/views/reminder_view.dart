import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../componen/remender.dart';
import '../controllers/reminder_controller.dart';

class ReminderView extends StatelessWidget {
  const ReminderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReminderController controller = Get.put(ReminderController());

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: const Text('Your Reminder'),
        centerTitle: true,
      ),
      body: Obx(() {
        return controller.notes.isEmpty
            ? const Center(
          child: Text(
            'No Reminder available. Click + to add a new Reminder.',
            style: TextStyle(fontSize: 16),
          ),
        )
            : ListView.builder(
          itemCount: controller.notes.length,
          itemBuilder: (context, index) {
            final note = controller.notes[index];
            final priority = note['priority'] ?? 'Low';

            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 475),
            childAnimationBuilder: (widget) => SlideAnimation(
            child: FadeInAnimation(
            child: widget,
            ),
            ),
            children: [
              SizedBox(height: 10,),
              Container(
                margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: ListTile(
                leading: _buildPriorityIndicator(priority),
                title: Text(note['title'] ?? '', style: GoogleFonts.nunito(color: Colors.black, fontWeight: FontWeight.bold),),
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
            ),
              ],
                )
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
