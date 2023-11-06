import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:simple_inap_browser/simple_browser/simple_browser_controller.dart';

import 'components/custom_image.dart';
import 'components/tab_viewer.dart';
import 'components/util.dart';
import 'components/webview_tab.dart';
import 'log_utils.dart';

class SimpleBrowserPage extends StatefulWidget {
  const SimpleBrowserPage({super.key});

  @override
  State<SimpleBrowserPage> createState() => _SimpleBrowserPageState();
}

class _SimpleBrowserPageState extends State<SimpleBrowserPage> {
  var _isRestored = false;
  SimpleBrowserController controller = Get.find<SimpleBrowserController>();
  @override
  void initState() {
    super.initState();
    getIntentData();
  }

  getIntentData() async {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isRestored) {
      _isRestored = true;
      controller.restore();
    }
    precacheImage(const AssetImage("assets/icon/icon.png"), context);
  }

  @override
  Widget build(BuildContext context) {
    return _buildBrowser();
  }

  Widget _buildBrowser() {
    var currentWebViewModel = controller.currentWebViewModel;
    var browserModel = controller.browserModel;

    var canShowTabScroller = browserModel.showTabScroller && browserModel.webViewTabs.isNotEmpty;
    return IndexedStack(
      index: 0, //canShowTabScroller ? 1 : 0,
      children: [_buildWebViewTabs(), canShowTabScroller ? _buildWebViewTabsViewer() : Container()],
    );
  }

  Widget _buildWebViewTabs() {
    return WillPopScope(
        onWillPop: () async {
          var browserModel = controller.browserModel;
          var webViewModel = browserModel.getCurrentTab()?.webViewModel;
          var webViewController = webViewModel?.webViewController;

          if (webViewController != null) {
            if (await webViewController.canGoBack()) {
              webViewController.goBack();
              return false;
            }
          }

          if (webViewModel != null && webViewModel.tabIndex != null) {
            setState(() {
              browserModel.closeTab(webViewModel.tabIndex!);
            });
            if (mounted) {
              FocusScope.of(context).unfocus();
            }
            return false;
          }

          return browserModel.webViewTabs.isEmpty;
        },
        child: Listener(
          onPointerUp: (_) {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
              currentFocus.focusedChild!.unfocus();
            }
          },
          child: Scaffold(
            // appBar: const BrowserAppBar(),
            body: _buildWebViewTabsContent(),
          ),
        ));
  }

  Widget _buildWebViewTabsContent() {
    var browserModel = controller.browserModel;
    logd('${browserModel.webViewTabs.length}');
    if (browserModel.webViewTabs.isEmpty) {
      return Center(child: const Text('Emplty tab'));
    }
    logd(browserModel.getCurrentTabIndex());
    logd(browserModel.webViewTabs.length);
    var stackChildren = <Widget>[
      IndexedStack(
        index: browserModel.getCurrentTabIndex(),
        children: browserModel.webViewTabs.map((webViewTab) {
          var isCurrentTab = webViewTab.webViewModel.tabIndex == browserModel.getCurrentTabIndex();

          if (isCurrentTab) {
            Future.delayed(const Duration(milliseconds: 100), () {
              webViewTabStateKey.currentState?.onShowTab();
            });
          } else {
            webViewTabStateKey.currentState?.onHideTab();
          }

          return webViewTab;
        }).toList(),
      ),
      _createProgressIndicator()
    ];

    return Stack(
      children: stackChildren,
    );
  }

  Widget _createProgressIndicator() {
    return Obx(() {
      if (controller.currentWebViewModel.progress >= 1.0) {
        return Container();
      }
      return PreferredSize(
          preferredSize: const Size(double.infinity, 4.0),
          child: SizedBox(
              height: 4.0,
              child: LinearProgressIndicator(
                value: controller.currentWebViewModel.progress,
              )));
    });
  }

  Widget _buildWebViewTabsViewer() {
    var browserModel = controller.browserModel;
    return WillPopScope(
        onWillPop: () async {
          browserModel.showTabScroller = false;
          return false;
        },
        child: Scaffold(
            // appBar: const TabViewerAppBar(),
            body: TabViewer(
          currentIndex: browserModel.getCurrentTabIndex(),
          children: browserModel.webViewTabs.map((webViewTab) {
            webViewTabStateKey.currentState?.pause();
            var screenshotData = webViewTab.webViewModel.screenshot;
            Widget screenshotImage = Container(
              decoration: const BoxDecoration(color: Colors.white),
              width: double.infinity,
              child: screenshotData != null ? Image.memory(screenshotData) : null,
            );

            var url = webViewTab.webViewModel.url;
            var faviconUrl = webViewTab.webViewModel.favicon != null
                ? webViewTab.webViewModel.favicon!.url
                : (url != null && ["http", "https"].contains(url.scheme)
                    ? Uri.parse("${url.origin}/favicon.ico")
                    : null);

            var isCurrentTab = browserModel.getCurrentTabIndex() == webViewTab.webViewModel.tabIndex;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Material(
                  color: isCurrentTab
                      ? Colors.blue
                      : (webViewTab.webViewModel.isIncognitoMode ? Colors.black : Colors.white),
                  child: ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // CachedNetworkImage(
                        //   placeholder: (context, url) =>
                        //   url == "about:blank"
                        //       ? Container()
                        //       : CircularProgressIndicator(),
                        //   imageUrl: faviconUrl,
                        //   height: 30,
                        // )
                        CustomImage(url: faviconUrl, maxWidth: 30.0, height: 30.0)
                      ],
                    ),
                    title: Text(webViewTab.webViewModel.title ?? webViewTab.webViewModel.url?.toString() ?? "",
                        maxLines: 2,
                        style: TextStyle(
                          color: webViewTab.webViewModel.isIncognitoMode || isCurrentTab ? Colors.white : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis),
                    subtitle: Text(webViewTab.webViewModel.url?.toString() ?? "",
                        style: TextStyle(
                          color:
                              webViewTab.webViewModel.isIncognitoMode || isCurrentTab ? Colors.white60 : Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 20.0,
                            color: webViewTab.webViewModel.isIncognitoMode || isCurrentTab
                                ? Colors.white60
                                : Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              if (webViewTab.webViewModel.tabIndex != null) {
                                browserModel.closeTab(webViewTab.webViewModel.tabIndex!);
                                if (browserModel.webViewTabs.isEmpty) {
                                  browserModel.showTabScroller = false;
                                }
                              }
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: screenshotImage,
                )
              ],
            );
          }).toList(),
          onTap: (index) async {
            browserModel.showTabScroller = false;
            browserModel.showTab(index);
          },
        )));
  }
}
