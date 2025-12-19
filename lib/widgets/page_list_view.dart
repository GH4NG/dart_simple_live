import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simple_live_app/app/controller/base_controller.dart';
import 'package:simple_live_app/widgets/status/app_empty_widget.dart';
import 'package:simple_live_app/widgets/status/app_error_widget.dart';
import 'package:simple_live_app/widgets/status/app_loading_widget.dart';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

typedef IndexedWidgetBuilder = Widget Function(BuildContext context, int index);

class PageListView extends StatelessWidget {
  final BasePageController pageController;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final EdgeInsets? padding;
  final bool refreshOnStart;
  final Function()? onLoginSuccess;
  final bool showPageLoading;
  final bool showPCRefreshButton;
  const PageListView({
    required this.itemBuilder,
    required this.pageController,
    this.padding,
    this.refreshOnStart = false,
    this.showPageLoading = false,
    this.showPCRefreshButton = true,
    this.separatorBuilder,
    this.onLoginSuccess,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        EasyRefresh.builder(
          header: const MaterialHeader(),
          footer: const ClassicFooter(
            position: IndicatorPosition.locator,
            infiniteOffset: 10,
          ),
          controller: pageController.easyRefreshController,
          refreshOnStart: refreshOnStart,
          onLoad: () async {
            if (pageController.canLoadMore.value) {
              await pageController.loadData();
            }
          },
          onRefresh: pageController.refreshData,
          childBuilder: (context, physics) {
            return Obx(
              () => ListView.separated(
                controller: pageController.scrollController,
                physics: physics,
                padding: padding,
                itemCount: pageController.list.length,
                itemBuilder: itemBuilder,
                separatorBuilder:
                    separatorBuilder ?? (c, i) => const SizedBox(),
              ),
            );
          },
        ),
        if ((Platform.isWindows || Platform.isLinux || Platform.isMacOS) &&
            showPCRefreshButton)
          Positioned(
            bottom: 12,
            right: 12,
            child: Obx(
              () => Visibility(
                visible:
                    pageController.canLoadMore.value &&
                    !pageController.pageLoading.value &&
                    !pageController.pageEmpty.value,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Get.theme.cardColor.withAlpha(200),
                    elevation: 4,
                  ),
                  onPressed: pageController.refreshData,
                  icon: const Icon(Icons.refresh),
                ),
              ),
            ),
          ),
        Offstage(
          offstage: !pageController.pageEmpty.value,
          child: AppEmptyWidget(
            onRefresh: pageController.refreshData,
          ),
        ),
        Offstage(
          offstage: !(showPageLoading && pageController.pageLoading.value),
          child: const AppLoadingWidget(),
        ),
        Offstage(
          offstage: !pageController.pageError.value,
          child: AppErrorWidget(
            errorMsg: pageController.errorMsg.value,
            onRefresh: pageController.refreshData,
          ),
        ),
      ],
    );
  }
}
