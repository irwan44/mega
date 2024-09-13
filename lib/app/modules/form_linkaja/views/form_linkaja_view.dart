import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/form_linkaja_controller.dart';

class FormLinkajaView extends GetView<FormLinkajaController> {
  const FormLinkajaView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FormLinkajaView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'FormLinkajaView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
