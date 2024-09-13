import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/schedule_controller.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo/mega_insurance.png',
          height: 30,
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            width: 50,
            height: 50,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1000),
              border: Border.all(color: Colors.orange),
            ),
            child: Icon(
              Icons.notification_important_sharp,
              color: Colors.orange,
              size: 18,
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'ScheduleView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
