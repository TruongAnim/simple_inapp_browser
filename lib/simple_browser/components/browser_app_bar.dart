import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/color_resources.dart';
import '../core/dismention_constants.dart';
import '../simple_browser_controller.dart';

class BrowserAppBar extends GetView<SimpleBrowserController> {
  const BrowserAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SimpleBrowserController>(
      id: SimpleBrowserController.UPDATE_APP_BAR,
      builder: (c) {
        if (c.isSearching || !c.isEmptyPage) {
          return const SearchAppBar();
        } else {
          return const EmptyAppBar();
        }
      },
    );
  }
}

class EmptyAppBar extends StatelessWidget {
  const EmptyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          padding: const EdgeInsets.only(left: 10, top: kItemPadding),
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back,
            size: kMediumIconSize * 1.5,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class SearchAppBar extends StatelessWidget {
  const SearchAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SimpleBrowserController>(
      id: SimpleBrowserController.UPDATE_SEARCH,
      builder: (controller) => Container(
        color: Colors.white24,
        padding: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding,
          vertical: kMinPadding,
        ),
        child: TextField(
          focusNode: controller.focusNode,
          controller: controller.urlText,
          onSubmitted: controller.onUrlSubmit,
          style: const TextStyle(
              color: Colors.black, decoration: TextDecoration.none, fontSize: 16, fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            hintText: 'Search or input URL',
            hintStyle: const TextStyle(color: ColorResources.GREY),
            contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kTopPadding),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(
              Icons.search,
              size: kMediumIconSize * 1.2,
              color: ColorResources.GREY,
            ),
            suffixIcon: controller.urlText.text.isNotEmpty && controller.focusNode.hasFocus
                ? InkWell(
                    onTap: () {
                      controller.urlText.clear();
                    },
                    child: const Icon(
                      Icons.close,
                      size: kMediumIconSize * 1.2,
                      color: ColorResources.GREY,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
