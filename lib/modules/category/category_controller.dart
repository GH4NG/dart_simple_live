import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:simple_live_app/app/event_bus.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/modules/category/category_list_controller.dart';
import 'package:simple_live_app/modules/indexed/indexed_controller.dart';

class CategoryController extends GetxController {
  TabController get tabController =>
      Get.find<IndexedController>().tabController;
  StreamSubscription<dynamic>? streamSubscription;

  @override
  void onInit() {
    streamSubscription = EventBus.instance.listen(
      EventBus.kBottomNavigationBarClicked,
      (index) {
        if (index == 2) {
          refreshOrScrollTop();
        }
      },
    );
    super.onInit();
  }

  void refreshOrScrollTop() {
    final supportSites = Sites.supportSites;
    if (supportSites.isEmpty) {
      return;
    }
    var tabIndex = tabController.index;
    if (tabIndex >= supportSites.length) {
      tabIndex = 0;
    }
    final site = supportSites[tabIndex];
    if (!Get.isRegistered<CategoryListController>(tag: site.id)) {
      Get.put(CategoryListController(site), tag: site.id);
    }
    Get.find<CategoryListController>(
      tag: site.id,
    ).scrollToTopOrRefresh();
  }

  @override
  void onClose() {
    streamSubscription?.cancel();
    super.onClose();
  }
}
