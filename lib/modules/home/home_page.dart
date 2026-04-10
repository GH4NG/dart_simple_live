import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/modules/home/home_controller.dart';
import 'package:simple_live_app/modules/home/home_list_view.dart';
import 'package:simple_live_app/modules/indexed/indexed_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    return Obx(() {
      AppSettingsController.instance.siteSort.length;
      var supportSites = Sites.supportSites;
      if (supportSites.isNotEmpty &&
          homeController.tabController.length != supportSites.length) {
        final indexedController = Get.find<IndexedController>();
        indexedController.setIndex(indexedController.index.value);
        supportSites = Sites.supportSites;
      }
      return Scaffold(
        appBar: AppBar(
          titleSpacing: 8,
          title: TabBar(
            controller: homeController.tabController,
            labelPadding: AppStyle.edgeInsetsH20,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.label,
            tabAlignment: TabAlignment.center,
            tabs: supportSites
                .map(
                  (e) => Tab(
                    child: Row(
                      children: [
                        Image.asset(
                          e.logo,
                          width: 24,
                          semanticLabel: '${e.name} logo',
                        ),
                        AppStyle.hGap8,
                        Text(e.name),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          actions: [
            IconButton(
              onPressed: homeController.toSearch,
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        body: TabBarView(
          controller: homeController.tabController,
          children: supportSites
              .map(
                (e) => HomeListView(
                  e.id,
                  key: ValueKey("home_${e.id}"),
                ),
              )
              .toList(),
        ),
      );
    });
  }
}
