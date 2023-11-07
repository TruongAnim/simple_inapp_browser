import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_inap_browser/simple_browser/core/color_resources.dart';
import 'package:simple_inap_browser/simple_browser/simple_browser_controller.dart';

class LoadingProgress extends GetView<SimpleBrowserController> {
  const LoadingProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        double progress = controller.currentWebViewModel.progress;
        if (progress >= 1.0) {
          return Container();
        }
        return PreferredSize(
          preferredSize: const Size(double.infinity, 4.0),
          child: SizedBox(
            height: 4.0,
            child: LinearProgressIndicator(
              value: progress,
              color: ColorResources.PRIMARY_1,
            ),
          ),
        );
      },
    );
  }
}
