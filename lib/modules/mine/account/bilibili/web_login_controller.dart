import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/controller/base_controller.dart';
import 'package:simple_live_app/app/log.dart';
import 'package:simple_live_app/routes/route_path.dart';
import 'package:simple_live_app/services/bilibili_account_service.dart';

class BiliBiliWebLoginController extends BaseController {
  InAppWebViewController? webViewController;
  final CookieManager cookieManager = CookieManager.instance();
  void onWebViewCreated(InAppWebViewController controller) {
    webViewController = controller;
    webViewController!.loadUrl(
      urlRequest: URLRequest(
        url: WebUri("https://passport.bilibili.com/login"),
      ),
    );
  }

  Future<void> toQRLogin() async {
    await Get.toNamed(RoutePath.kBiliBiliQRLogin);
    Get.back();
  }

  Future<void> onLoadStop(InAppWebViewController controller, Uri? uri) async {
    if (uri == null) {
      return;
    }
    if (uri.host == "m.bilibili.com") {
      logged();
    }
  }

  Future<bool> logged() async {
    try {
      var cookies = await cookieManager.getCookies(
        url: WebUri("https://bilibili.com"),
      );
      if (cookies.isEmpty) {
        return false;
      }
      var cookieStr = cookies.map((e) => "${e.name}=${e.value}").join(";");
      Log.i(cookieStr);
      BiliBiliAccountService.instance.setCookie(cookieStr);
      await BiliBiliAccountService.instance.loadUserInfo();
      Get.back();
      return true;
    } catch (e) {
      return false;
    }
  }
}
