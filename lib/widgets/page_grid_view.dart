import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simple_live_app/app/controller/base_controller.dart';
import 'package:simple_live_app/widgets/status/app_empty_widget.dart';
import 'package:simple_live_app/widgets/status/app_error_widget.dart';
import 'package:simple_live_app/widgets/status/app_loading_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

class PageGridView extends StatelessWidget {
  final BasePageController pageController;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsets? padding;
  final bool refreshOnStart;
  final Function()? onLoginSuccess;
  final bool showPageLoading;
  final double crossAxisSpacing, mainAxisSpacing;
  final int crossAxisCount;
  final bool showPCRefreshButton;
  const PageGridView({
    required this.itemBuilder,
    required this.pageController,
    this.padding,
    this.refreshOnStart = false,
    this.showPageLoading = false,
    this.onLoginSuccess,
    this.crossAxisSpacing = 0.0,
    this.mainAxisSpacing = 0.0,
    this.showPCRefreshButton = true,
    required this.crossAxisCount,
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
              () => MasonryGridView.count(
                padding: padding,
                itemCount: pageController.list.length,
                itemBuilder: itemBuilder,
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
                physics: physics,
                controller: pageController.scrollController,
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
