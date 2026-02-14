import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/constant.dart';
import 'package:simple_live_app/app/log.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/services/local_storage_service.dart';

class AppSettingsController extends GetxController {
  static AppSettingsController get instance =>
      Get.find<AppSettingsController>();

  /// 可选播放器日志等级
  /// LogLevel 0: 错误 1: 警告 2: 简略 3: 详细 4: 调试（隐藏） 5: 全部（隐藏）
  static const Map<int, String> playerLogLevelMap = {
    0: "错误",
    1: "警告",
    2: "简略",
    3: "详细",
    // 以下两个级别被MPV官方支持，但是输出内容过于冗长，暂时隐藏
    // 4: "调试",
    // 5: "全部",
  };

  /// 缩放模式
  RxInt scaleMode = 0.obs;

  /// 播放器类型 0: MPV, 1: MDK
  RxInt playerType = 0.obs;

  var themeMode = 0.obs;

  var firstRun = false;

  var dbVer = 0;

  @override
  void onInit() {
    themeMode.value = LocalStorageService.instance.getValue(
      LocalStorageService.kThemeMode,
      0,
    );
    firstRun = LocalStorageService.instance.getValue(
      LocalStorageService.kFirstRun,
      true,
    );
    danmuSize.value = LocalStorageService.instance.getValue(
      LocalStorageService.kDanmuSize,
      16.0,
    );
    danmuOpacity.value = LocalStorageService.instance.getValue(
      LocalStorageService.kDanmuOpacity,
      1.0,
    );
    danmuArea.value = LocalStorageService.instance.getValue(
      LocalStorageService.kDanmuArea,
      0.8,
    );
    danmuSpeed.value = LocalStorageService.instance.getValue(
      LocalStorageService.kDanmuSpeed,
      10.0,
    );
    danmuEnable.value = LocalStorageService.instance.getValue(
      LocalStorageService.kDanmuEnable,
      true,
    );
    danmuStrokeWidth.value = LocalStorageService.instance.getValue(
      LocalStorageService.kDanmuStrokeWidth,
      2.0,
    );
    danmuLineHeight.value = LocalStorageService.instance.getValue(
      LocalStorageService.kDanmuLineHeight,
      2.0,
    );
    danmuTopMargin.value = LocalStorageService.instance.getValue(
      LocalStorageService.kDanmuTopMargin,
      0.0,
    );
    danmuBottomMargin.value = LocalStorageService.instance.getValue(
      LocalStorageService.kDanmuBottomMargin,
      0.0,
    );
    danmuFontWeight.value = LocalStorageService.instance.getValue(
      LocalStorageService.kDanmuFontWeight,
      FontWeight.normal.index,
    );

    hardwareDecode.value = LocalStorageService.instance.getValue(
      LocalStorageService.kHardwareDecode,
      true,
    );

    chatTextSize.value = LocalStorageService.instance.getValue(
      LocalStorageService.kChatTextSize,
      14.0,
    );

    chatTextGap.value = LocalStorageService.instance.getValue(
      LocalStorageService.kChatTextGap,
      4.0,
    );

    chatBubbleStyle.value = LocalStorageService.instance.getValue(
      LocalStorageService.kChatBubbleStyle,
      false,
    );

    qualityLevel.value = LocalStorageService.instance.getValue(
      LocalStorageService.kQualityLevel,
      2,
    );
    qualityLevelCellular.value = LocalStorageService.instance.getValue(
      LocalStorageService.kQualityLevelCellular,
      1,
    );

    autoExitEnable.value = LocalStorageService.instance.getValue(
      LocalStorageService.kAutoExitEnable,
      false,
    );

    autoExitDuration.value = LocalStorageService.instance.getValue(
      LocalStorageService.kAutoExitDuration,
      60,
    );

    roomAutoExitDuration.value = LocalStorageService.instance.getValue(
      LocalStorageService.kRoomAutoExitDuration,
      60,
    );

    playerCompatMode.value = LocalStorageService.instance.getValue(
      LocalStorageService.kPlayerCompatMode,
      false,
    );

    playerAutoPause.value = LocalStorageService.instance.getValue(
      LocalStorageService.kPlayerAutoPause,
      false,
    );

    playerForceHttps.value = LocalStorageService.instance.getValue(
      LocalStorageService.kPlayerForceHttps,
      false,
    );

    douyinHlsFirst.value = LocalStorageService.instance.getValue(
      LocalStorageService.kDouyinHlsFirst,
      false,
    );

    autoFullScreen.value = LocalStorageService.instance.getValue(
      LocalStorageService.kAutoFullScreen,
      false,
    );

    playerShowSuperChat.value = LocalStorageService.instance.getValue(
      LocalStorageService.kPlayerShowSuperChat,
      true,
    );

    showKeyframe.value = LocalStorageService.instance.getValue(
      LocalStorageService.kShowKeyframe,
      false,
    );

    // ignore: invalid_use_of_protected_member
    shieldList.value = LocalStorageService.instance.shieldBox.values.toSet();

    scaleMode.value = LocalStorageService.instance.getValue(
      LocalStorageService.kPlayerScaleMode,
      0,
    );

    playerType.value = LocalStorageService.instance.getValue(
      LocalStorageService.kPlayerType,
      0,
    );

    playerVolume.value = LocalStorageService.instance.getValue(
      LocalStorageService.kPlayerVolume,
      100.0,
    );
    pipHideDanmu.value = LocalStorageService.instance.getValue(
      LocalStorageService.kPIPHideDanmu,
      true,
    );

    styleColor.value = LocalStorageService.instance.getValue(
      LocalStorageService.kStyleColor,
      0xff3498db,
    );

    isDynamic.value = LocalStorageService.instance.getValue(
      LocalStorageService.kIsDynamic,
      false,
    );

    bilibiliLoginTip.value = LocalStorageService.instance.getValue(
      LocalStorageService.kBilibiliLoginTip,
      true,
    );

    playerBufferSize.value = LocalStorageService.instance.getValue(
      LocalStorageService.kPlayerBufferSize,
      32,
    );

    logEnable.value = LocalStorageService.instance.getValue(
      LocalStorageService.kLogEnable,
      false,
    );
    if (logEnable.value) {
      Log.initWriter();
    }

    playerLogEnable.value = LocalStorageService.instance.getValue(
      LocalStorageService.kPlayerLogEnable,
      false,
    );

    playerLogLevel.value = LocalStorageService.instance.getValue(
      LocalStorageService.kPlayerLogLevel,
      0,
    );

    customPlayerOutput.value = LocalStorageService.instance.getValue(
      LocalStorageService.kCustomPlayerOutput,
      false,
    );

    videoOutputDriver.value = LocalStorageService.instance.getValue(
      LocalStorageService.kVideoOutputDriver,
      Platform.isAndroid ? "mediacodec_embed" : "libmpv",
    );

    audioOutputDriver.value = LocalStorageService.instance.getValue(
      LocalStorageService.kAudioOutputDriver,
      Platform.isAndroid
          ? "audiotrack"
          : Platform.isLinux
          ? "pulse"
          : Platform.isWindows
          ? "wasapi"
          : Platform.isIOS
          ? "audiounit"
          : Platform.isMacOS
          ? "coreaudio"
          : "sdl",
    );

    videoHardwareDecoder.value = LocalStorageService.instance.getValue(
      LocalStorageService.kVideoHardwareDecoder,
      Platform.isAndroid ? "mediacodec" : "auto",
    );

    customPlayerDecoder.value = LocalStorageService.instance.getValue(
      LocalStorageService.kCustomPlayerDecoder,
      false,
    );

    mdkAndroidTunnel.value = LocalStorageService.instance.getValue(
      LocalStorageService.kMdkAndroidTunnel,
      false,
    );

    videoDecoder.value = LocalStorageService.instance.getValue(
      LocalStorageService.kVideoDecoder,
      "FFmpeg",
    );

    audioDecoder.value = LocalStorageService.instance.getValue(
      LocalStorageService.kAudioDecoder,
      "FFmpeg",
    );

    autoUpdateFollowEnable.value = LocalStorageService.instance.getValue(
      LocalStorageService.kAutoUpdateFollowEnable,
      true,
    );

    autoUpdateFollowDuration.value = LocalStorageService.instance.getValue(
      LocalStorageService.kUpdateFollowDuration,
      10,
    );

    updateFollowThreadCount.value = LocalStorageService.instance.getValue(
      LocalStorageService.kUpdateFollowThreadCount,
      4,
    );

    dbVer = LocalStorageService.instance.getValue(
      LocalStorageService.kHiveDbVer,
      10708,
    );

    followSortMethod.value = SortMethodStore.fromStore(
      LocalStorageService.instance.getValue(
        LocalStorageService.kFollowSortMethod,
        SortMethod.watchDuration.storeValue,
      ),
    );

    followStyleNotGrid.value = LocalStorageService.instance.getValue(
      LocalStorageService.kFollowStyleNotGrid,
      true,
    );

    initSiteSort();
    initHomeSort();
    initDecoders();
    super.onInit();
  }

  void initSiteSort() {
    var sort = LocalStorageService.instance
        .getValue(
          LocalStorageService.kSiteSort,
          Sites.allSites.keys.join(","),
        )
        .split(",");
    //如果数量与allSites的数量不一致，将缺失的添加上
    if (sort.length != Sites.allSites.length) {
      var keys = Sites.allSites.keys.toList();
      for (var i = 0; i < keys.length; i++) {
        if (!sort.contains(keys[i])) {
          sort.add(keys[i]);
        }
      }
    }

    siteSort.value = sort;
  }

  void initHomeSort() {
    var sort = LocalStorageService.instance
        .getValue(
          LocalStorageService.kHomeSort,
          Constant.allHomePages.keys.join(","),
        )
        .split(",");
    //如果数量与allSites的数量不一致，将缺失的添加上
    if (sort.length != Constant.allHomePages.length) {
      var keys = Constant.allHomePages.keys.toList();
      for (var i = 0; i < keys.length; i++) {
        if (!sort.contains(keys[i])) {
          sort.add(keys[i]);
        }
      }
    }

    homeSort.value = sort;
  }

  void setNoFirstRun() {
    LocalStorageService.instance.setValue(LocalStorageService.kFirstRun, false);
  }

  void changeTheme() {
    Get.dialog(
      RadioGroup(
        groupValue: themeMode.value,
        onChanged: (e) {
          Get.back();
          setTheme(e ?? 0);
        },
        child: const SimpleDialog(
          title: Text("设置主题"),
          children: [
            RadioListTile<int>(
              title: Text("跟随系统"),
              value: 0,
            ),
            RadioListTile<int>(
              title: Text("浅色模式"),
              value: 1,
            ),
            RadioListTile<int>(
              title: Text("深色模式"),
              value: 2,
            ),
          ],
        ),
      ),
    );
  }

  void setTheme(int i) {
    themeMode.value = i;
    var mode = ThemeMode.values[i];

    LocalStorageService.instance.setValue(LocalStorageService.kThemeMode, i);
    Get.changeThemeMode(mode);
  }

  var hardwareDecode = true.obs;
  void setHardwareDecode(bool e) {
    hardwareDecode.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kHardwareDecode,
      e,
    );
  }

  var chatTextSize = 14.0.obs;
  void setChatTextSize(double e) {
    chatTextSize.value = e;
    LocalStorageService.instance.setValue(LocalStorageService.kChatTextSize, e);
  }

  var chatTextGap = 4.0.obs;
  void setChatTextGap(double e) {
    chatTextGap.value = e;
    LocalStorageService.instance.setValue(LocalStorageService.kChatTextGap, e);
  }

  var chatBubbleStyle = false.obs;
  void setChatBubbleStyle(bool e) {
    chatBubbleStyle.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kChatBubbleStyle,
      e,
    );
  }

  var danmuSize = 16.0.obs;
  void setDanmuSize(double e) {
    danmuSize.value = e;
    LocalStorageService.instance.setValue(LocalStorageService.kDanmuSize, e);
  }

  var danmuSpeed = 10.0.obs;
  void setDanmuSpeed(double e) {
    danmuSpeed.value = e;
    LocalStorageService.instance.setValue(LocalStorageService.kDanmuSpeed, e);
  }

  var danmuArea = 1.0.obs;
  void setDanmuArea(double e) {
    danmuArea.value = e;
    LocalStorageService.instance.setValue(LocalStorageService.kDanmuArea, e);
  }

  var danmuOpacity = 1.0.obs;
  void setDanmuOpacity(double e) {
    danmuOpacity.value = e;
    LocalStorageService.instance.setValue(LocalStorageService.kDanmuOpacity, e);
  }

  var danmuEnable = true.obs;
  void setDanmuEnable(bool e) {
    danmuEnable.value = e;
    LocalStorageService.instance.setValue(LocalStorageService.kDanmuEnable, e);
  }

  var danmuStrokeWidth = 2.0.obs;
  void setDanmuStrokeWidth(double e) {
    danmuStrokeWidth.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kDanmuStrokeWidth,
      e,
    );
  }

  var danmuLineHeight = 2.0.obs;
  void setDanmuLineHeight(double e) {
    danmuLineHeight.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kDanmuLineHeight,
      e,
    );
  }

  var danmuFontWeight = 4.obs;
  void setDanmuFontWeight(int e) {
    danmuFontWeight.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kDanmuFontWeight,
      e,
    );
  }

  var qualityLevel = 1.obs;
  void setQualityLevel(int level) {
    qualityLevel.value = level;
    LocalStorageService.instance.setValue(
      LocalStorageService.kQualityLevel,
      level,
    );
  }

  var qualityLevelCellular = 1.obs;
  void setQualityLevelCellular(int level) {
    qualityLevelCellular.value = level;
    LocalStorageService.instance.setValue(
      LocalStorageService.kQualityLevelCellular,
      level,
    );
  }

  var autoExitEnable = false.obs;
  void setAutoExitEnable(bool e) {
    autoExitEnable.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kAutoExitEnable,
      e,
    );
  }

  var autoExitDuration = 60.obs;
  void setAutoExitDuration(int e) {
    autoExitDuration.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kAutoExitDuration,
      e,
    );
  }

  var roomAutoExitDuration = 60.obs;
  void setRoomAutoExitDuration(int e) {
    roomAutoExitDuration.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kRoomAutoExitDuration,
      e,
    );
  }

  var playerCompatMode = false.obs;
  void setPlayerCompatMode(bool e) {
    playerCompatMode.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kPlayerCompatMode,
      e,
    );
  }

  var playerBufferSize = 32.obs;
  void setPlayerBufferSize(int e) {
    playerBufferSize.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kPlayerBufferSize,
      e,
    );
  }

  var playerAutoPause = false.obs;
  void setPlayerAutoPause(bool e) {
    playerAutoPause.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kPlayerAutoPause,
      e,
    );
  }

  var autoFullScreen = false.obs;
  void setAutoFullScreen(bool e) {
    autoFullScreen.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kAutoFullScreen,
      e,
    );
  }

  var playerShowSuperChat = true.obs;

  var showKeyframe = false.obs;
  void setShowKeyframe(bool e) {
    showKeyframe.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kShowKeyframe,
      e,
    );
  }

  void setPlayerShowSuperChat(bool e) {
    playerShowSuperChat.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kPlayerShowSuperChat,
      e,
    );
  }

  RxSet<String> shieldList = <String>{}.obs;
  void addShieldList(String e) {
    shieldList.add(e);
    LocalStorageService.instance.shieldBox.put(e, e);
  }

  void removeShieldList(String e) {
    shieldList.remove(e);
    LocalStorageService.instance.shieldBox.delete(e);
  }

  Future clearShieldList() async {
    shieldList.clear();
    await LocalStorageService.instance.shieldBox.clear();
  }

  void setScaleMode(int value) {
    scaleMode.value = value;
    LocalStorageService.instance.setValue(
      LocalStorageService.kPlayerScaleMode,
      value,
    );
  }

  void setPlayerType(int value) {
    playerType.value = value;
    LocalStorageService.instance.setValue(
      LocalStorageService.kPlayerType,
      value,
    );
  }

  void setThemeMode(int value) {
    themeMode.value = value;
    var mode = ThemeMode.values[value];

    LocalStorageService.instance.setValue(
      LocalStorageService.kThemeMode,
      value,
    );
    Get.changeThemeMode(mode);
  }

  RxList<String> siteSort = RxList<String>();
  void setSiteSort(List<String> e) {
    siteSort.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kSiteSort,
      siteSort.join(","),
    );
  }

  RxList<String> homeSort = RxList<String>();
  void setHomeSort(List<String> e) {
    homeSort.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kHomeSort,
      homeSort.join(","),
    );
  }

  Rx<double> playerVolume = 100.0.obs;
  void setPlayerVolume(double value) {
    playerVolume.value = value;
    LocalStorageService.instance.setValue(
      LocalStorageService.kPlayerVolume,
      value,
    );
  }

  var pipHideDanmu = true.obs;
  void setPIPHideDanmu(bool e) {
    pipHideDanmu.value = e;
    LocalStorageService.instance.setValue(LocalStorageService.kPIPHideDanmu, e);
  }

  var styleColor = 0xff3498db.obs;
  void setStyleColor(int e) {
    styleColor.value = e;
    LocalStorageService.instance.setValue(LocalStorageService.kStyleColor, e);
  }

  var isDynamic = false.obs;
  void setIsDynamic(bool e) {
    isDynamic.value = e;
    LocalStorageService.instance.setValue(LocalStorageService.kIsDynamic, e);
  }

  var danmuTopMargin = 0.0.obs;
  void setDanmuTopMargin(double e) {
    danmuTopMargin.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kDanmuTopMargin,
      e,
    );
  }

  var danmuBottomMargin = 0.0.obs;
  void setDanmuBottomMargin(double e) {
    danmuBottomMargin.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kDanmuBottomMargin,
      e,
    );
  }

  var bilibiliLoginTip = true.obs;
  void setBiliBiliLoginTip(bool e) {
    bilibiliLoginTip.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kBilibiliLoginTip,
      e,
    );
  }

  var logEnable = false.obs;
  void setLogEnable(bool e) {
    logEnable.value = e;
    LocalStorageService.instance.setValue(LocalStorageService.kLogEnable, e);
  }

  var playerLogEnable = false.obs;
  void setPlayerLogEnable(bool e) {
    playerLogEnable.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kPlayerLogEnable,
      e,
    );
  }

  var playerLogLevel = 0.obs;
  void setPlayerLogLevel(int e) {
    playerLogLevel.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kPlayerLogLevel,
      e,
    );
  }

  var customPlayerOutput = false.obs;
  void setCustomPlayerOutput(bool e) {
    customPlayerOutput.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kCustomPlayerOutput,
      e,
    );
  }

  var videoOutputDriver = "".obs;
  void setVideoOutputDriver(String e) {
    videoOutputDriver.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kVideoOutputDriver,
      e,
    );
  }

  var audioOutputDriver = "".obs;
  void setAudioOutputDriver(String e) {
    audioOutputDriver.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kAudioOutputDriver,
      e,
    );
  }

  var videoHardwareDecoder = "".obs;
  void setVideoHardwareDecoder(String e) {
    videoHardwareDecoder.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kVideoHardwareDecoder,
      e,
    );
  }

  var customPlayerDecoder = false.obs;
  void setCustomPlayerDecoder(bool e) {
    customPlayerDecoder.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kCustomPlayerDecoder,
      e,
    );
  }

  var mdkAndroidTunnel = false.obs;
  void setMdkAndroidTunnel(bool e) {
    mdkAndroidTunnel.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kMdkAndroidTunnel,
      e,
    );
  }

  var videoDecoder = "".obs;
  void setVideoDecoder(String e) {
    videoDecoder.value = e;
    LocalStorageService.instance.setValue(LocalStorageService.kVideoDecoder, e);
  }

  var audioDecoder = "".obs;
  void setAudioDecoder(String e) {
    audioDecoder.value = e;
    LocalStorageService.instance.setValue(LocalStorageService.kAudioDecoder, e);
  }

  var autoUpdateFollowEnable = false.obs;
  void setAutoUpdateFollowEnable(bool e) {
    autoUpdateFollowEnable.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kAutoUpdateFollowEnable,
      e,
    );
  }

  var autoUpdateFollowDuration = 10.obs;
  void setAutoUpdateFollowDuration(int e) {
    autoUpdateFollowDuration.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kUpdateFollowDuration,
      e,
    );
  }

  var updateFollowThreadCount = 4.obs;
  void setUpdateFollowThreadCount(int e) {
    updateFollowThreadCount.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kUpdateFollowThreadCount,
      e,
    );
  }

  var playerForceHttps = false.obs;
  void setPlayerForceHttps(bool e) {
    playerForceHttps.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kPlayerForceHttps,
      e,
    );
  }

  var videoDecoders = <String, String>{}.obs;
  var audioDecoders = <String, String>{}.obs;

  var videoOutputs = <String, String>{}.obs;
  var audioOutputs = <String, String>{}.obs;
  var hardwareDecoders = <String, String>{}.obs;

  void initDecoders() {
    videoDecoders.value = {
      "FFmpeg": "FFmpeg (通用软件解码器)",
    };

    if (Platform.isWindows) {
      videoDecoders.addAll({
        "MFT:d3d=11": "MFT (D3D11)",
        "MFT:d3d=12": "MFT (D3D12)",
        "MFT": "MFT (Auto)",
        "D3D11": "D3D11",
        "D3D12": "D3D12",
        "DXVA": "DXVA",
        "CUDA": "CUDA",
        "NVDEC": "NVDEC",
        "QSV": "QSV",
        "dav1d": "dav1d (AV1)",
        "hap": "hap",
        "R3D": "R3D",
        "BRAW": "BRAW",
      });
    } else if (Platform.isMacOS || Platform.isIOS) {
      videoDecoders.addAll({
        "VT": "VT (VideoToolbox)",
        "VideoToolbox": "VideoToolbox",
        "dav1d": "dav1d (AV1)",
        "hap": "hap",
        "R3D": "R3D",
        "BRAW": "BRAW",
      });
    } else if (Platform.isAndroid) {
      videoDecoders.addAll({
        "AMediaCodec": "AMediaCodec",
        "MediaCodec": "MediaCodec",
        "dav1d": "dav1d (AV1)",
      });
    } else if (Platform.isLinux) {
      videoDecoders.addAll({
        "VAAPI": "VAAPI",
        "VDPAU": "VDPAU",
        "CUDA": "CUDA",
        "NVDEC": "NVDEC",
        "V4L2M2M": "V4L2M2M",
        "rkmpp": "rkmpp (RockChip)",
        "MMAL": "MMAL (Raspberry Pi)",
        "CedarX": "CedarX (Allwinner)",
        "dav1d": "dav1d (AV1)",
        "hap": "hap",
      });
    }

    audioDecoders.value = {
      "FFmpeg": "FFmpeg (通用音频解码器)",
      "MFT": Platform.isWindows ? "Windows MFT" : "",
      "AMediaCodec": Platform.isAndroid ? "Android AMediaCodec" : "",
    }..removeWhere((key, value) => value.isEmpty);

    videoOutputs.value = {
      "gpu": "gpu",
      "gpu-next": "gpu-next",
      "xv": "xv (X11 only)",
      "x11": "x11 (X11 only)",
      "vdpau": "vdpau (X11 only)",
      "direct3d": "direct3d (Windows only)",
      "sdl": "sdl",
      "dmabuf-wayland": "dmabuf-wayland",
      "vaapi": "vaapi",
      "null": "null",
      "libmpv": "libmpv",
      "mediacodec_embed": "mediacodec_embed (Android only)",
    };

    audioOutputs.value = {
      "auto": "auto (Not available)",
      "null": "null (No audio output)",
      "pulse": "pulse (Linux, uses PulseAudio)",
      "pipewire": "pipewire (Linux, via Pulse compatibility or native)",
      "alsa": "alsa (Linux only)",
      "oss": "oss (Linux only)",
      "jack": "jack (Linux/macOS, low-latency audio)",
      "directsound": "directsound (Windows only)",
      "wasapi": "wasapi (Windows only)",
      "winmm": "winmm (Windows only, legacy API)",
      "audiounit": "audiounit (iOS only)",
      "coreaudio": "coreaudio (macOS only)",
      "opensles": "opensles (Android only)",
      "audiotrack": "audiotrack (Android only)",
      "aaudio": "aaudio (Android only)",
      "pcm": "pcm (Cross-platform)",
      "sdl": "sdl (Cross-platform, via SDL library)",
      "openal": "openal (Cross-platform, OpenAL backend)",
      "libao": "libao (Cross-platform, uses libao library)",
    };

    hardwareDecoders.value = {
      'auto': '启用任意可用解码器',
      'auto-safe': '启用最佳解码器',
      'auto-copy': '启用带拷贝功能的最佳解码器',
      'd3d11va': 'DirectX11 (windows8 及以上)',
      'd3d11va-copy': 'DirectX11 (windows8 及以上) (非直通)',
      'videotoolbox': 'VideoToolbox (macOS / iOS)',
      'videotoolbox-copy': 'VideoToolbox (macOS / iOS) (非直通)',
      'vaapi': 'VAAPI (Linux)',
      'vaapi-copy': 'VAAPI (Linux) (非直通)',
      'nvdec': 'NVDEC (NVIDIA独占)',
      'nvdec-copy': 'NVDEC (NVIDIA独占) (非直通)',
      'drm': 'DRM (Linux)',
      'drm-copy': 'DRM (Linux) (非直通)',
      'vulkan': 'Vulkan (全平台) (实验性)',
      'vulkan-copy': 'Vulkan (全平台) (实验性) (非直通)',
      'dxva2': 'DXVA2 (Windows7 及以上)',
      'dxva2-copy': 'DXVA2 (Windows7 及以上) (非直通)',
      'vdpau': 'VDPAU (Linux)',
      'vdpau-copy': 'VDPAU (Linux) (非直通)',
      'mediacodec': 'MediaCodec (Android)',
      'mediacodec-copy': 'MediaCodec (Android) (非直通)',
      'cuda': 'CUDA (NVIDIA独占) (过时)',
      'cuda-copy': 'CUDA (NVIDIA独占) (过时) (非直通)',
      'crystalhd': 'CrystalHD (全平台) (过时)',
      'rkmpp': 'Rockchip MPP (仅部分Rockchip芯片)',
    };

    String savedDecoder = videoDecoder.value;
    if (!videoDecoders.containsKey(savedDecoder)) {
      setVideoDecoder("FFmpeg");
    }
  }

  var douyinHlsFirst = false.obs;
  void setDouyinHlsFirst(bool e) {
    douyinHlsFirst.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kDouyinHlsFirst,
      e,
    );
  }

  var followSortMethod = SortMethod.watchDuration.obs;
  void setFollowSortMethod(SortMethod e) {
    followSortMethod.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kFollowSortMethod,
      e.storeValue,
    );
  }

  // 关注样式是否卡片化
  var followStyleNotGrid = true.obs;
  void setFollowStyleNotGrid(bool e) {
    followStyleNotGrid.value = e;
    LocalStorageService.instance.setValue(
      LocalStorageService.kFollowStyleNotGrid,
      e,
    );
  }
}
