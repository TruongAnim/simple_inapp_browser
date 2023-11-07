import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_inap_browser/simple_browser/core/color_resources.dart';
import 'package:simple_inap_browser/simple_browser/core/izi_size_util.dart';
import 'package:simple_inap_browser/simple_browser/multi_tabs/widgets/tab_header.dart';

import '../components/webview_tab.dart';
import 'multi_tabs_controller.dart';
import 'widgets/footer.dart';

class MultiTabsPage extends StatelessWidget {
  const MultiTabsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(84, 84, 84, 1),
      body: Column(
        children: [
          Expanded(
            child: GetBuilder<MultiTabsController>(
              id: MultiTabsController.UPDATE_TABS,
              builder: (controller) => PageView.builder(
                controller: controller.pageController,
                itemCount: controller.browserModel.webViewTabs.length,
                itemBuilder: (context, index) {
                  WebViewTab webViewTab = controller.browserModel.webViewTabs[index];
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

                  var isCurrentTab = controller.browserModel.getCurrentTabIndex() == webViewTab.webViewModel.tabIndex;
                  return Dismissible(
                    key: Key(webViewTab.toString()),
                    direction: DismissDirection.vertical,
                    onDismissed: (direction) {
                      if (direction == DismissDirection.up || direction == DismissDirection.down) {
                        controller.removeTab(index);
                      }
                    },
                    child: Column(
                      children: [
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            controller.onTabSelect(index);
                          },
                          child: SizedBox(
                            height: iziHeight * 0.7,
                            width: iziWidth * 0.75,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Material(
                                  color: isCurrentTab
                                      ? ColorResources.PRIMARY_1
                                      : (webViewTab.webViewModel.isIncognitoMode ? Colors.black : Colors.white),
                                  child: TabHeader(
                                    faviconUrl: faviconUrl,
                                    isCurrentTab: isCurrentTab,
                                    webViewTab: webViewTab,
                                    onClose: () {
                                      controller.removeTab(index);
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: screenshotImage,
                                )
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const Footer(),
        ],
      ),
    );
  }
}
