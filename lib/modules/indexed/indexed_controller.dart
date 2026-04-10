import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:simple_live_app/app/constant.dart';
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/app/event_bus.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/app/utils.dart';
import 'package:simple_live_app/modules/category/category_controller.dart';
import 'package:simple_live_app/modules/category/category_page.dart';
import 'package:simple_live_app/modules/home/home_controller.dart';
import 'package:simple_live_app/modules/home/home_page.dart';
import 'package:simple_live_app/modules/follow_user/follow_user_controller.dart';
import 'package:simple_live_app/modules/follow_user/follow_user_page.dart';
import 'package:simple_live_app/modules/mine/mine_page.dart';

class IndexedController extends GetxController
    with GetTickerProviderStateMixin {
  RxList<HomePageItem> items = RxList<HomePageItem>([]);

  var index = 0.obs;

  late TabController tabController;
  RxList<Widget> pages = RxList<Widget>([]);
  final List<TabController> staleTabControllers = [];

  void setIndex(int i) {
    final supportSites = Sites.supportSites;
    if (supportSites.isNotEmpty &&
        tabController.length != supportSites.length) {
      var targetSiteIndex = tabController.index;
      if (targetSiteIndex >= supportSites.length) {
        targetSiteIndex = 0;
      }
      final oldTabController = tabController;
      tabController = TabController(
        length: supportSites.length,
        vsync: this,
        initialIndex: targetSiteIndex,
      );
      staleTabControllers.add(oldTabController);
      for (var j = 0; j < items.length; j++) {
        if (items[j].index == 0 || items[j].index == 2) {
          pages[j] = const SizedBox();
        }
      }
    }

    if (i < 0 || i >= items.length || i >= pages.length) {
      return;
    }

    if (pages[i] is SizedBox) {
      switch (items[i].index) {
        case 0:
          Get.put(HomeController());
          pages[i] = const HomePage();
          break;
        case 1:
          Get.put(FollowUserController());
          pages[i] = const FollowUserPage();
          break;
        case 2:
          Get.put(CategoryController());
          pages[i] = const CategoryPage();
          break;
        case 3:
          pages[i] = const MinePage();
          break;
        default:
      }
    } else {
      if (index.value == i) {
        EventBus.instance.emit<int>(
          EventBus.kBottomNavigationBarClicked,
          items[i].index,
        );
      }
    }

    index.value = i;
  }

  @override
  void onInit() {
    tabController = TabController(
      length: Sites.supportSites.length,
      vsync: this,
    );
    Future.delayed(Duration.zero, showFirstRun);
    items.value = AppSettingsController.instance.homeSort
        .map((key) => Constant.allHomePages[key]!)
        .toList();
    pages.value = List<Widget>.filled(items.length, const SizedBox());
    setIndex(0);
    super.onInit();
  }

  @override
  void onClose() {
    for (final controller in staleTabControllers) {
      controller.dispose();
    }
    tabController.dispose();
    super.onClose();
  }

  Future<void> showFirstRun() async {
    var settingsController = Get.find<AppSettingsController>();
    if (settingsController.firstRun) {
      settingsController.setNoFirstRun();
      await Utils.showStatement();
      Utils.checkUpdate();
    }
  }
}
