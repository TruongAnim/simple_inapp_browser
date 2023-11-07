import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:simple_inap_browser/simple_browser/models/browser_model.dart';
import 'package:simple_inap_browser/simple_browser/simple_browser_controller.dart';

import '../components/webview_tab.dart';
import '../models/webview_model.dart';

class MultiTabsController extends GetxController {
  static const String UPDATE_TABS = 'UPDATE_TABS';

  late BrowserModel browserModel;
  late SimpleBrowserController browserController = Get.find<SimpleBrowserController>();
  late PageController pageController;
  @override
  void onInit() {
    super.onInit();
    browserModel = browserController.browserModel;
    pageController = PageController(initialPage: browserModel.getCurrentTabIndex(), viewportFraction: 0.8);
  }

  void addTab() {
    browserModel.showTabScroller = false;
    browserModel.addTab(
      WebViewTab(
        key: GlobalKey(),
        webViewModel: WebViewModel(url: WebUri(SimpleBrowserController.EMPTY_URI)),
      ),
    );
    update([UPDATE_TABS]);
  }

  void back() {
    Get.back();
  }

  void removeTab(int index) {
    WebViewTab webViewTab = browserModel.webViewTabs[index];
    if (webViewTab.webViewModel.tabIndex != null) {
      browserModel.closeTab(webViewTab.webViewModel.tabIndex!);
      if (browserModel.webViewTabs.isEmpty) {
        browserModel.showTabScroller = false;
      }
    }
    if (browserModel.webViewTabs.isEmpty) {
      addTab();
    } else {
      update([UPDATE_TABS]);
    }
  }

  void onTabSelect(int index) {
    browserModel.showTabScroller = false;
    browserModel.showTab(index);
    Get.back();
  }
}
