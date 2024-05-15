import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:openidconnect_platform_interface/openidconnect_platform_interface.dart';
import "package:web/web.dart" as html;

/// A web implementation of the OpenidconnectWeb plugin.
class OpenIdConnectWeb extends OpenIdConnectPlatform {
  static void registerWith(Registrar registrar) {
    OpenIdConnectPlatform.instance = OpenIdConnectWeb();
  }

  @override
  Future<String?> authorizeInteractive({
    required BuildContext context,
    required String title,
    required String authorizationUrl,
    required String redirectUrl,
    required int popupWidth,
    required int popupHeight,
    bool useWebRedirectLoop = false,
  }) async {
    if (useWebRedirectLoop) {
      const AUTH_DESTINATION_KEY = "openidconnect_auth_destination_url";
      html.window.sessionStorage[AUTH_DESTINATION_KEY] =
          html.window.location.toString();
      html.window.location.assign(authorizationUrl);
      return Future<String?>.value(null);
    }

    final top = (html.window.outerHeight - popupHeight) / 2 +
        (html.window.screenTop);
    final left = (html.window.outerWidth - popupWidth) / 2 +
        (html.window.screenLeft);

    var options =
        'width=${popupWidth},height=${popupHeight},toolbar=no,location=no,directories=no,status=no,menubar=no,copyhistory=no&top=$top,left=$left';

    final child = html.window.open(
      authorizationUrl,
      "open_id_connect_authentication",
      options,
    );

    final c = new Completer<String>();
    html.window.onMessage.first.then((event) {
      final url = event.data.toString();
      c.complete(url);
      if(child != null) {
        child.close();
      }
    });

    return c.future;
  }

  @override
  Future<String?> processStartup() async {
    const AUTH_RESPONSE_KEY = "openidconnect_auth_response_info";

    final url = html.window.sessionStorage[AUTH_RESPONSE_KEY];
    html.window.sessionStorage.removeItem(AUTH_RESPONSE_KEY);

    return url;
  }
}
