import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/constant.dart';
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/modules/indexed/indexed_controller.dart';

class IndexedSettingsController extends GetxController {
  RxList<String> siteSort = RxList<String>();
  RxList<String> homeSort = RxList<String>();

  List<String> get allHomeKeys => Constant.allHomePages.keys.toList();
  List<String> get allSiteKeys =>
      Sites.allSites.keys.where((key) => key != Constant.kTwitch).toList();

  bool isSiteEnabled(String key) {
    return siteSort.contains(key);
  }

  bool isHomeEnabled(String key) => homeSort.contains(key);

  @override
  void onInit() {
    siteSort = AppSettingsController.instance.siteSort;
    homeSort = AppSettingsController.instance.homeSort;
    if (!homeSort.contains("user")) {
      homeSort.add("user");
      AppSettingsController.instance.setHomeSort(homeSort.toList());
    }
    super.onInit();
  }

  void toggleSiteVisible(String key, bool visible) {
    if (visible) {
      if (!siteSort.contains(key)) {
        siteSort.add(key);
      }
    } else {
      if (siteSort.where((e) => e != Constant.kTwitch).length <= 1) {
        SmartDialog.showToast('至少保留一个平台');
        return;
      }
      siteSort.remove(key);
    }
    final fullOrder = [
      ...siteSort.where((k) => k != Constant.kTwitch),
      ...allSiteKeys.where((k) => !siteSort.contains(k)),
    ];
    final enabled = siteSort.toSet();
    siteSort.value = fullOrder.where(enabled.contains).toList();

    AppSettingsController.instance.setSiteSort(siteSort.toList());
    if (Get.isRegistered<IndexedController>()) {
      final indexedController = Get.find<IndexedController>();
      for (var i = 0; i < indexedController.items.length; i++) {
        if (indexedController.items[i].index == 0 ||
            indexedController.items[i].index == 2) {
          indexedController.pages[i] = const SizedBox();
        }
      }
      var currentIndex = indexedController.index.value;
      if (currentIndex >= indexedController.items.length) {
        currentIndex = indexedController.items.isEmpty
            ? 0
            : indexedController.items.length - 1;
      }
      indexedController.setIndex(currentIndex);
    }
  }

  void updateSiteSort(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final fullOrder = [
      ...siteSort.where((key) => key != Constant.kTwitch),
      ...allSiteKeys.where((key) => !siteSort.contains(key)),
    ];
    final String item = fullOrder.removeAt(oldIndex);
    fullOrder.insert(newIndex, item);
    final enabled = siteSort.toSet();
    siteSort.value = fullOrder.where(enabled.contains).toList();
    AppSettingsController.instance.setSiteSort(siteSort.toList());
    if (Get.isRegistered<IndexedController>()) {
      final indexedController = Get.find<IndexedController>();
      for (var i = 0; i < indexedController.items.length; i++) {
        if (indexedController.items[i].index == 0 ||
            indexedController.items[i].index == 2) {
          indexedController.pages[i] = const SizedBox();
        }
      }
      var currentIndex = indexedController.index.value;
      if (currentIndex >= indexedController.items.length) {
        currentIndex = indexedController.items.isEmpty
            ? 0
            : indexedController.items.length - 1;
      }
      indexedController.setIndex(currentIndex);
    }
  }

  void toggleHomeVisible(String key, bool visible) {
    if (visible) {
      if (!homeSort.contains(key)) {
        homeSort.add(key);
      }
    } else {
      homeSort.remove(key);
    }
    final fullOrder = [
      ...homeSort,
      ...allHomeKeys.where((k) => !homeSort.contains(k)),
    ];
    final enabled = homeSort.toSet();
    homeSort.value = fullOrder.where(enabled.contains).toList();
    if (!homeSort.contains("user")) {
      homeSort.add("user");
    }
    AppSettingsController.instance.setHomeSort(homeSort.toList());
    if (Get.isRegistered<IndexedController>()) {
      final indexedController = Get.find<IndexedController>();
      indexedController.items.value = AppSettingsController.instance.homeSort
          .map((key) => Constant.allHomePages[key]!)
          .toList();
      indexedController.pages.value =
          List<Widget>.filled(indexedController.items.length, const SizedBox());
      var currentIndex = indexedController.index.value;
      if (currentIndex >= indexedController.items.length) {
        currentIndex = indexedController.items.isEmpty
            ? 0
            : indexedController.items.length - 1;
      }
      indexedController.setIndex(currentIndex);
    }
  }

  void updateHomeSort(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final fullOrder = [
      ...homeSort,
      ...allHomeKeys.where((key) => !homeSort.contains(key)),
    ];
    final String item = fullOrder.removeAt(oldIndex);
    fullOrder.insert(newIndex, item);
    final enabled = homeSort.toSet();
    homeSort.value = fullOrder.where(enabled.contains).toList();
    if (!homeSort.contains("user")) {
      homeSort.add("user");
    }
    AppSettingsController.instance.setHomeSort(homeSort.toList());
    if (Get.isRegistered<IndexedController>()) {
      final indexedController = Get.find<IndexedController>();
      indexedController.items.value = AppSettingsController.instance.homeSort
          .map((key) => Constant.allHomePages[key]!)
          .toList();
      indexedController.pages.value =
          List<Widget>.filled(indexedController.items.length, const SizedBox());
      var currentIndex = indexedController.index.value;
      if (currentIndex >= indexedController.items.length) {
        currentIndex = indexedController.items.isEmpty
            ? 0
            : indexedController.items.length - 1;
      }
      indexedController.setIndex(currentIndex);
    }
  }
}
