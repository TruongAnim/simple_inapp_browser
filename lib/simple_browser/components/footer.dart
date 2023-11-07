import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_inap_browser/simple_browser/simple_browser_controller.dart';

import '../core/color_resources.dart';
import '../core/dismention_constants.dart';
import '../core/izi_size_util.dart';
import '../core/textstyle_constants.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SimpleBrowserController>(
      id: SimpleBrowserController.UPDATE_FOOTER,
      builder: (controller) {
        final int tabCount = controller.browserModel.webViewTabs.length;
        final SimpleBrowserController browserController = Get.find<SimpleBrowserController>();
        return Container(
          color: ColorResources.browser_footer_bg,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: controller.webBack,
                      icon: Obx(
                        () {
                          bool canGoBack = controller.currentWebViewModel.canGoBack;
                          return Icon(
                            Icons.arrow_back_ios_rounded,
                            color: canGoBack ? ColorResources.WHITE : ColorResources.browser_footer_inactive,
                          );
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: controller.webForward,
                      icon: Obx(
                        () {
                          bool canGoForward = controller.currentWebViewModel.canGoForward;
                          return Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: canGoForward ? ColorResources.WHITE : ColorResources.browser_footer_inactive,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: browserController.home,
                icon: Obx(
                  () {
                    return Icon(
                      browserController.isEmptyPage ? Icons.search : Icons.home,
                      color: ColorResources.WHITE,
                    );
                  },
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        browserController.viewTabs();
                      },
                      icon: Container(
                        height: iziWidth * 0.06,
                        width: iziWidth * 0.06,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(width: 2, color: ColorResources.browser_footer_active),
                        ),
                        child: Text(
                          tabCount.toString(),
                          style: TextStyles.defaultStyle.setColor(ColorResources.browser_footer_active),
                        ),
                      ),
                    ),
                    const PopupMenuWidget(),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class PopupMenuWidget extends GetView<SimpleBrowserController> {
  const PopupMenuWidget({super.key});

  PopupMenuItem<String> _buildPopupItem({
    required String value,
    required String title,
    String? icon,
  }) {
    return PopupMenuItem(
      value: value,
      height: IZISizeUtil.setSizeWithWidth(percent: 0.1),
      child: Center(
        child: Column(
          children: [
            Row(
              children: [
                if (icon != null)
                  Image.asset(
                    icon,
                    width: IZISizeUtil.setSize(percent: 0.023),
                    height: IZISizeUtil.setSize(percent: 0.023),
                    // colorIconsSvg: ColorResources.WHITE,
                  ),
                const SizedBox(width: IZISizeUtil.SPACE_2X),
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: ColorResources.WHITE,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(-25, 0),
      shape: const RoundedRectangleBorder(),
      onSelected: (value) {
        switch (value) {
          case 'reload':
            controller.reload();
            break;
          case 'backToVpnServer':
            controller.backToVpnServer();
            break;
          case 'share':
            controller.share();
            break;
          case 'backToVpnApp':
            controller.backToVpnApp();
            break;
        }
      },
      surfaceTintColor: Colors.black,
      color: ColorResources.browser_footer_popup,
      constraints: BoxConstraints.tightFor(
        width: IZISizeUtil.setSizeWithWidth(percent: 0.5),
      ),
      child: const Icon(
        Icons.more_horiz,
        color: ColorResources.browser_footer_active,
        size: kMediumIconSize * 1.3,
      ),
      itemBuilder: (BuildContext context) {
        return [
          _buildPopupItem(value: 'reload', title: 'Reload'.tr),
          // const PopupMenuDivider(),
          _buildPopupItem(value: 'backToVpnServer', title: 'VPN Server'.tr),
          // const PopupMenuDivider(),
          _buildPopupItem(value: 'share', title: 'Share'.tr),
          // const PopupMenuDivider(),
          _buildPopupItem(value: 'backToVpnApp', title: 'Back to VPN Fast'.tr),
        ];
      },
    );
  }
}
