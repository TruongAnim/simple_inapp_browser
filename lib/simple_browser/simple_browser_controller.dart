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

  static const String IS_EMPTY_PAGE = 'IS_EMPTY_PAGE';
  static const String IS_INIT_PAGE = 'IS_INIT_PAGE';
  static const String UPDATE_FOOTER = 'UPDATE_FOOTER';
  static const String SEARCH_BAR = 'SEARCH_BAR';
  bool isEmptyPage = true;
  bool isInitPage = true;
  TextEditingController urlText = TextEditingController();
  FocusNode focusNode = FocusNode();

  final List<Map<String, String>> websites = [
    {'name': 'Facebook', 'url': 'https://amazon.com', 'icon': 'assets/features/browser/logo_ic_amazon.png'},
    {'name': 'Facebook', 'url': 'https://facebook.com', 'icon': 'assets/features/browser/logo_ic_facebook.png'},
    {'name': 'Facebook', 'url': 'https://gmail.com', 'icon': 'assets/features/browser/logo_ic_gmail.png'},
    {'name': 'Facebook', 'url': 'https://google.com', 'icon': 'assets/features/browser/logo_ic_google.png'},
    {'name': 'Facebook', 'url': 'https://instagram.com', 'icon': 'assets/features/browser/logo_ic_insta.png'},
    {'name': 'Facebook', 'url': 'https://linkin.com', 'icon': 'assets/features/browser/logo_ic_linkin.png'},
    {'name': 'Facebook', 'url': 'https://tiktok.com', 'icon': 'assets/features/browser/logo_ic_tiktok.png'},
    {'name': 'Facebook', 'url': 'https://twitter.com', 'icon': 'assets/features/browser/logo_ic_twitter.png'},
    {'name': 'Facebook', 'url': 'https://yahoo.com', 'icon': 'assets/features/browser/logo_ic_yahoo.png'},
    {'name': 'Facebook', 'url': 'https://youtube.com', 'icon': 'assets/features/browser/logo_ic_youtube.png'},
    {'name': 'Facebook', 'url': 'https://telegram.com', 'icon': 'assets/features/browser/logo_ic_telegram.png'},
    {'name': 'Facebook', 'url': 'https://whatismyip.com', 'icon': 'assets/features/browser/logo_ic_myip.jpg'},
  ];
  @override
  void onInit() {
    super.onInit();
    setup();
    init();
    _initSearchBar();
    print('truong init SimpleBrowserController');
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

  void search() {
    isEmptyPage = false;
    isInitPage = true;
    focusNode.requestFocus();
    update([IS_EMPTY_PAGE, UPDATE_FOOTER]);
  }

  void home() {
    isEmptyPage = true;
    urlText.clear();
    update([IS_EMPTY_PAGE, UPDATE_FOOTER]);
  }

  void backToVpnApp() {
    Get.back();
  }

  Future<void> share() async {}

  void backToVpnServer() {}

  void reload() {}

  void viewTabs() {}

  void onUrlSubmit(String value) {
    isEmptyPage = false;
    isInitPage = false;

    FocusScope.of(Get.context!).unfocus();
    update([IS_EMPTY_PAGE, IS_INIT_PAGE, UPDATE_FOOTER]);
  }

  void _initSearchBar() {
    focusNode.addListener(() {
      if (!focusNode.hasFocus && isInitPage) {
        home();
      }
    });
    urlText.addListener(() {
      update([SEARCH_BAR]);
    });
  }
}
