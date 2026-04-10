import 'dart:async';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:simple_live_app/app/event_bus.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/modules/home/home_list_controller.dart';
import 'package:simple_live_app/modules/indexed/indexed_controller.dart';
import 'package:simple_live_app/routes/route_path.dart';

class HomeController extends GetxController {
  TabController get tabController =>
      Get.find<IndexedController>().tabController;
  StreamSubscription<dynamic>? streamSubscription;

  @override
  void onInit() {
    streamSubscription = EventBus.instance.listen(
      EventBus.kBottomNavigationBarClicked,
      (index) {
        if (index == 0) {
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
    if (!Get.isRegistered<HomeListController>(tag: site.id)) {
      Get.put(HomeListController(site), tag: site.id);
    }
    Get.find<HomeListController>(
      tag: site.id,
    ).scrollToTopOrRefresh();
  }

  void toSearch() {
    Get.toNamed(RoutePath.kSearch);
  }

  @override
  void onClose() {
    streamSubscription?.cancel();
    super.onClose();
  }
}
