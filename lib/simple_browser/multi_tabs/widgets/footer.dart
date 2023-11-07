import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_inap_browser/simple_browser/multi_tabs/multi_tabs_controller.dart';

import '../../core/color_resources.dart';

class Footer extends GetView<MultiTabsController> {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorResources.browser_footer_bg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more,
              color: Colors.transparent,
            ),
          ),
          IconButton(
            onPressed: controller.addTab,
            icon: const Icon(
              Icons.add,
              color: ColorResources.WHITE,
            ),
          ),
          IconButton(
            onPressed: controller.back,
            icon: const Icon(
              Icons.close,
              color: ColorResources.WHITE,
            ),
          ),
        ],
      ),
    );
  }
}
