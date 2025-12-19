import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/utils.dart';
import 'package:simple_live_app/routes/route_path.dart';
import 'package:simple_live_app/services/bilibili_account_service.dart';
import 'package:simple_live_app/services/douyin_account_service.dart';

class AccountController extends GetxController {
  Future<String?> cookieInputDialog({required String title}) async {
    final controller = TextEditingController();

    InputDecoration inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      );
    }

    return Get.dialog<String>(
      AlertDialog(
        title: Text('手动输入 $title Cookie'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: inputDecoration('完整 Cookie'),
                maxLines: 5,
              ),
              AppStyle.vGap12,
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final raw = controller.text.trim();
              if (raw.isEmpty) {
                Get.back(result: null);
                return;
              }

              final Map<String, String> kvMap = {};
              final parts = raw.split(';');
              for (var part in parts) {
                final kv = part.split('=');
                if (kv.length >= 2) {
                  final key = kv[0].trim();
                  final value = kv.sublist(1).join('=').trim();
                  kvMap[key] = value;
                }
              }

              Get.dialog(
                AlertDialog(
                  title: const Text('Cookie 预览'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children: kvMap.entries
                          .map(
                            (e) => ListTile(
                              title: Text(e.key),
                              subtitle: Text(e.value),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: Get.back,
                      child: const Text('返回修改'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final formattedCookie = kvMap.entries
                            .map((e) => '${e.key}=${e.value}')
                            .join('; ');
                        Get
                          ..back(result: formattedCookie)
                          ..back(result: formattedCookie);
                      },
                      child: const Text('确认使用'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  Future<void> bilibiliTap() async {
    if (BiliBiliAccountService.instance.logged.value) {
      var result = await Utils.showAlertDialog(
        "确定要退出哔哩哔哩账号吗？",
        title: "退出登录",
      );
      if (result) {
        BiliBiliAccountService.instance.logout();
      }
    } else {
      //AppNavigator.toBiliBiliLogin();
      bilibiliLogin();
    }
  }

  void bilibiliLogin() {
    Utils.showBottomSheet(
      title: "登录哔哩哔哩",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: Platform.isAndroid || Platform.isIOS,
            child: ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text("Web登录"),
              subtitle: const Text("填写用户名密码登录"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get
                  ..back()
                  ..toNamed(RoutePath.kBiliBiliWebLogin);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text("扫码登录"),
            subtitle: const Text("使用哔哩哔哩APP扫描二维码登录"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Get
                ..back()
                ..toNamed(RoutePath.kBiliBiliQRLogin);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text("Cookie登录"),
            subtitle: const Text("手动输入Cookie登录"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              Get.back();
              final cookie = await cookieInputDialog(title: "哔哩哔哩");
              if (cookie?.isNotEmpty ?? false) {
                BiliBiliAccountService.instance
                  ..setCookie(cookie!)
                  ..loadUserInfo();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> douyinTap() async {
    if (DouyinAccountService.instance.logged.value) {
      var result = await Utils.showAlertDialog(
        "确定要清除抖音Cookie吗？",
        title: "清除Cookie",
      );
      if (result) {
        DouyinAccountService.instance.logout();
      }
    } else {
      final cookie = await cookieInputDialog(title: "抖音");
      if (cookie?.isNotEmpty ?? false) {
        DouyinAccountService.instance
          ..setCookie(cookie!)
          ..loadUserInfo();
      }
    }
  }
}
