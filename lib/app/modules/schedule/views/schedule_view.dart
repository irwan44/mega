import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/schedule_controller.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {

  Future<bool> _onWillPop() async {
    final shouldExit = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
              color: Colors.white
          ),
          padding: EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.orange),
                title: Text(
                  'Keluar Aplikasi?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false), // Jangan keluar
                    child: Text(
                      'Tidak',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true), // Keluar
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text('Ya', style: TextStyle( color: Colors.white),),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    return shouldExit ?? false; // Mengembalikan false jika pengguna menekan di luar BottomSheet
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      _onWillPop();
      return true;
    },
    child:
      Scaffold(
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
      ),
    );
  }
}
