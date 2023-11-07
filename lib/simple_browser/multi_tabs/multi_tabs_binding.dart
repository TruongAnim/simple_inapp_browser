import 'package:get/get.dart';
import 'package:simple_inap_browser/simple_browser/multi_tabs/multi_tabs_controller.dart';

class MultiTabsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MultiTabsController>(() => MultiTabsController());
  }
}
