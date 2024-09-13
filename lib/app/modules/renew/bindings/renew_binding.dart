import 'package:get/get.dart';

import '../controllers/renew_controller.dart';

class RenewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RenewController>(
      () => RenewController(),
    );
  }
}
