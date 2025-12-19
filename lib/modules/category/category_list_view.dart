import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';

import 'package:get/get.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/modules/category/category_list_controller.dart';
import 'package:simple_live_app/routes/app_navigation.dart';
import 'package:simple_live_app/widgets/keep_alive_wrapper.dart';
import 'package:simple_live_app/widgets/net_image.dart';
import 'package:simple_live_app/widgets/shadow_card.dart';
import 'package:simple_live_core/simple_live_core.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class CategoryListView extends StatelessWidget {
  final String tag;
  const CategoryListView(this.tag, {super.key});
  CategoryListController get controller =>
      Get.find<CategoryListController>(tag: tag);
  @override
  Widget build(BuildContext context) {
    return KeepAliveWrapper(
      child: EasyRefresh.builder(
        refreshOnStart: true,
        controller: controller.easyRefreshController,
        onRefresh: controller.refreshData,
        header: const MaterialHeader(),
        onLoad: controller.loadData,
        childBuilder: (context, physics) {
          return Obx(() {
            return CustomScrollView(
              physics: physics,
              controller: controller.scrollController,
              slivers: [
                for (var item in controller.list)
                  SliverStickyHeader(
                    header: Container(
                      padding: AppStyle.edgeInsetsV8.copyWith(left: 4),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    sliver: Obx(() {
                      return SliverPadding(
                        padding: AppStyle.edgeInsetsV8,
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.of(context).size.width ~/ 80,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final subItem = item.showAll.value
                                  ? item.children[index]
                                  : (index < item.take15.length
                                        ? item.take15[index]
                                        : null);

                              if (subItem != null) {
                                return buildSubCategory(subItem, controller);
                              } else if (!item.showAll.value &&
                                  index == item.take15.length) {
                                return buildShowMore(item, controller);
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                            childCount: item.showAll.value
                                ? item.children.length
                                : item.take15.length + 1,
                          ),
                        ),
                      );
                    }),
                  ),
              ],
            );
          });
        },
      ),
    );
  }

  Widget buildSubCategory(
    LiveSubCategory item,
    CategoryListController controller,
  ) {
    return ShadowCard(
      onTap: () {
        AppNavigator.toCategoryDetail(site: controller.site, category: item);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NetImage(
            item.pic ?? "",
            width: 40,
            height: 40,
            borderRadius: 8,
          ),
          AppStyle.vGap4,
          Text(
            item.name,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget buildShowMore(
    AppLiveCategory item,
    CategoryListController controller,
  ) {
    return ShadowCard(
      onTap: () {
        item.showAll.value = true;
      },
      child: const Center(
        child: Text(
          "显示全部",
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
