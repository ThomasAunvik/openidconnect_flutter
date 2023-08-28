part of openidconnect;

class OpenIdConnectAndroidiOS {
  static Future<String> authorizeInteractive({
    required BuildContext context,
    required String title,
    required String authorizationUrl,
    required String redirectUrl,
    required int popupWidth,
    required int popupHeight,
  }) async {
    //Create the url

    final result = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final webViewController = flutterWebView.WebViewController()
          ..setJavaScriptMode(flutterWebView.JavaScriptMode.unrestricted)
          ..setNavigationDelegate(flutterWebView.NavigationDelegate(
            onPageFinished: (url) {
              if (url.startsWith(redirectUrl)) {
                Navigator.pop(dialogContext, url);
              }
            },
          ))
          ..loadRequest(
            Uri.parse(authorizationUrl),
          );

        return AlertDialog(
          actions: [
            IconButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              icon: Icon(Icons.close),
            ),
          ],
          content: Container(
            width:
                min(popupWidth.toDouble(), MediaQuery.of(context).size.width),
            height:
                min(popupHeight.toDouble(), MediaQuery.of(context).size.height),
            child: flutterWebView.WebViewWidget(
              controller: webViewController,
            ),
          ),
          title: Text(title),
        );
      },
    );

    if (result == null) throw AuthenticationException(ERROR_USER_CLOSED);

    return result;
  }
}
