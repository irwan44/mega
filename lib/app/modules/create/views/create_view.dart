import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../componen/documenttab.dart';
import '../componen/formtab.dart';
import '../componen/informasitab.dart';
import '../controllers/create_controller.dart';

class CreateView extends GetView<CreateController> {
  const CreateView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('LINKAJA-TLO'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Form'),
              Tab(text: 'Document'),
              Tab(text: 'Information'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FormTab(),        // Tab 1: Form
            DocumentTab(),    // Tab 2: Document
            InformationTab(), // Tab 3: Information
          ],
        ),
      ),
    );
  }
}
