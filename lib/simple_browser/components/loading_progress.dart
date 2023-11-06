import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_inap_browser/simple_browser/simple_browser_controller.dart';

// class LoadingProgress extends GetView<NavigationController> {
//   const LoadingProgress({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<int>(
//       stream: controller.progressStream,
//       builder: (context, snap) {
//         final int data = snap.data ?? 0;
//         final double first = iziWidth * (data / 100);
//         final double second = iziWidth - first;
//         return Row(
//           children: [
//             Container(
//               width: first,
//               height: kMinPadding,
//               color: Colors.green,
//             ),
//             Container(
//               width: second,
//               height: kMinPadding,
//               color: Colors.white,
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

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
            ),
          ),
        );
      },
    );
  }
}
