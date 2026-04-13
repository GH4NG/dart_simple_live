import 'dart:math' as math;

import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:dpad/dpad.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/app/tv_regions.dart';
import 'package:simple_live_app/modules/live_room/live_room_controller.dart';
import 'package:simple_live_app/modules/live_room/player/player_states.dart';
import 'package:simple_live_app/widgets/net_image.dart';
import 'package:simple_live_app/widgets/tv_focusable.dart';

const Key _tvPlayerKey = ValueKey('tv_live_player');
const Key _tvDanmakuKey = ValueKey('tv_live_danmaku');

class LiveRoomTvPage extends GetView<LiveRoomController> {
  const LiveRoomTvPage({super.key});

  void _clearLocalFocusHistory(BuildContext context) {
    Dpad.clearFocusHistory(context);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loadError.value) {
        return _LiveRoomTvError(controller: controller);
      }

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _clearLocalFocusHistory(context);
            controller.handleTvBackPressed();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: DpadFocusable(
                  autofocus: true,
                  region: TvRegions.liveContent,
                  isEntryPoint: true,
                  debugLabel: 'tv_live_surface',
                  onFocus: () {
                    _clearLocalFocusHistory(context);
                    controller.resetTvOverlayTimer();
                  },
                  onSelect: () {
                    _clearLocalFocusHistory(context);
                    controller.showTvControls();
                  },
                  builder: (context, isFocused, child) =>
                      child ?? const SizedBox(),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildPlayerSurface(),
                      _buildDanmuView(context),
                    ],
                  ),
                ),
              ),
              if (controller.tvOverlayVisible.value)
                Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: _LiveRoomTvHeader(controller: controller),
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      top: MediaQuery.of(context).size.height * 0.74,
                      child: _LiveRoomTvActionBar(
                        controller: controller,
                        visible: true,
                        onFocusActivity: () {
                          _clearLocalFocusHistory(context);
                        },
                        onActionTriggered: controller.resetTvOverlayTimer,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPlayerSurface() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        Obx(() {
          if (!controller.isPlayerInitialized.value) {
            return const SizedBox();
          }

          final (
            boxFit,
            aspectRatio,
          ) = switch (AppSettingsController.instance.scaleMode.value) {
            1 => (BoxFit.fill, null),
            2 => (BoxFit.cover, null),
            3 => (BoxFit.contain, 16 / 9),
            4 => (BoxFit.contain, 4 / 3),
            _ => (BoxFit.contain, null),
          };

          return controller.player.videoWidget(
                _tvPlayerKey,
                aspectRatio,
                boxFit,
                false,
              ) ??
              const SizedBox();
        }),
        _buildBufferingIndicator(),
        Obx(
          () => Visibility(
            visible: !controller.liveStatus.value,
            child: const Center(
              child: Text(
                '未开播',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBufferingIndicator() {
    return Obx(() {
      final showInitialLoading =
          !controller.isPlayerInitialized.value && controller.liveStatus.value;

      return StreamBuilder<PlayerState>(
        stream: controller.player.stateStream,
        initialData: controller.player.lastState,
        builder: (context, snapshot) {
          final showBuffering =
              showInitialLoading || (snapshot.data?.buffering ?? false);

          return IgnorePointer(
            ignoring: !showBuffering,
            child: AnimatedOpacity(
              opacity: showBuffering ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(176),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withAlpha(20)),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '正在缓冲...',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildDanmuView(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return Positioned.fill(
      top: padding.top,
      bottom: padding.bottom,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return Obx(() {
            final option = DanmakuOption(
              fontSize: AppSettingsController.instance.danmuSize.value,
              fontWeight: AppSettingsController.instance.danmuFontWeight.value,
              area: AppSettingsController.instance.danmuArea.value,
              duration: AppSettingsController.instance.danmuSpeed.value,
              strokeWidth:
                  AppSettingsController.instance.danmuStrokeWidth.value,
              lineHeight: AppSettingsController.instance.danmuLineHeight.value,
              safeArea: false,
            );

            return AnimatedOpacity(
              opacity: controller.showDanmakuState.value
                  ? AppSettingsController.instance.danmuOpacity.value
                  : 0,
              duration: const Duration(milliseconds: 100),
              child: ClipRect(
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: DanmakuScreen(
                    key: _tvDanmakuKey,
                    createdController: controller.initDanmakuController,
                    option: option,
                    size: size,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class _LiveRoomTvError extends StatelessWidget {
  final LiveRoomController controller;

  const _LiveRoomTvError({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(18),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Remix.alert_line,
                size: 44,
                color: Colors.white,
              ),
              AppStyle.vGap12,
              const Text(
                '直播间加载失败',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              AppStyle.vGap8,
              Text(
                controller.error?.toString() ?? '未知错误',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withAlpha(180),
                  fontSize: 14,
                ),
              ),
              AppStyle.vGap24,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LiveRoomTvPrimaryButton(
                    label: '复制信息',
                    icon: Remix.file_copy_line,
                    onPressed: controller.copyErrorDetail,
                  ),
                  AppStyle.hGap16,
                  _LiveRoomTvPrimaryButton(
                    label: '刷新',
                    icon: Remix.refresh_line,
                    onPressed: controller.refreshRoom,
                    autofocus: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveRoomTvHeader extends StatelessWidget {
  final LiveRoomController controller;

  const _LiveRoomTvHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return Container(
      padding: EdgeInsets.fromLTRB(24, padding.top + 18, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(215),
            Colors.black.withAlpha(128),
            Colors.transparent,
          ],
        ),
      ),
      child: Obx(() {
        final detail = controller.detail.value;
        return Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withAlpha(36)),
              ),
              child: NetImage(
                detail?.userAvatar ?? '',
                width: 52,
                height: 52,
                borderRadius: 26,
              ),
            ),
            AppStyle.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail?.title ?? '直播间',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppStyle.vGap4,
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          detail?.userName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withAlpha(220),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(24),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          controller.site.name,
                          style: TextStyle(
                            color: Colors.white.withAlpha(220),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _LiveRoomTvActionBar extends StatelessWidget {
  final LiveRoomController controller;
  final bool visible;
  final VoidCallback onFocusActivity;
  final VoidCallback onActionTriggered;

  const _LiveRoomTvActionBar({
    required this.controller,
    required this.visible,
    required this.onFocusActivity,
    required this.onActionTriggered,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = math.min(screenWidth - 48, 780.0);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.black.withAlpha(182),
            border: Border.all(color: Colors.white.withAlpha(26)),
          ),
          child: Obx(
            () => Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                _LiveRoomTvActionButton(
                  label: '刷新',
                  icon: Remix.refresh_line,
                  value: controller.liveStatus.value ? '重载房间' : '重新检测',
                  onPressed: controller.refreshRoom,
                  autofocus: visible,
                  isEntryPoint: true,
                  debugLabel: 'tv_live_refresh',
                  onFocusActivity: onFocusActivity,
                  onSelected: onActionTriggered,
                ),
                _LiveRoomTvActionButton(
                  label: '清晰度',
                  icon: Remix.hd_line,
                  value: controller.currentQualityInfo.value.isEmpty
                      ? '未就绪'
                      : controller.currentQualityInfo.value,
                  onPressed: controller.qualities.isEmpty
                      ? null
                      : controller.showQualitySheet,
                  debugLabel: 'tv_live_quality',
                  onFocusActivity: onFocusActivity,
                  onSelected: onActionTriggered,
                ),
                _LiveRoomTvActionButton(
                  label: '线路',
                  icon: Remix.route_line,
                  value: controller.currentLineInfo.value.isEmpty
                      ? '未就绪'
                      : controller.currentLineInfo.value,
                  onPressed: controller.playUrls.isEmpty
                      ? null
                      : controller.showPlayUrlsSheet,
                  debugLabel: 'tv_live_line',
                  onFocusActivity: onFocusActivity,
                  onSelected: onActionTriggered,
                ),
                _LiveRoomTvActionButton(
                  label: controller.followed.value ? '已关注' : '关注',
                  icon: controller.followed.value
                      ? Remix.heart_fill
                      : Remix.heart_line,
                  value: controller.followed.value ? '取消关注' : '加入列表',
                  onPressed: controller.followed.value
                      ? controller.removeFollowUser
                      : controller.followUser,
                  debugLabel: 'tv_live_follow',
                  onFocusActivity: onFocusActivity,
                  onSelected: onActionTriggered,
                ),
                _LiveRoomTvActionButton(
                  label: '弹幕',
                  icon: controller.showDanmakuState.value
                      ? Remix.chat_1_fill
                      : Remix.chat_off_line,
                  value: controller.showDanmakuState.value ? '开启' : '关闭',
                  onPressed: () {
                    controller.showDanmakuState.value =
                        !controller.showDanmakuState.value;
                  },
                  debugLabel: 'tv_live_danmaku',
                  onFocusActivity: onFocusActivity,
                  onSelected: onActionTriggered,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveRoomTvActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final VoidCallback? onPressed;
  final VoidCallback onFocusActivity;
  final VoidCallback onSelected;
  final bool autofocus;
  final bool isEntryPoint;
  final String debugLabel;

  const _LiveRoomTvActionButton({
    required this.label,
    required this.icon,
    required this.value,
    required this.onPressed,
    required this.onFocusActivity,
    required this.onSelected,
    required this.debugLabel,
    this.autofocus = false,
    this.isEntryPoint = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return TvFocusable(
      enabled: enabled,
      autofocus: autofocus,
      onFocus: () {
        onFocusActivity();
        onSelected();
      },
      region: TvRegions.liveContentControls,
      isEntryPoint: isEntryPoint,
      debugLabel: debugLabel,
      borderRadius: BorderRadius.circular(18),
      onSelect: () {
        onSelected();
        onPressed?.call();
      },
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.45,
        duration: const Duration(milliseconds: 120),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed == null
                ? null
                : () {
                    onSelected();
                    onPressed?.call();
                  },
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              width: 132,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withAlpha(28),
                    Colors.white.withAlpha(14),
                  ],
                ),
                border: Border.all(color: Colors.white.withAlpha(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withAlpha(180),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveRoomTvPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool autofocus;

  const _LiveRoomTvPrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      autofocus: autofocus,
      onSelect: onPressed,
      region: TvRegions.liveContentControls,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
