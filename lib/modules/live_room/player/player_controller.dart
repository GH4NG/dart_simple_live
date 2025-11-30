import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:auto_orientation_v2/auto_orientation_v2.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:fvp/mdk.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:simple_live_app/app/event_bus.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/app/controller/base_controller.dart';
import 'package:simple_live_app/app/custom_throttle.dart';
import 'package:simple_live_app/app/log.dart';
import 'package:simple_live_app/app/utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';

mixin PlayerMixin {
  GlobalKey globalDanmuKey = GlobalKey();

  /// 播放器实例
  late final Player player = Player();

  /// 初始化播放器并设置参数
  Future<void> initializePlayer() async {
    // 设置音频解码器
    if (AppSettingsController.instance.customPlayerDecoder.value) {
      player.setDecoders(
        MediaType.audio,
        [
          AppSettingsController.instance.audioDecoder.value,
        ],
      );
    }

    // 设置视频解码器
    if (AppSettingsController.instance.customPlayerDecoder.value) {
      player.setDecoders(
        MediaType.video,
        [
          AppSettingsController.instance.videoDecoder.value,
        ],
      );
    }

    player.setDecoders(MediaType.subtitle, []);
  }
}

mixin PlayerStateMixin on PlayerMixin {
  ///音量控制条计时器
  Timer? hideVolumeTimer;

  /// 是否进入桌面端小窗
  RxBool smallWindowState = false.obs;

  /// 是否显示弹幕
  RxBool showDanmakuState = false.obs;

  /// 是否显示控制器
  RxBool showControlsState = false.obs;

  /// 是否显示鼠标光标
  RxBool showCursorState = false.obs;

  /// 是否显示设置窗口
  RxBool showSettingState = false.obs;

  /// 是否显示弹幕设置窗口
  RxBool showDanmakuSettingState = false.obs;

  /// 是否处于锁定控制器状态
  RxBool lockControlsState = false.obs;

  /// 是否处于全屏状态
  RxBool fullScreenState = false.obs;

  /// 显示手势Tip
  RxBool showGestureTip = false.obs;

  /// 手势Tip文本
  RxString gestureTipText = "".obs;

  /// 显示提示底部Tip
  RxBool showBottomTip = false.obs;

  /// 提示底部Tip文本
  RxString bottomTipText = "".obs;

  /// 自动隐藏控制器计时器
  Timer? hideControlsTimer;

  /// 自动隐藏鼠标光标计时器
  Timer? hideCursorTimer;

  /// 自动隐藏提示计时器
  Timer? hideSeekTipTimer;

  /// 是否为竖屏直播间
  var isVertical = false.obs;

  /// 是否自动全屏
  bool autoFullScreen = false;

  /// 视频尺寸
  final Rx<int> width = 0.obs;
  final Rx<int> height = 0.obs;

  Widget? danmakuView;

  var showQualities = false.obs;
  var showLines = false.obs;

  /// 隐藏控制器
  void hideControls() {
    showControlsState.value = false;
    hideControlsTimer?.cancel();
  }

  /// 隐藏鼠标光标
  void hideCursor() {
    showCursorState.value = false;
    hideCursorTimer?.cancel();
  }

  void setLockState() {
    lockControlsState.value = !lockControlsState.value;
    if (lockControlsState.value) {
      showControlsState.value = false;
    } else {
      showControlsState.value = true;
    }
  }

  /// 显示控制器
  void showControls() {
    showControlsState.value = true;
    resetHideControlsTimer();
  }

  /// 显示鼠标光标
  void showCursor() {
    showCursorState.value = true;
    resetHideCursorTimer();
  }

  /// 开始隐藏控制器计时
  /// - 当点击控制器上时功能时需要重新计时
  void resetHideControlsTimer() {
    hideControlsTimer?.cancel();

    hideControlsTimer = Timer(
      const Duration(
        seconds: 5,
      ),
      hideControls,
    );
  }

  /// 开始隐藏鼠标光标计时
  void resetHideCursorTimer() {
    hideCursorTimer?.cancel();

    hideCursorTimer = Timer(
      const Duration(
        seconds: 5,
      ),
      hideCursor,
    );
  }
}

mixin PlayerDanmakuMixin on PlayerStateMixin {
  /// 弹幕控制器
  late DanmakuController? danmakuController;

  void initDanmakuController(DanmakuController e) {
    danmakuController = e;
  }

  void updateDanmuOption(DanmakuOption? option) {
    if (option == null) return;
    danmakuController?.updateOption(option);
  }

  void disposeDanmakuController() {
    danmakuController?.clear();
  }

  void addDanmaku(List<DanmakuContentItem> items) {
    if (!showDanmakuState.value) {
      return;
    }
    for (var item in items) {
      danmakuController?.addDanmaku(item);
    }
  }
}

mixin PlayerSystemMixin on PlayerMixin, PlayerStateMixin, PlayerDanmakuMixin {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final screenBrightness = ScreenBrightness();
  final VolumeController volumeController = VolumeController.instance;
  final pip = Floating();
  StreamSubscription<PiPStatus>? _pipSubscription;

  /// 初始化一些系统状态
  Future<void> initSystem() async {
    if (Platform.isAndroid || Platform.isIOS) {
      volumeController.showSystemUI = false;
    }

    // 屏幕常亮
    //WakelockPlus.enable();

    // 开始隐藏计时
    resetHideControlsTimer();

    // 进入全屏模式
    if (AppSettingsController.instance.autoFullScreen.value) {
      autoFullScreen = true;
    }
  }

  /// 释放一些系统状态
  Future resetSystem() async {
    _pipSubscription?.cancel();
    //pip.dispose();
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );

    await setPortraitOrientation();
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      // 亮度重置,桌面平台可能会报错,暂时不处理桌面平台的亮度
      try {
        await ScreenBrightness.instance.resetApplicationScreenBrightness();
      } catch (e) {
        Log.logPrint(e);
      }
    }

    await WakelockPlus.disable();
  }

  /// 进入全屏
  Future<void> enterFullScreen() async {
    fullScreenState.value = true;
    if (Platform.isAndroid || Platform.isIOS) {
      //全屏
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [],
      );

      if (!isVertical.value) {
        //横屏
        await setLandscapeOrientation();
      }
    } else {
      showCursor();
      resetHideCursorTimer();
      bool isMaximized = await windowManager.isMaximized();
      if (isMaximized) {
        await windowManager.setFullScreen(true);
        await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      }
      await windowManager.setFullScreen(true);
    }
    //danmakuController?.clear();
  }

  /// 退出全屏
  Future<void> exitFull() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );
      await setPortraitOrientation();
    } else {
      hideCursorTimer?.cancel();
      showCursorState.value = true;
      bool isMaximized = await windowManager.isMaximized();
      if (isMaximized) {
        await windowManager.setFullScreen(false);
        await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      }
      await windowManager.setFullScreen(false);
    }
    fullScreenState.value = false;

    //danmakuController?.clear();
  }

  Size? _lastWindowSize;
  Offset? _lastWindowPosition;

  ///小窗模式()
  Future<void> enterSmallWindow() async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      fullScreenState.value = true;
      smallWindowState.value = true;

      // 读取窗口大小
      _lastWindowSize = await windowManager.getSize();
      _lastWindowPosition = await windowManager.getPosition();

      windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      // 获取视频窗口大小
      var videoWidth = width.value;
      var videoHeight = height.value;

      // 横屏还是竖屏
      if (videoHeight > videoWidth) {
        var aspectRatio = videoWidth / videoHeight;
        windowManager.setSize(Size(400, 400 / aspectRatio));
      } else {
        var aspectRatio = videoHeight / videoWidth;
        windowManager.setSize(Size(280 / aspectRatio, 280));
      }

      windowManager.setAlwaysOnTop(true);
    }
  }

  ///退出小窗模式()
  void exitSmallWindow() {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      fullScreenState.value = false;
      smallWindowState.value = false;
      windowManager
        ..setTitleBarStyle(TitleBarStyle.normal)
        ..setSize(_lastWindowSize!)
        ..setPosition(_lastWindowPosition!)
        ..setAlwaysOnTop(false);
      //windowManager.setAlignment(Alignment.center);
    }
  }

  /// 设置横屏
  Future setLandscapeOrientation() async {
    if (await beforeIOS16()) {
      AutoOrientation.landscapeAutoMode();
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  /// 设置竖屏
  Future setPortraitOrientation() async {
    if (await beforeIOS16()) {
      AutoOrientation.portraitAutoMode();
    } else {
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
  }

  /// 是否是IOS16以下
  Future<bool> beforeIOS16() async {
    if (Platform.isIOS) {
      var info = await deviceInfo.iosInfo;
      var version = info.systemVersion;
      var versionInt = int.tryParse(version.split('.').first) ?? 0;
      return versionInt < 16;
    } else {
      return false;
    }
  }

  Future saveScreenshot() async {
    try {
      SmartDialog.showLoading(msg: "正在保存截图");
      //检查相册权限,仅iOS需要
      var permission = await Utils.checkPhotoPermission();
      if (!permission) {
        SmartDialog.showToast("没有相册权限");
        SmartDialog.dismiss(status: SmartStatus.loading);
        return;
      }

      Uint8List? rgbaData = await player.snapshot();
      if (rgbaData == null) {
        SmartDialog.showToast("截图失败,数据为空");
        SmartDialog.dismiss(status: SmartStatus.loading);
        return;
      }

      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        rgbaData,
        width.value,
        height.value,
        ui.PixelFormat.rgba8888,
        completer.complete,
      );
      final ui.Image image = await completer.future;

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        SmartDialog.showToast("截图转换失败");
        SmartDialog.dismiss(status: SmartStatus.loading);
        return;
      }
      final pngBytes = byteData.buffer.asUint8List();

      if (Platform.isIOS || Platform.isAndroid) {
        await ImageGallerySaverPlus.saveImage(
          pngBytes,
          quality: 100,
        );
        SmartDialog.showToast("已保存截图至相册");
      } else {
        //选择保存文件夹
        var path = await FilePicker.platform.saveFile(
          allowedExtensions: ["png"],
          type: FileType.image,
          fileName: "${DateTime.now().millisecondsSinceEpoch}.png",
        );
        if (path == null) {
          SmartDialog.showToast("取消保存");
          SmartDialog.dismiss(status: SmartStatus.loading);
          return;
        }
        await File(path).writeAsBytes(pngBytes);
        SmartDialog.showToast("已保存截图至 $path");
      }
    } catch (e) {
      Log.logPrint(e);
      SmartDialog.showToast("截图失败");
    } finally {
      SmartDialog.dismiss(status: SmartStatus.loading);
    }
  }

  /// 开启小窗播放前弹幕状态
  bool danmakuStateBeforePIP = false;

  Future enablePIP() async {
    if (!Platform.isAndroid) {
      return;
    }
    if (await pip.isPipAvailable == false) {
      SmartDialog.showToast("设备不支持小窗播放");
      return;
    }
    danmakuStateBeforePIP = showDanmakuState.value;
    //关闭并清除弹幕
    if (AppSettingsController.instance.pipHideDanmu.value &&
        danmakuStateBeforePIP) {
      showDanmakuState.value = false;
    }
    danmakuController?.clear();
    //关闭控制器
    showControlsState.value = false;

    //监听事件
    var videoWidth = width.value;
    var videoHeight = height.value;
    Rational ratio = const Rational.landscape();
    if (videoHeight > videoWidth) {
      ratio = const Rational.vertical();
    } else {
      ratio = const Rational.landscape();
    }
    await pip.enable(
      ImmediatePiP(
        aspectRatio: ratio,
      ),
    );

    _pipSubscription ??= pip.pipStatusStream.listen((event) {
      if (event == PiPStatus.disabled) {
        danmakuController?.clear();
        showDanmakuState.value = danmakuStateBeforePIP;
      }
      Log.w(event.toString());
    });
  }
}

mixin PlayerGestureControlMixin
    on PlayerStateMixin, PlayerMixin, PlayerSystemMixin {
  /// 单击显示/隐藏控制器
  void onTap() {
    if (showControlsState.value) {
      hideControls();
    } else {
      showControls();
    }
    if (fullScreenState.value) {
      showCursor();
    }
  }

  //桌面端操控
  void onEnter(PointerEnterEvent event) {
    if (!showControlsState.value) {
      showControls();
    }

    if (fullScreenState.value) {
      showCursor();
    }
  }

  void onExit(PointerExitEvent event) {
    if (showControlsState.value) {
      hideControls();
    }
    if (fullScreenState.value) {
      hideCursor();
    }
  }

  void onHover(PointerHoverEvent event, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final targetPosition = screenHeight * 0.25; // 计算屏幕顶部25%的位置

    if (fullScreenState.value) {
      showCursor();
    }

    if (event.position.dy <= targetPosition ||
        event.position.dy >= targetPosition * 3) {
      if (!showControlsState.value) {
        showControls();
      }
    }
  }

  /// 双击全屏/退出全屏
  void onDoubleTap(TapDownDetails details) {
    if (lockControlsState.value) {
      return;
    }
    if (fullScreenState.value) {
      exitFull();
    } else {
      enterFullScreen();
    }
  }

  bool verticalDragging = false;
  bool leftVerticalDrag = false;
  var _currentVolume = 0.0;
  var _currentBrightness = 1.0;
  var verStartPosition = 0.0;

  DelayedThrottle? throttle;

  /// 竖向手势开始
  Future<void> onVerticalDragStart(DragStartDetails details) async {
    if (lockControlsState.value && fullScreenState.value) {
      return;
    }

    final dy = details.globalPosition.dy;
    // 开始位置必须是中间2/4的位置
    if (dy < Get.height * 0.25 || dy > Get.height * 0.75) {
      return;
    }

    verStartPosition = dy;
    leftVerticalDrag = details.globalPosition.dx < Get.width / 2;

    throttle = DelayedThrottle(200);

    verticalDragging = true;
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      showGestureTip.value = true;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      _currentVolume = await volumeController.getVolume();
    }
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      _currentBrightness = await ScreenBrightness.instance.application;
    }
  }

  /// 竖向手势更新
  Future<void> onVerticalDragUpdate(DragUpdateDetails e) async {
    if (lockControlsState.value && fullScreenState.value) {
      return;
    }
    if (verticalDragging == false) return;
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }
    //String text = "";
    //double value = 0.0;

    Log.logPrint("$verStartPosition/${e.globalPosition.dy}");

    if (leftVerticalDrag) {
      setGestureBrightness(e.globalPosition.dy);
    } else {
      setGestureVolume(e.globalPosition.dy);
    }
  }

  int lastVolume = -1; // it's ok to be -1

  void setGestureVolume(double dy) {
    double value = 0.0;
    double seek;
    if (dy > verStartPosition) {
      value = ((dy - verStartPosition) / (Get.height * 0.5));

      seek = _currentVolume - value;
      if (seek < 0) {
        seek = 0;
      }
    } else {
      value = ((dy - verStartPosition) / (Get.height * 0.5));
      seek = value.abs() + _currentVolume;
      if (seek > 1) {
        seek = 1;
      }
    }
    int volume = _convertVolume((seek * 100).round());
    if (volume == lastVolume) {
      return;
    }
    lastVolume = volume;
    // update UI outside throttle to make it more fluent
    gestureTipText.value = "音量 $volume%";
    throttle?.invoke(() async => await _realSetVolume(volume));
  }

  // 0 to 100, 5 step each
  int _convertVolume(int volume) {
    return (volume / 5).round() * 5;
  }

  Future _realSetVolume(int volume) async {
    Log.logPrint(volume);
    volumeController.setVolume(volume / 100);
  }

  void setGestureBrightness(double dy) {
    double value = 0.0;
    if (dy > verStartPosition) {
      value = ((dy - verStartPosition) / (Get.height * 0.5));

      var seek = _currentBrightness - value;
      if (seek < 0) {
        seek = 0;
      }
      ScreenBrightness.instance.setApplicationScreenBrightness(seek);

      gestureTipText.value = "亮度 ${(seek * 100).toInt()}%";
      Log.logPrint(value);
    } else {
      value = ((dy - verStartPosition) / (Get.height * 0.5));
      var seek = value.abs() + _currentBrightness;
      if (seek > 1) {
        seek = 1;
      }

      ScreenBrightness.instance.setApplicationScreenBrightness(seek);
      gestureTipText.value = "亮度 ${(seek * 100).toInt()}%";
      Log.logPrint(value);
    }
  }

  /// 竖向手势完成
  Future<void> onVerticalDragEnd(DragEndDetails details) async {
    if (lockControlsState.value && fullScreenState.value) {
      return;
    }
    throttle = null;
    verticalDragging = false;
    leftVerticalDrag = false;
    showGestureTip.value = false;
  }
}

class PlayerController extends BaseController
    with
        PlayerMixin,
        PlayerStateMixin,
        PlayerDanmakuMixin,
        PlayerSystemMixin,
        PlayerGestureControlMixin {
  String videoDecoderName = "";
  String audioDecoderName = "";

  @override
  void onInit() {
    initSystem();
    initStream();
    //设置音量
    player.volume = AppSettingsController.instance.playerVolume.value / 100.0;
    super.onInit();
  }

  StreamSubscription? _escSubscription;

  void initStream() {
    int lastBufferProgress = 0;

    player
      ..onEvent((MediaEvent event) {
        if (event.error < 0) {
          errorMsg.value = event.error.toString();
          Log.d(
            "播放器错误: ${event.error}, 详情: ${event.category}-${event.detail}",
          );
          mediaError(event.error.toString());
          return;
        }

        switch (event.category) {
          case "render.video":
            if (event.detail == "1st_frame") {
              Log.d("首帧已渲染");
            }
            break;

          case "decoder.audio":
          case "decoder.video":
            if (event.detail == "open" && event.error < 0) {
              Log.d("解码器打开失败: ${event.category}, stream=${event.detail}");
            } else if (event.error == 0) {
              Log.d("解码器已打开: ${event.category}, name=${event.detail}");
              if (event.category == "decoder.video") {
                videoDecoderName = event.detail;
              } else {
                audioDecoderName = event.detail;
              }
            }
            break;

          case "video":
            if (event.detail != "size") break;
            Log.d("视频帧大小变化");

            final codec = player.mediaInfo.video?.firstOrNull?.codec;
            if (codec == null) {
              Log.d("未获取到视频编码信息");
              break;
            }

            width.value = codec.width;
            height.value = codec.height;
            isVertical.value = height.value > width.value;

            Log.d(
              "视频宽: ${codec.width}, 高: ${codec.height}, 帧率: ${codec.frameRate}",
            );

            if (autoFullScreen) {
              enterFullScreen();
            }
            break;

          case "reader.buffering":
            final progress = event.error.toInt();
            if (progress < lastBufferProgress) lastBufferProgress = 0;
            if (progress - lastBufferProgress >= 20 || progress == 100) {
              lastBufferProgress = (progress ~/ 20) * 20;
              Log.d("缓冲进度: $lastBufferProgress%");
            }
            break;

          case "thread.audio":
          case "thread.video":
            Log.d(
              "线程事件: ${event.category}, 状态=${event.error == 1 ? "启动" : "退出"}",
            );
            break;

          case "snapshot":
            Log.d(
              event.error == 0
                  ? "截图成功: ${event.detail}"
                  : "截图失败: ${event.detail}",
            );
            break;

          case "metadata":
            Log.d("元数据已更新");
            break;

          default:
            Log.d(
              "未知事件: ${event.category}, 详情: ${event.detail}, 错误码: ${event.error}",
            );
            break;
        }
      })
      ..onStateChanged((oldState, newState) {
        Log.d("播放状态变化: $oldState → $newState");
        if (newState == PlaybackState.playing) {
          WakelockPlus.enable();
        } else {
          WakelockPlus.disable();
        }
      });

    _escSubscription = EventBus.instance.listen(EventBus.kEscapePressed, (_) {
      exitFull();
    });
  }

  void disposeStream() {
    _pipSubscription?.cancel();
    _escSubscription?.cancel();
  }

  void mediaEnd() {
    WakelockPlus.disable();
  }

  void mediaError(String error) {
    WakelockPlus.disable();
  }

  void showDebugInfo() {
    final mediaInfo = player.mediaInfo;
    Utils.showBottomSheet(
      title: "播放信息",
      child: ListView(
        children: [
          ListTile(
            title: const Text("解码器信息"),
            subtitle: Text(
              '视频解码器: ${videoDecoderName.isNotEmpty ? videoDecoderName : "未知"}\n'
              '音频解码器: ${audioDecoderName.isNotEmpty ? audioDecoderName : "未知"}',
            ),
            onLongPress: () {
              Clipboard.setData(
                ClipboardData(
                  text:
                      '解码器信息\n视频解码器: ${videoDecoderName.isNotEmpty ? videoDecoderName : "未知"}\n'
                      '音频解码器: ${audioDecoderName.isNotEmpty ? audioDecoderName : "未知"}',
                ),
              );
            },
          ),
          ListTile(
            title: const Text("分辨率"),
            subtitle: Text(
              '${width.value}x${height.value} ${mediaInfo.video?[0].codec.frameRate}FPS',
            ),
            onLongPress: () {
              Clipboard.setData(
                ClipboardData(
                  text:
                      '分辨率\n${width.value}x${height.value} ${mediaInfo.video?[0].codec.frameRate}FPS',
                ),
              );
            },
          ),
          ListTile(
            title: const Text("媒体信息"),
            subtitle: Text(
              '时长: ${mediaInfo.duration} ms\n'
              '码率: ${mediaInfo.bitRate}\n'
              '格式: ${mediaInfo.format}\n'
              '流数量: ${mediaInfo.streams}',
            ),
            onLongPress: () {
              Clipboard.setData(
                ClipboardData(
                  text:
                      '媒体信息\n时长: ${mediaInfo.duration} ms\n码率: ${mediaInfo.bitRate}\n格式: ${mediaInfo.format}\n流数量: ${mediaInfo.streams}',
                ),
              );
            },
          ),
          // 视频轨道
          if (mediaInfo.video != null)
            ...mediaInfo.video!.map(
              (v) => ListTile(
                title: Text("视频轨道 #${v.index}"),
                subtitle: Text(
                  v.toString(),
                ),
                onLongPress: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: "视频轨道 #${v.index}\n${v.toString()}",
                    ),
                  );
                },
              ),
            ),
          // 音频轨道
          if (mediaInfo.audio != null)
            ...mediaInfo.audio!.map(
              (a) => ListTile(
                title: Text("音频轨道 #${a.index}"),
                subtitle: Text(
                  a.toString(),
                ),
                onLongPress: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: "音频轨道 #${a.index}\n${a.toString()}",
                    ),
                  );
                },
              ),
            ),

          // Metadata
          if (mediaInfo.metadata.isNotEmpty)
            ListTile(
              title: const Text("元数据"),
              subtitle: Text(
                mediaInfo.metadata.entries
                    .map((e) => "${e.key}: ${e.value}")
                    .join("\n"),
              ),
              onLongPress: () {
                Clipboard.setData(
                  ClipboardData(
                    text:
                        "元数据\n${mediaInfo.metadata.entries.map((e) => "${e.key}: ${e.value}").join("\n")}",
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Future<void> onClose() async {
    Log.w("播放器关闭");
    if (smallWindowState.value) {
      exitSmallWindow();
    }
    disposeStream();
    disposeDanmakuController();
    await resetSystem();
    player.dispose();
    super.onClose();
  }
}
