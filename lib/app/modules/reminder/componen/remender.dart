import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../controllers/reminder_controller.dart';

class AddNoteView extends StatelessWidget {
  final int? index;
  final String? initialTitle;
  final String? initialNote;
  final String? initialPriority;
  final DateTime? initialReminderDate; // Tanggal pengingat

  const AddNoteView({
    Key? key,
    this.index,
    this.initialTitle,
    this.initialNote,
    this.initialPriority,
    this.initialReminderDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReminderController controller = Get.find<ReminderController>();
    final TextEditingController titleController = TextEditingController(text: initialTitle ?? '');
    final TextEditingController noteController = TextEditingController(text: initialNote ?? '');
    final RxString selectedPriority = (initialPriority ?? 'Low').obs;
    Rx<DateTime?> selectedDate = (initialReminderDate ?? null).obs;

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
        child: SizedBox(
          height: 45,
          child: ElevatedButton(
            onPressed: () {
              final title = titleController.text;
              final note = noteController.text;
              final priority = selectedPriority.value;
              final reminderDate = selectedDate.value;
              Get.back();
              if (title.isNotEmpty && note.isNotEmpty) {
                if (index == null) {
                  controller.addNote(title, note, priority, reminderDate);
                  Get.snackbar(
                    'Reminder Saved',
                    'Your Reminder "$title" has been saved.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else {
                  controller.updateNote(index!, title, note, priority, reminderDate);
                  Get.snackbar(
                    'Note Updated',
                    'Your Reminder "$title" has been updated.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
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
                style: const TextStyle(fontSize: 14, color: Colors.white)),
          ),
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
                  SizedBox(
                    width: isWideScreen ? constraints.maxWidth * 0.5 : constraints.maxWidth,
                    height: isWideScreen ? constraints.maxHeight * 0.2 : constraints.maxHeight * 0.25,
                    child: Lottie.asset(
                      'assets/lottie/anm_travel.json',
                      fit: BoxFit.contain,
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
                    child: TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
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
                    child: TextField(
                      controller: noteController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: 'Write your Reminder here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Reminder Date:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pastikan elemen dibagi dengan benar
                      children: [
                        // ListTile diperluas untuk mengisi ruang yang tersisa di sebelah kiri
                        Expanded(
                          child: Obx(() => ListTile(
                            contentPadding: EdgeInsets.zero, // Hapus padding default ListTile
                            title: Text(
                              selectedDate.value == null
                                  ? 'No Date Selected'
                                  : DateFormat('yyyy-MM-dd HH:mm').format(selectedDate.value!),
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate.value ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null) {
                                final TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (pickedTime != null) {
                                  selectedDate.value = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                }
                              }
                            },
                          )),
                        ),
                        const SizedBox(width: 10), // Spacer antara ListTile dan tombol
                        SizedBox(
                          height: 45,
                          child: IconButton(
                              icon: Icon(
                                Icons.notification_add,
                                color:  Colors.blue,
                              ),
                              onPressed: () {
                                final reminderDate = selectedDate.value;
                                if (reminderDate != null && reminderDate.isAfter(DateTime.now())) {
                                  controller.scheduleManualNotification(
                                    titleController.text,
                                    noteController.text,
                                    reminderDate,
                                  );
                                  Get.snackbar(
                                    'Notification Scheduled',
                                    'Reminder set for "${DateFormat('yyyy-MM-dd HH:mm').format(reminderDate)}".',
                                    snackPosition: SnackPosition.TOP,
                                  );
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Please set a valid future reminder date to schedule a notification.',
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              }
                          ),),
                      ],
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
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
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
