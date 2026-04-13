import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/app/tv_regions.dart';
import 'package:simple_live_app/app/utils/platform_utils.dart';
import 'package:simple_live_app/modules/search/search_controller.dart';
import 'package:simple_live_app/modules/search/search_list_view.dart';
import 'package:simple_live_app/widgets/tv_focusable.dart';

class SearchPage extends GetView<AppSearchController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          controller: controller.searchController,
          autofocus: !PlatformUtils.isAndroidTV,
          decoration: InputDecoration(
            hintText: "搜点什么吧",
            border: OutlineInputBorder(
              borderRadius: AppStyle.radius24,
            ),
            contentPadding: AppStyle.edgeInsetsH12,
            prefixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.arrow_back),
                ),
                Obx(
                  () => DropdownButton<int>(
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 0,
                        child: Text("房间"),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text("主播"),
                      ),
                    ],
                    value: controller.searchMode.value,
                    onChanged: (e) {
                      controller.searchMode.value = e ?? 0;
                      controller.doSearch();
                    },
                  ),
                ),
                AppStyle.hGap8,
              ],
            ),
            suffixIcon: IconButton(
              onPressed: controller.doSearch,
              icon: const Icon(Icons.search),
            ),
          ),
          onSubmitted: (e) {
            controller.doSearch();
          },
        ),
        bottom: TabBar(
          controller: controller.tabController,
          padding: EdgeInsets.zero,
          tabAlignment: TabAlignment.center,
          tabs: Sites.supportSites.asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;
            return Tab(
              child: TvFocusable(
                autofocus: controller.tabController.index == index,
                region: TvRegions.tabs,
                isEntryPoint: index == 0,
                onSelect: () => controller.tabController.animateTo(index),
                borderRadius: AppStyle.radius12,
                debugLabel: 'search_tab_${e.id}',
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
        animation: controller.tabController,
        builder: (context, _) {
          controller.index = controller.tabController.index;
          final children = Sites.supportSites.asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;
            return ExcludeFocus(
              excluding: controller.tabController.index != index,
              child: SearchListView(e.id),
            );
          }).toList();
          if (PlatformUtils.isAndroidTV) {
            return IndexedStack(
              index: controller.tabController.index,
              children: children,
            );
          }
          return TabBarView(
            controller: controller.tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: children,
          );
        },
      ),
    );
  }
}
