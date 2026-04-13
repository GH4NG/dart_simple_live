import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/tv_regions.dart';
import 'package:simple_live_app/widgets/tv_focusable.dart';

import 'package:simple_live_app/modules/indexed/indexed_controller.dart';

class IndexedPage extends GetView<IndexedController> {
  const IndexedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          body: Row(
            children: [
              Visibility(
                visible: orientation == Orientation.landscape,
                child: Obx(
                  () => NavigationRail(
                    selectedIndex: controller.index.value,
                    onDestinationSelected: controller.setIndex,
                    labelType: NavigationRailLabelType.none,
                    destinations: controller.items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return NavigationRailDestination(
                        icon: TvFocusable(
                          autofocus: controller.index.value == index,
                          region: TvRegions.sidebar,
                          isEntryPoint: index == 0,
                          onSelect: () => controller.setIndex(index),
                          borderRadius: AppStyle.radius12,
                          debugLabel: 'sidebar_${item.title}',
                          child: Padding(
                            padding: AppStyle.edgeInsetsA8,
                            child: Icon(item.iconData),
                          ),
                        ),
                        label: Text(item.title),
                        padding: AppStyle.edgeInsetsV8,
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                child: Obx(
                  () => DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        left: orientation == Orientation.landscape
                            ? BorderSide(
                                color: Colors.grey.withAlpha(50),
                                width: 1,
                              )
                            : BorderSide.none,
                      ),
                    ),
                    child: IndexedStack(
                      index: controller.index.value,
                      children: controller.pages,
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Visibility(
            visible: orientation == Orientation.portrait,
            child: Obx(
              () => NavigationBar(
                selectedIndex: controller.index.value,
                onDestinationSelected: controller.setIndex,
                height: 56,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                destinations: controller.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return NavigationDestination(
                    icon: TvFocusable(
                      autofocus: controller.index.value == index,
                      region: TvRegions.sidebar,
                      isEntryPoint: index == 0,
                      onSelect: () => controller.setIndex(index),
                      borderRadius: AppStyle.radius12,
                      debugLabel: 'bottom_nav_${item.title}',
                      child: Padding(
                        padding: AppStyle.edgeInsetsA8,
                        child: Icon(item.iconData),
                      ),
                    ),
                    label: item.title,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
