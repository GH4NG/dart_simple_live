import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/constant.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/models/account/douyin_user_info.dart';
import 'package:simple_live_app/services/local_storage_service.dart';
import 'package:simple_live_app/requests/http_client.dart';
import 'package:simple_live_core/simple_live_core.dart';

class DouyinAccountService extends GetxService {
  static DouyinAccountService get instance => Get.find<DouyinAccountService>();

  var logged = false.obs;
  var cookie = "";
  var name = "未登录".obs;

  @override
  void onInit() {
    cookie = LocalStorageService.instance.getValue(
      LocalStorageService.kDouyinCookie,
      "",
    );
    logged.value = cookie.isNotEmpty;
    loadUserInfo();
    super.onInit();
  }

  Future loadUserInfo() async {
    if (cookie.isEmpty) {
      return;
    }
    try {
      final result = await HttpClient.instance.getJson(
        "https://live.douyin.com/webcast/user/me/",
        queryParameters: {
          "aid": "6383",
        },
        header: {
          "Cookie": cookie,
        },
      );

      if (result["status_code"] == 0) {
        var info = DouyinUserInfoModel.fromJson(result["data"]);
        name.value = info.nickname ?? "未登录";
        setSite();
      } else {
        SmartDialog.showToast("抖音登录已失效，请重新登录");
        logout();
      }
    } catch (e) {
      SmartDialog.showToast("获取抖音登录用户信息失败，可前往账号管理重试");
    }
  }

  void setSite() {
    (Sites.allSites[Constant.kDouyin]!.liveSite as DouyinSite).cookie = cookie;
  }

  void setCookie(String cookie) {
    this.cookie = cookie;
    LocalStorageService.instance.setValue(
      LocalStorageService.kDouyinCookie,
      cookie,
    );
    logged.value = cookie.isNotEmpty;
  }

  Future<void> logout() async {
    cookie = "";
    name.value = "未登录";
    setSite();
    LocalStorageService.instance.setValue(
      LocalStorageService.kDouyinCookie,
      "",
    );
    logged.value = false;

    if (Platform.isAndroid || Platform.isIOS) {
      CookieManager cookieManager = CookieManager.instance();
      await cookieManager.deleteAllCookies();
    }
  }
}
