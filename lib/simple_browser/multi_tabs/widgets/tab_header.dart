import 'package:flutter/material.dart';
import 'package:simple_inap_browser/simple_browser/components/custom_image.dart';
import 'package:simple_inap_browser/simple_browser/components/webview_tab.dart';

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
    return ListTile(
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
            color: webViewTab.webViewModel.isIncognitoMode || isCurrentTab ? Colors.white60 : Colors.black54,
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
              color: webViewTab.webViewModel.isIncognitoMode || isCurrentTab ? Colors.white60 : Colors.black54,
            ),
            onPressed: onClose,
          )
        ],
      ),
    );
  }
}
