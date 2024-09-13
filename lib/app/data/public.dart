import 'package:get/get.dart';

import 'localstorage.dart';


class UniverseController extends GetxController {
  final getToken = LocalStorages.getToken.obs;
  final getTokenRegis = LocalStorages.getTokenRegis.obs;
}

class Publics {
  static var controller = Get.put(UniverseController());
}