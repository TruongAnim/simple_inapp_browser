import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_inap_browser/simple_browser/models/browser_model.dart';

import '../core/color_resources.dart';
import '../core/dismention_constants.dart';
import '../core/images_path.dart';
import '../core/izi_size_util.dart';
import '../core/textstyle_constants.dart';
import '../log_utils.dart';
import '../simple_browser_controller.dart';
import 'loading_progress.dart';
import 'webview_tab.dart';

class BrowserBody extends StatelessWidget {
  const BrowserBody({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SimpleBrowserController>(
      id: SimpleBrowserController.UPDATE_BODY,
      builder: (c) {
        return IndexedStack(
          index: c.isEmptyPage ? 1 : 0,
          children: [
            ContentBody(browserModel: c.browserModel),
            EmptyBody(showSearch: !c.isSearching),
          ],
        );
      },
    );
  }
}

class ContentBody extends StatelessWidget {
  const ContentBody({super.key, required this.browserModel});
  final BrowserModel browserModel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IndexedStack(
          alignment: Alignment.center,
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
        const LoadingProgress(),
      ],
    );
  }
}

class EmptyBody extends GetView<SimpleBrowserController> {
  const EmptyBody({super.key, required this.showSearch});
  final bool showSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showSearch) ...[
          spaceHeight(iziHeight * 0.1),
          Image.asset(
            ImagesPath.ic_logo,
            width: 200,
          ),
          spaceHeight(iziHeight * 0.03),
          InkWell(
            onTap: controller.search,
            child: Container(
              width: iziWidth * 0.8,
              height: iziHeight * 0.07,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: ColorResources.browser_input_bg, borderRadius: BorderRadius.circular(kMediumPadding)),
              child: const Text(
                'Search or input URL',
                style: TextStyles.defaultStyle,
              ),
            ),
          ),
        ],
        SizedBox(height: iziHeight * 0.05, width: iziWidth),
        Expanded(
          child: SizedBox(
            width: iziWidth * 0.8,
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: iziWidth * 0.05,
              crossAxisSpacing: iziWidth * 0.08,
              children: List.generate(
                controller.websites.length,
                (index) {
                  final Map<String, String> item = controller.websites[index];
                  return InkWell(
                    onTap: () {
                      controller.onUrlSubmit(item['url'].toString());
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: ColorResources.WHITE,
                        child: Image.asset(
                          item['icon']!,
                          width: iziWidth * 0.15,
                          height: iziWidth * 0.15,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
