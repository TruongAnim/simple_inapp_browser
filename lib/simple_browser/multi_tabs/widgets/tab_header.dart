import 'package:flutter/material.dart';
import 'package:simple_inap_browser/simple_browser/components/custom_image.dart';
import 'package:simple_inap_browser/simple_browser/components/webview_tab.dart';
import 'package:simple_inap_browser/simple_browser/core/dismention_constants.dart';
import 'package:simple_inap_browser/simple_browser/simple_browser_controller.dart';

class TabHeader extends StatelessWidget {
  const TabHeader(
      {super.key,
      required this.faviconUrl,
      required this.webViewTab,
      required this.isCurrentTab,
      required this.onClose});
  final Uri? faviconUrl;
  final WebViewTab webViewTab;
  final bool isCurrentTab;
  final Function()? onClose;

  @override
  Widget build(BuildContext context) {
    String title = webViewTab.webViewModel.title.toString();
    String url = webViewTab.webViewModel.url.toString();
    bool isEmpty = url == SimpleBrowserController.EMPTY_URI;
    if (isEmpty) {
      title = 'New tab';
    }
    return ListTile(
      horizontalTitleGap: 0,
      minVerticalPadding: kItemPadding,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: kItemPadding, vertical: 0),
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
          Padding(
              padding: const EdgeInsets.only(right: kItemPadding),
              child: CustomImage(url: faviconUrl, maxWidth: 30.0, height: 30.0))
        ],
      ),
      title: Text(title,
          maxLines: 1,
          style: TextStyle(
            color: webViewTab.webViewModel.isIncognitoMode || isCurrentTab ? Colors.white : Colors.black,
          ),
          overflow: TextOverflow.ellipsis),
      subtitle: url.isNotEmpty
          ? Text(url,
              style: TextStyle(
                color: webViewTab.webViewModel.isIncognitoMode || isCurrentTab ? Colors.white60 : Colors.black54,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis)
          : null,
      trailing: IconButton(
        padding: const EdgeInsets.all(0),
        visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity),
        constraints: const BoxConstraints(),
        icon: Icon(
          Icons.close,
          size: 25,
          color: webViewTab.webViewModel.isIncognitoMode || isCurrentTab ? Colors.white70 : Colors.black38,
        ),
        onPressed: onClose,
      ),
    );
  }
}
