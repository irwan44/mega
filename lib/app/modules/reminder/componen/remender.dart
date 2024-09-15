import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/reminder_controller.dart';

class AddNoteView extends StatelessWidget {
  final int? index;
  final String? initialTitle;
  final String? initialNote;
  final String? initialPriority;

  const AddNoteView({
    Key? key,
    this.index,
    this.initialTitle,
    this.initialNote,
    this.initialPriority,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReminderController controller = Get.find<ReminderController>();
    final TextEditingController titleController = TextEditingController(text: initialTitle ?? '');
    final TextEditingController noteController = TextEditingController(text: initialNote ?? '');
    final RxString selectedPriority = (initialPriority ?? 'Low').obs;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: Text(index == null ? 'Create Reminder' : 'Edit Reminder'),
        centerTitle: true,
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            final title = titleController.text;
            final note = noteController.text;
            final priority = selectedPriority.value;
            Get.back();
            if (title.isNotEmpty && note.isNotEmpty) {
              if (index == null) {
                controller.addNote(title, note, priority);
                Get.snackbar(
                  'Reminder Saved',
                  'Your Reminder "$title" has been saved.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } else {
                controller.updateNote(index!, title, note, priority);
                Get.snackbar(
                  'Note Updated',
                  'Your Reminder "$title" has been updated.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
              Get.back();
            } else {
              Get.snackbar(
                'Error',
                'Title and Reminder cannot be empty.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: Text(index == null ? 'Save Reminder' : 'Update Reminder',
              style: const TextStyle(fontSize: 18, color: Colors.white)),
        ),

      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Animasi Lottie
                  Lottie.asset(
                    'assets/lottie/anm_travel.json',
                    width: isWideScreen ? constraints.maxWidth * 0.5 : constraints.maxWidth,
                    height: isWideScreen ? constraints.maxHeight * 0.2 : constraints.maxHeight * 0.25,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child:
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: InputBorder.none,
                    ),
                  ),
                  ),
                  const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child:
                  TextField(
                    controller: noteController,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Write your Reminder here...',
                      border: InputBorder.none,
                    ),
                  ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Priority:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Obx(() => Column(
                    children: [
                      _buildPriorityOption('Low', selectedPriority, isWideScreen),
                      _buildPriorityOption('Medium', selectedPriority, isWideScreen),
                      _buildPriorityOption('High', selectedPriority, isWideScreen),
                    ],
                  )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriorityOption(String priority, RxString selectedPriority, bool isWideScreen) {
    return GestureDetector(
      onTap: () {
        selectedPriority.value = priority;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: selectedPriority.value == priority ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedPriority.value == priority ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                priority,
                style: TextStyle(
                  fontSize: isWideScreen ? 20 : 18,
                  color: selectedPriority.value == priority ? Colors.black : Colors.black,
                ),
              ),
            ),
            if (selectedPriority.value == priority)
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.check_circle, color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
