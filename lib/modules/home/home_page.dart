import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/app/tv_regions.dart';
import 'package:simple_live_app/app/utils/platform_utils.dart';
import 'package:simple_live_app/modules/home/home_controller.dart';
import 'package:simple_live_app/modules/home/home_list_view.dart';
import 'package:simple_live_app/modules/indexed/indexed_controller.dart';
import 'package:simple_live_app/widgets/tv_focusable.dart';

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
            tabs: supportSites.asMap().entries.map((entry) {
              final index = entry.key;
              final e = entry.value;
              return Tab(
                child: TvFocusable(
                  autofocus: homeController.tabController.index == index,
                  region: TvRegions.tabs,
                  isEntryPoint: index == 0,
                  onSelect: () => homeController.tabController.animateTo(index),
                  borderRadius: AppStyle.radius12,
                  debugLabel: 'home_tab_${e.id}',
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
              );
            }).toList(),
          ),
          actions: [
            IconButton(
              onPressed: homeController.toSearch,
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: homeController.tabController,
          builder: (context, _) {
            final children = supportSites.asMap().entries.map((entry) {
              final index = entry.key;
              final e = entry.value;
              return ExcludeFocus(
                excluding: homeController.tabController.index != index,
                child: HomeListView(
                  e.id,
                  key: ValueKey("home_${e.id}"),
                ),
              );
            }).toList();
            if (PlatformUtils.isAndroidTV) {
              return IndexedStack(
                index: homeController.tabController.index,
                children: children,
              );
            }
            return TabBarView(
              controller: homeController.tabController,
              children: children,
            );
          },
        ),
      );
    });
  }
}
