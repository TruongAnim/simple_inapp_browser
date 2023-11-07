import 'package:collection/collection.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../log_utils.dart';

class WebViewModel {
  int? _tabIndex;
  final Rx<WebUri?> _url = Rx(null);
  String? _title;
  Favicon? _favicon;
  RxDouble _progress = RxDouble(0);
  final RxBool _canGoBack = RxBool(false);
  final RxBool _canGoForward = RxBool(false);
  late bool _loaded;
  late bool _isDesktopMode;
  late bool _isIncognitoMode;
  late List<Widget> _javaScriptConsoleResults;
  late List<String> _javaScriptConsoleHistory;
  late List<LoadedResource> _loadedResources;
  late bool _isSecure;
  int? windowId;
  InAppWebViewSettings? settings;
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  FindInteractionController? findInteractionController;
  Uint8List? screenshot;
  bool needsToCompleteInitialLoad;

  WebViewModel(
      {int? tabIndex,
      WebUri? url,
      String? title,
      Favicon? favicon,
      double progress = 0.0,
      bool loaded = false,
      bool isDesktopMode = false,
      bool isIncognitoMode = false,
      List<Widget>? javaScriptConsoleResults,
      List<String>? javaScriptConsoleHistory,
      List<LoadedResource>? loadedResources,
      bool isSecure = false,
      this.windowId,
      this.settings,
      this.webViewController,
      this.pullToRefreshController,
      this.findInteractionController,
      this.needsToCompleteInitialLoad = true}) {
    _tabIndex = tabIndex;
    _url.value = url;
    _favicon = favicon;
    _progress = RxDouble(0);
    _loaded = loaded;
    _isDesktopMode = isDesktopMode;
    _isIncognitoMode = isIncognitoMode;
    _javaScriptConsoleResults = javaScriptConsoleResults ?? <Widget>[];
    _javaScriptConsoleHistory = javaScriptConsoleHistory ?? <String>[];
    _loadedResources = loadedResources ?? <LoadedResource>[];
    _isSecure = isSecure;
    settings = settings ?? InAppWebViewSettings();
  }

  int? get tabIndex => _tabIndex;

  set tabIndex(int? value) {
    if (value != _tabIndex) {
      _tabIndex = value;
    }
  }

  // current url
  WebUri? get url => _url.value;
  set url(WebUri? value) => _url.value = value;

  String? get title => _title;

  set title(String? value) {
    if (value != _title) {
      _title = value;
    }
  }

  Favicon? get favicon => _favicon;

  set favicon(Favicon? value) {
    if (value != _favicon) {
      _favicon = value;
    }
  }

  // progress
  double get progress => _progress.value;
  set progress(double value) => _progress.value = value;

  // can go back
  bool get canGoBack => _canGoBack.value;
  set canGoBack(bool value) => _canGoBack.value = value;

  // can go forward
  bool get canGoForward => _canGoForward.value;
  set canGoForward(bool value) => _canGoForward.value = value;

  bool get loaded => _loaded;

  set loaded(bool value) {
    if (value != _loaded) {
      _loaded = value;
    }
  }

  bool get isDesktopMode => _isDesktopMode;

  set isDesktopMode(bool value) {
    if (value != _isDesktopMode) {
      _isDesktopMode = value;
    }
  }

  bool get isIncognitoMode => _isIncognitoMode;

  set isIncognitoMode(bool value) {
    if (value != _isIncognitoMode) {
      _isIncognitoMode = value;
    }
  }

  UnmodifiableListView<Widget> get javaScriptConsoleResults => UnmodifiableListView(_javaScriptConsoleResults);

  setJavaScriptConsoleResults(List<Widget> value) {
    if (!const IterableEquality().equals(value, _javaScriptConsoleResults)) {
      _javaScriptConsoleResults = value;
    }
  }

  void addJavaScriptConsoleResults(Widget value) {
    _javaScriptConsoleResults.add(value);
  }

  UnmodifiableListView<String> get javaScriptConsoleHistory => UnmodifiableListView(_javaScriptConsoleHistory);

  setJavaScriptConsoleHistory(List<String> value) {
    if (!const IterableEquality().equals(value, _javaScriptConsoleHistory)) {
      _javaScriptConsoleHistory = value;
    }
  }

  void addJavaScriptConsoleHistory(String value) {
    _javaScriptConsoleHistory.add(value);
  }

  UnmodifiableListView<LoadedResource> get loadedResources => UnmodifiableListView(_loadedResources);

  setLoadedResources(List<LoadedResource> value) {
    if (!const IterableEquality().equals(value, _loadedResources)) {
      _loadedResources = value;
    }
  }

  void addLoadedResources(LoadedResource value) {
    _loadedResources.add(value);
  }

  bool get isSecure => _isSecure;

  set isSecure(bool value) {
    if (value != _isSecure) {
      _isSecure = value;
    }
  }

  void updateWithValue(WebViewModel webViewModel) {
    tabIndex = webViewModel.tabIndex;
    url = webViewModel.url;
    title = webViewModel.title;
    favicon = webViewModel.favicon;
    progress = webViewModel.progress;
    loaded = webViewModel.loaded;
    isDesktopMode = webViewModel.isDesktopMode;
    isIncognitoMode = webViewModel.isIncognitoMode;
    setJavaScriptConsoleResults(webViewModel._javaScriptConsoleResults.toList());
    setJavaScriptConsoleHistory(webViewModel._javaScriptConsoleHistory.toList());
    setLoadedResources(webViewModel._loadedResources.toList());
    isSecure = webViewModel.isSecure;
    settings = webViewModel.settings;
    webViewController = webViewModel.webViewController;
    pullToRefreshController = webViewModel.pullToRefreshController;
    findInteractionController = webViewModel.findInteractionController;
  }

  static WebViewModel? fromMap(Map<String, dynamic>? map) {
    return map != null
        ? WebViewModel(
            tabIndex: map["tabIndex"],
            url: map["url"] != null ? WebUri(map["url"]) : null,
            title: map["title"],
            favicon: map["favicon"] != null
                ? Favicon(
                    url: WebUri(map["favicon"]["url"]),
                    rel: map["favicon"]["rel"],
                    width: map["favicon"]["width"],
                    height: map["favicon"]["height"],
                  )
                : null,
            progress: map["progress"],
            isDesktopMode: map["isDesktopMode"],
            isIncognitoMode: map["isIncognitoMode"],
            javaScriptConsoleHistory: map["javaScriptConsoleHistory"]?.cast<String>(),
            isSecure: map["isSecure"],
            settings: InAppWebViewSettings.fromMap(map["settings"]),
          )
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      "tabIndex": _tabIndex,
      "url": _url?.toString(),
      "title": _title,
      "favicon": _favicon?.toMap(),
      "progress": _progress,
      "isDesktopMode": _isDesktopMode,
      "isIncognitoMode": _isIncognitoMode,
      "javaScriptConsoleHistory": _javaScriptConsoleHistory,
      "isSecure": _isSecure,
      "settings": settings?.toMap(),
      "screenshot": screenshot,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
