import 'dart:collection';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/webview_tab.dart';
import 'favorite_model.dart';
import 'search_engine_model.dart';

import 'web_archive_model.dart';
import 'webview_model.dart';

class BrowserSettings {
  SearchEngineModel searchEngine;
  bool homePageEnabled;
  String customUrlHomePage;
  bool debuggingEnabled;

  BrowserSettings(
      {this.searchEngine = GoogleSearchEngine,
      this.homePageEnabled = false,
      this.customUrlHomePage = "",
      this.debuggingEnabled = false});

  BrowserSettings copy() {
    return BrowserSettings(
        searchEngine: searchEngine,
        homePageEnabled: homePageEnabled,
        customUrlHomePage: customUrlHomePage,
        debuggingEnabled: debuggingEnabled);
  }

  static BrowserSettings? fromMap(Map<String, dynamic>? map) {
    return map != null
        ? BrowserSettings(
            searchEngine: SearchEngines[map["searchEngineIndex"]],
            homePageEnabled: map["homePageEnabled"],
            customUrlHomePage: map["customUrlHomePage"],
            debuggingEnabled: map["debuggingEnabled"])
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      "searchEngineIndex": SearchEngines.indexOf(searchEngine),
      "homePageEnabled": homePageEnabled,
      "customUrlHomePage": customUrlHomePage,
      "debuggingEnabled": debuggingEnabled
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

class BrowserModel {
  final List<FavoriteModel> _favorites = [];
  final List<WebViewTab> _webViewTabs = [];
  final Map<String, WebArchiveModel> _webArchives = {};
  int _currentTabIndex = -1;
  BrowserSettings _settings = BrowserSettings();
  late WebViewModel _currentWebViewModel;

  bool _showTabScroller = false;

  bool get showTabScroller => _showTabScroller;

  set showTabScroller(bool value) {
    if (value != _showTabScroller) {
      _showTabScroller = value;
    }
  }

  BrowserModel() {
    _currentWebViewModel = WebViewModel();
  }

  UnmodifiableListView<WebViewTab> get webViewTabs => UnmodifiableListView(_webViewTabs);

  UnmodifiableListView<FavoriteModel> get favorites => UnmodifiableListView(_favorites);

  UnmodifiableMapView<String, WebArchiveModel> get webArchives => UnmodifiableMapView(_webArchives);

  void addTab(WebViewTab webViewTab) {
    _webViewTabs.add(webViewTab);
    _currentTabIndex = _webViewTabs.length - 1;
    webViewTab.webViewModel.tabIndex = _currentTabIndex;

    _currentWebViewModel.updateWithValue(webViewTab.webViewModel);
  }

  void addTabs(List<WebViewTab> webViewTabs) {
    for (final webViewTab in webViewTabs) {
      _webViewTabs.add(webViewTab);
      webViewTab.webViewModel.tabIndex = _webViewTabs.length - 1;
    }
    _currentTabIndex = _webViewTabs.length - 1;
    if (_currentTabIndex >= 0) {
      _currentWebViewModel.updateWithValue(webViewTabs.last.webViewModel);
    }
  }

  void closeTab(int index) {
    _webViewTabs.removeAt(index);
    _currentTabIndex = _webViewTabs.length - 1;

    for (int i = index; i < _webViewTabs.length; i++) {
      _webViewTabs[i].webViewModel.tabIndex = i;
    }

    if (_currentTabIndex >= 0) {
      _currentWebViewModel.updateWithValue(_webViewTabs[_currentTabIndex].webViewModel);
    } else {
      _currentWebViewModel.updateWithValue(WebViewModel());
    }
  }

  void showTab(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      _currentWebViewModel.updateWithValue(_webViewTabs[_currentTabIndex].webViewModel);
    }
  }

  void closeAllTabs() {
    _webViewTabs.clear();
    _currentTabIndex = -1;
    _currentWebViewModel.updateWithValue(WebViewModel());
  }

  int getCurrentTabIndex() {
    return _currentTabIndex;
  }

  WebViewTab? getCurrentTab() {
    return _currentTabIndex >= 0 ? _webViewTabs[_currentTabIndex] : null;
  }

  bool containsFavorite(FavoriteModel favorite) {
    return _favorites.contains(favorite) ||
        _favorites.map((e) => e).toList().firstWhereOrNull((element) => element.url == favorite.url) != null;
  }

  void addFavorite(FavoriteModel favorite) {
    _favorites.add(favorite);
  }

  void addFavorites(List<FavoriteModel> favorites) {
    _favorites.addAll(favorites);
  }

  void clearFavorites() {
    _favorites.clear();
  }

  void removeFavorite(FavoriteModel favorite) {
    if (!_favorites.remove(favorite)) {
      final favToRemove = _favorites.map((e) => e).toList().firstWhereOrNull((element) => element.url == favorite.url);
      _favorites.remove(favToRemove);
    }
  }

  void addWebArchive(String url, WebArchiveModel webArchiveModel) {
    _webArchives.putIfAbsent(url, () => webArchiveModel);
  }

  void addWebArchives(Map<String, WebArchiveModel> webArchives) {
    _webArchives.addAll(webArchives);
  }

  void removeWebArchive(WebArchiveModel webArchive) {
    final path = webArchive.path;
    if (path != null) {
      final webArchiveFile = File(path);
      try {
        webArchiveFile.deleteSync();
      } finally {
        _webArchives.remove(webArchive.url.toString());
      }
    }
  }

  void clearWebArchives() {
    _webArchives.forEach((key, webArchive) {
      final path = webArchive.path;
      if (path != null) {
        final webArchiveFile = File(path);
        try {
          webArchiveFile.deleteSync();
        } finally {
          _webArchives.remove(key);
        }
      }
    });
  }

  BrowserSettings getSettings() {
    return _settings.copy();
  }

  void updateSettings(BrowserSettings settings) {
    _settings = settings;
  }

  void setCurrentWebViewModel(WebViewModel webViewModel) {
    _currentWebViewModel = webViewModel;
  }

  DateTime _lastTrySave = DateTime.now();
  Timer? _timerSave;
  Future<void> save() async {
    _timerSave?.cancel();

    if (DateTime.now().difference(_lastTrySave) >= const Duration(milliseconds: 400)) {
      _lastTrySave = DateTime.now();
      await flush();
    } else {
      _lastTrySave = DateTime.now();
      _timerSave = Timer(const Duration(milliseconds: 500), () {
        save();
      });
    }
  }

  Future<void> flush() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("browser", json.encode(toJson()));
  }

  Future<void> restore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> browserData;
    try {
      final String? source = prefs.getString("browser");
      if (source != null) {
        browserData = await json.decode(source);

        clearFavorites();
        closeAllTabs();
        clearWebArchives();

        final List<Map<String, dynamic>> favoritesList = browserData["favorites"]?.cast<Map<String, dynamic>>() ?? [];
        final List<FavoriteModel> favorites = favoritesList.map((e) => FavoriteModel.fromMap(e)!).toList();

        final Map<String, dynamic> webArchivesMap = browserData["webArchives"]?.cast<String, dynamic>() ?? {};
        final Map<String, WebArchiveModel> webArchives =
            webArchivesMap.map((key, value) => MapEntry(key, WebArchiveModel.fromMap(value?.cast<String, dynamic>())!));

        final BrowserSettings settings =
            BrowserSettings.fromMap(browserData["settings"]?.cast<String, dynamic>()) ?? BrowserSettings();
        final List<Map<String, dynamic>> webViewTabList =
            browserData["webViewTabs"]?.cast<Map<String, dynamic>>() ?? [];
        final List<WebViewTab> webViewTabs = webViewTabList
            .map((e) => WebViewTab(
                  key: GlobalKey<WebViewTabState>(),
                  webViewModel: WebViewModel.fromMap(e)!,
                ))
            .toList();
        webViewTabs.sort((a, b) => a.webViewModel.tabIndex!.compareTo(b.webViewModel.tabIndex!));

        addFavorites(favorites);
        addWebArchives(webArchives);
        updateSettings(settings);
        addTabs(webViewTabs);

        int currentTabIndex = browserData["currentTabIndex"] ?? _currentTabIndex;
        currentTabIndex = min(currentTabIndex, _webViewTabs.length - 1);

        if (currentTabIndex >= 0) {
          showTab(currentTabIndex);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "favorites": _favorites.map((e) => e.toMap()).toList(),
      "webViewTabs": _webViewTabs.map((e) => e.webViewModel.toMap()).toList(),
      "webArchives": _webArchives.map((key, value) => MapEntry(key, value.toMap())),
      "currentTabIndex": _currentTabIndex,
      "settings": _settings.toMap(),
      "currentWebViewModel": _currentWebViewModel.toMap(),
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
