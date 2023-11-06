import 'package:get/get.dart';
import 'package:simple_inap_browser/simple_browser/simple_browser_controller.dart';

class SimpleBrowserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SimpleBrowserController());
  }
}
