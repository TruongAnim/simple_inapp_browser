import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_inap_browser/simple_browser/simple_browser_controller.dart';

import 'components/browser_app_bar.dart';
import 'components/browser_body.dart';
import 'components/footer.dart';
import 'core/color_resources.dart';

class SimpleBrowserPage extends GetView<SimpleBrowserController> {
  const SimpleBrowserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: controller.canPop(),
      onPopInvoked: controller.pressBack,
      child: const Scaffold(
        backgroundColor: ColorResources.browser_bg,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              BrowserAppBar(),
              Expanded(child: BrowserBody()),
              Footer(),
            ],
          ),
        ),
      ),
    );
  }
}
