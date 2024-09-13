import 'package:get/get.dart';

import '../controllers/form_linkaja_controller.dart';

class FormLinkajaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FormLinkajaController>(
      () => FormLinkajaController(),
    );
  }
}
