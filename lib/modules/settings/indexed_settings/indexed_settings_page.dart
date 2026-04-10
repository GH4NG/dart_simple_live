import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/constant.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/modules/settings/indexed_settings/indexed_settings_controller.dart';
import 'package:simple_live_app/widgets/settings/settings_card.dart';

class IndexedSettingsPage extends GetView<IndexedSettingsController> {
  const IndexedSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("主页设置"),
      ),
      body: ListView(
        padding: AppStyle.edgeInsetsA12,
        children: [
          Padding(
            padding: AppStyle.edgeInsetsA12.copyWith(top: 0),
            child: Text(
              "主页排序 (长按拖动排序，重启后生效)",
              style: Get.textTheme.titleSmall,
            ),
          ),
          SettingsCard(
            child: Obx(
              () {
                final homeOrder = [
                  ...controller.homeSort,
                  ...controller.allHomeKeys.where(
                    (key) => !controller.homeSort.contains(key),
                  ),
                ];
                return ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorder: controller.updateHomeSort,
                  children: List.generate(
                    homeOrder.length,
                    (index) {
                      final key = homeOrder[index];
                      final e = Constant.allHomePages[key]!;
                      final isMine = key == "user";
                      return ListTile(
                        key: ValueKey(key),
                        title: Text(e.title),
                        visualDensity: VisualDensity.compact,
                        leading: Icon(e.iconData),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: controller.isHomeEnabled(key),
                              onChanged: isMine
                                  ? null
                                  : (value) => controller.toggleHomeVisible(
                                      key,
                                      value ?? false,
                                    ),
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: AppStyle.edgeInsetsA12.copyWith(top: 24),
            child: Text(
              "平台排序 (长按拖动排序，重启后生效)",
              style: Get.textTheme.titleSmall,
            ),
          ),
          SettingsCard(
            child: Obx(
              () {
                final siteOrder = [
                  ...controller.siteSort.where(
                    (key) => key != Constant.kTwitch,
                  ),
                  ...controller.allSiteKeys.where(
                    (key) => !controller.siteSort.contains(key),
                  ),
                ];
                return ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorder: controller.updateSiteSort,
                  children: List.generate(
                    siteOrder.length,
                    (index) {
                      final key = siteOrder[index];
                      final e = Sites.allSites[key]!;
                      return ListTile(
                        key: ValueKey(e.id),
                        visualDensity: VisualDensity.compact,
                        title: Text(e.name),
                        leading: Image.asset(
                          e.logo,
                          width: 24,
                          height: 24,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: controller.isSiteEnabled(key),
                              onChanged: (value) =>
                                  controller.toggleSiteVisible(
                                    key,
                                    value ?? false,
                                  ),
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
