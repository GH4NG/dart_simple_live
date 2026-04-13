import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/app/tv_regions.dart';
import 'package:simple_live_app/app/utils/platform_utils.dart';
import 'package:simple_live_app/modules/category/category_controller.dart';
import 'package:simple_live_app/modules/category/category_list_view.dart';
import 'package:simple_live_app/modules/indexed/indexed_controller.dart';
import 'package:simple_live_app/widgets/tv_focusable.dart';

class CategoryPage extends GetView<CategoryController> {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.isRegistered<CategoryController>()
        ? Get.find<CategoryController>()
        : Get.put(CategoryController());
    return Obx(() {
      AppSettingsController.instance.siteSort.length;
      var supportSites = Sites.supportSites;
      if (supportSites.isNotEmpty &&
          categoryController.tabController.length != supportSites.length) {
        final indexedController = Get.find<IndexedController>();
        indexedController.setIndex(indexedController.index.value);
        supportSites = Sites.supportSites;
      }
      return Scaffold(
        appBar: AppBar(
          titleSpacing: 8,
          title: TabBar(
            controller: categoryController.tabController,
            padding: EdgeInsets.zero,
            tabAlignment: TabAlignment.center,
            tabs: supportSites.asMap().entries.map((entry) {
              final index = entry.key;
              final e = entry.value;
              return Tab(
                child: TvFocusable(
                  autofocus: categoryController.tabController.index == index,
                  region: TvRegions.tabs,
                  isEntryPoint: index == 0,
                  onSelect: () =>
                      categoryController.tabController.animateTo(index),
                  borderRadius: AppStyle.radius12,
                  debugLabel: 'category_tab_${e.id}',
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
            labelPadding: AppStyle.edgeInsetsH20,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.label,
          ),
        ),
        body: AnimatedBuilder(
          animation: categoryController.tabController,
          builder: (context, _) {
            final children = supportSites.asMap().entries.map((entry) {
              final index = entry.key;
              final e = entry.value;
              return ExcludeFocus(
                excluding: categoryController.tabController.index != index,
                child: CategoryListView(
                  e.id,
                  key: ValueKey("category_${e.id}"),
                ),
              );
            }).toList();
            if (PlatformUtils.isAndroidTV) {
              return IndexedStack(
                index: categoryController.tabController.index,
                children: children,
              );
            }
            return TabBarView(
              controller: categoryController.tabController,
              children: children,
            );
          },
        ),
      );
    });
  }
}
