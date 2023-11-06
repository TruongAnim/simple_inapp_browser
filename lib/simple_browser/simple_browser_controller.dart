import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_inap_browser/simple_browser/models/browser_model.dart';

import 'components/webview_tab.dart';
import 'log_utils.dart';
import 'models/webview_model.dart';

// ignore: non_constant_identifier_names
late String WEB_ARCHIVE_DIR;
// ignore: non_constant_identifier_names
late double TAB_VIEWER_BOTTOM_OFFSET_1;
// ignore: non_constant_identifier_names
late double TAB_VIEWER_BOTTOM_OFFSET_2;
// ignore: non_constant_identifier_names
late double TAB_VIEWER_BOTTOM_OFFSET_3;
// ignore: constant_identifier_names
const double TAB_VIEWER_TOP_OFFSET_1 = 0.0;
// ignore: constant_identifier_names
const double TAB_VIEWER_TOP_OFFSET_2 = 10.0;
// ignore: constant_identifier_names
const double TAB_VIEWER_TOP_OFFSET_3 = 20.0;
// ignore: constant_identifier_names
const double TAB_VIEWER_TOP_SCALE_TOP_OFFSET = 250.0;
// ignore: constant_identifier_names
const double TAB_VIEWER_TOP_SCALE_BOTTOM_OFFSET = 230.0;

class SimpleBrowserController extends GetxController {
  late BrowserModel browserModel;
  late WebViewModel currentWebViewModel;
  @override
  void onInit() {
    super.onInit();
    setup();
    init();
  }

  Future<void> setup() async {
    WEB_ARCHIVE_DIR = '/data/user/0/com.example.simple_inap_browser/files';
    // (await getApplicationSupportDirectory()).path;

    TAB_VIEWER_BOTTOM_OFFSET_1 = 130.0;
    TAB_VIEWER_BOTTOM_OFFSET_2 = 140.0;
    TAB_VIEWER_BOTTOM_OFFSET_3 = 150.0;

    // await FlutterDownloader.initialize(debug: kDebugMode);

    // await Permission.camera.request();
    // await Permission.microphone.request();
    // await Permission.storage.request();
  }

  Future<void> init() async {
    browserModel = BrowserModel();

    currentWebViewModel = WebViewModel();
    browserModel.setCurrentWebViewModel(currentWebViewModel);
    logd('add tab');
    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(url: WebUri('https://google.com')),
    ));
  }

  restore() async {
    browserModel.restore();
  }
}
