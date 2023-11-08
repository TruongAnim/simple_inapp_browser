import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_inap_browser/simple_browser/models/browser_model.dart';

import 'components/util.dart';
import 'components/webview_tab.dart';
import 'log_utils.dart';
import 'models/webview_model.dart';

// ignore: non_constant_identifier_names
late String WEB_ARCHIVE_DIR;

class SimpleBrowserController extends GetxController {
  static const String EMPTY_URI = 'about:blank';
  static const String UPDATE_BODY = 'UPDATE_BODY';
  static const String UPDATE_FOOTER = 'UPDATE_FOOTER';
  static const String UPDATE_APP_BAR = 'UPDATE_APP_BAR';
  static const String UPDATE_SEARCH = 'UPDATE_SEARCH';

  late BrowserModel browserModel;
  late WebViewModel currentWebViewModel;

  bool isSearching = false;
  RxBool isLoading = RxBool(true);
  bool get isEmptyPage => currentWebViewModel.url == null || currentWebViewModel.url?.rawValue == EMPTY_URI;

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
    _setup();
    _initSearchBar();
  }

  Future<void> _setup() async {
    WEB_ARCHIVE_DIR = (await getApplicationSupportDirectory()).path;
    browserModel = BrowserModel();
    currentWebViewModel = WebViewModel();
    browserModel.setCurrentWebViewModel(currentWebViewModel);
    await restore();
    if (browserModel.webViewTabs.isNotEmpty) {
    } else {
      browserModel.addTab(WebViewTab(
        key: GlobalKey<WebViewTabState>(),
        webViewModel: WebViewModel(),
      ));
    }
    // await FlutterDownloader.initialize(debug: kDebugMode);

    isLoading.value = false;
    // await Permission.camera.request();
    // await Permission.microphone.request();
    // await Permission.storage.request();
  }

  void _initSearchBar() {
    // focusNode.addListener(() {
    //   if (!focusNode.hasFocus && isInitPage) {
    //     home();
    //   }
    // });
    urlText.addListener(() {
      update([UPDATE_SEARCH]);
    });
  }

  void onUrlSubmit(String newUrl) {
    logd('url submit: $newUrl');
    if (newUrl.isEmpty) {
      return;
    }
    FocusScope.of(Get.context!).unfocus();
    var url = WebUri(newUrl.trim());
    if (!url.scheme.startsWith("http") && !Util.isLocalizedContent(url)) {
      url = WebUri(browserModel.getSettings().searchEngine.searchUrl + newUrl);
    }

    if (currentWebViewModel.webViewController != null) {
      currentWebViewModel.url = url;
      currentWebViewModel.webViewController?.loadUrl(urlRequest: URLRequest(url: url));
      delayUpdate([UPDATE_BODY, UPDATE_APP_BAR]);
    }
  }

  Future<void> restore() async {
    await browserModel.restore();
  }

  void search() {
    isSearching = true;
    focusNode.requestFocus();
    update([UPDATE_BODY, UPDATE_APP_BAR]);
  }

  void home() {
    if (isEmptyPage) {
      search();
    } else {
      currentWebViewModel.webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(EMPTY_URI)));
      delayCallback(() {
        currentWebViewModel.webViewController?.clearHistory();
        onUpdateVisitedHistory();
      }, mili: 500);
    }
  }

  Future<void> backToVpnApp() async {
    backToApp();
  }

  Future<void> share() async {
    final String url = currentWebViewModel.url.toString();
    if (currentWebViewModel.url != null && url != EMPTY_URI) {
      Share.shareWithResult(url).then((value) {
        if (value.status == ShareResultStatus.success) {
          // Show success dialog
          // Fluttertoast.showToast(msg: 'Chia sẻ thành công');
        }
      });
    }
  }

  void backToVpnServer() {}

  void reload() {
    currentWebViewModel.webViewController?.reload();
  }

  Future<void> viewTabs() async {
    await Get.toNamed('/multi_tabs');
    logd(currentWebViewModel);
    update([UPDATE_BODY, UPDATE_FOOTER, UPDATE_APP_BAR]);
    updateSearch();
  }

  void webBack() {
    if (currentWebViewModel.canGoBack) {
      currentWebViewModel.webViewController?.goBack();
    }
    if (isEmptyPage) {
      delayUpdate([UPDATE_BODY, UPDATE_APP_BAR]);
    }
  }

  void webForward() {
    if (currentWebViewModel.canGoForward) {
      currentWebViewModel.webViewController?.goForward();
    }
    if (isEmptyPage) {
      delayUpdate([UPDATE_BODY, UPDATE_APP_BAR]);
    }
  }

  Future<void> pressBack(bool isPop) async {
    if (isSearching) {
      isSearching = false;
      update([UPDATE_BODY, UPDATE_APP_BAR]);
      return;
    }
    if (await currentWebViewModel.webViewController?.canGoBack() ?? false) {
      webBack();
    } else {
      backToApp();
    }
  }

  bool canPop() {
    return false;
  }

  Future<void> backToApp() async {
    isLoading.value = true;
    if (browserModel.webViewTabs.isNotEmpty) {
      logd('save ${browserModel.webViewTabs.length}');
      await browserModel.save();
      browserModel.closeAllTabs();
      update([UPDATE_BODY, UPDATE_FOOTER, UPDATE_APP_BAR]);
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    Get.back();
  }

  Future<void> onUpdateVisitedHistory() async {
    final bool canGoBack = await currentWebViewModel.webViewController?.canGoBack() ?? false;
    final bool canGoForward = await currentWebViewModel.webViewController?.canGoForward() ?? false;
    currentWebViewModel.canGoBack = canGoBack;
    currentWebViewModel.canGoForward = canGoForward;
    if (isEmptyPage) {
      update([UPDATE_BODY, UPDATE_APP_BAR]);
    }
  }

  void delayUpdate(List<String> ids, {int mili = 100}) {
    Future.delayed(Duration(milliseconds: mili), () {
      update(ids);
    });
  }

  void delayCallback(VoidCallback callback, {int mili = 100}) {
    Future.delayed(Duration(milliseconds: mili), callback);
  }

  void updateSearch() {
    String url = currentWebViewModel.url.toString();
    if (url == EMPTY_URI) {
      logd('url: ${url}');
      url = '';
    }
    logd('update search $url');
    urlText.text = url;
    update([UPDATE_SEARCH]);
  }

  void onTitleChanged() {
    updateSearch();
    update([UPDATE_BODY, UPDATE_APP_BAR]);
  }

  void onLoadStart() {
    updateSearch();
    update([UPDATE_BODY, UPDATE_APP_BAR]);
  }
}
