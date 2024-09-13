import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../componen/documentrenewtab.dart';
import '../componen/formrenewtab.dart';
import '../componen/infomasirenewtab.dart';
import '../controllers/renew_controller.dart';

class RenewView extends GetView<RenewController> {
  const RenewView({Key? key}) : super(key: key);
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
            FormRenevTab(),        // Tab 1: Form
            DocumentRenevTab(),    // Tab 2: Document
            InformationRenevTab(), // Tab 3: Information
          ],
        ),
      ),
    );
  }
}
