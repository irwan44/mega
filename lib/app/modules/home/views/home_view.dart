import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../account/views/account_view.dart';
import '../../quiz/views/quiz_view.dart';
import '../../schedule/views/schedule_view.dart';
import '../../setting/views/setting_view.dart';
import 'view.dart'; // Asumsikan ini adalah lokasi dari ViewHome

class HomeView extends StatefulWidget {

  const HomeView({Key? key,}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int currentIndex = 0;

  final List<Widget> pages = [
    ViewHome(),
    ScheduleView(),
    AccountView(),
    SettingView(),
  ];

  @override
  void initState() {
    super.initState();
  }

  void onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.orange,
        iconSize: 26,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey[400],
        currentIndex: currentIndex,
        selectedFontSize: 14,
        selectedLabelStyle: GoogleFonts.nunito(),
        unselectedFontSize: 12,
        showSelectedLabels: true, // Tampilkan label untuk item yang dipilih
        showUnselectedLabels: true, // Tampilkan label untuk item yang tidak dipilih
        onTap: onTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            tooltip: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: "Schedule",
            tooltip: "Schedule",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Account",
            tooltip: "Account",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Setting",
            tooltip: "Setting",
          ),
        ],
      ),
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: pages[currentIndex],
    );
  }
}
