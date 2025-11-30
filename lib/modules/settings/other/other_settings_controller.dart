import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/app/controller/base_controller.dart';
import 'package:simple_live_app/app/log.dart';
import 'package:path/path.dart' as p;
import 'package:simple_live_app/app/utils.dart';
import 'package:simple_live_app/services/local_storage_service.dart';

class OtherSettingsController extends BaseController {
  RxList<LogFileModel> logFiles = <LogFileModel>[].obs;

  static const String customDecoderKey = "Custom";

  RxString customVideoDecoder = "".obs;
  RxString displayVideoDecoder = "".obs;

  var videoDecoders = <String, String>{}.obs;
  var audioDecoders = <String, String>{}.obs;

  @override
  void onInit() {
    loadLogFiles();
    initDecoders();
    super.onInit();
  }

  void initDecoders() {
    videoDecoders.value = {
      "FFmpeg": "FFmpeg (通用软件解码器)",
      customDecoderKey: "自定义解码器...",
    };

    if (Platform.isWindows) {
      videoDecoders.addAll({
        "MFT:d3d=11": "D3D11 (MFT D3D11)",
        "MFT:d3d=12": "D3D12 (MFT D3D12)",
        "D3D11": "D3D11 (FFmpeg D3D11)",
        "D3D12": "D3D12 (FFmpeg D3D12)",
        "DXVA": "DXVA (旧版支持)",
        "QSV": "QSV (Intel QuickSync)",
        "CUDA": "CUDA (NVIDIA GPU)",
        "NVDEC": "NVDEC (NVIDIA专用)",
        "VAAPI": "VAAPI",
        "hap": "hap",
      });
    } else if (Platform.isMacOS || Platform.isIOS) {
      videoDecoders.addAll({
        "VT": "VT",
        "VideoToolbox": "VideoToolbox",
        "hap": "hap (MacOS Only)",
      });
    } else if (Platform.isAndroid) {
      videoDecoders.addAll({
        "AMediaCodec": "AMediaCodec",
        "MediaCodec": "MediaCodec",
      });
    } else if (Platform.isLinux) {
      videoDecoders.addAll({
        "CUDA": "CUDA (NVIDIA GPU)",
        "VAAPI": "VAAPI (Intel/AMD GPU)",
        "VDPAU": "VDPAU (NVIDIA)",
        "NVDEC": "NVDEC (NVIDIA专用)",
        "rkmpp": "rkmpp (RockChip)",
        "V4L2M2M": "V4L2M2M (视频硬件解码API)",
        "hap": "hap",
      });
    }

    audioDecoders.value = {
      "FFmpeg": "FFmpeg (通用音频解码器)",
      "MFT": Platform.isWindows ? "Windows MFT解码器" : "",
      "AMediaCodec": Platform.isAndroid ? "Android AMediaCodec" : "",
    }..removeWhere((key, value) => value.isEmpty);

    String savedDecoder = AppSettingsController.instance.videoDecoder.value;
    if (videoDecoders.containsKey(savedDecoder) &&
        savedDecoder != customDecoderKey) {
      displayVideoDecoder.value = savedDecoder;
    } else if (savedDecoder.isNotEmpty) {
      customVideoDecoder.value = savedDecoder;
      displayVideoDecoder.value = customDecoderKey;
      videoDecoders[customDecoderKey] = "自定义解码器 (${customVideoDecoder.value})";
    } else {
      String defaultDecoder = "FFmpeg";
      displayVideoDecoder.value = defaultDecoder;
      AppSettingsController.instance.setVideoDecoder(defaultDecoder);
    }
  }

  void handleVideoDecoderSelection(String selection) {
    if (selection == customDecoderKey) {
      showCustomDecoderDialog();
    } else {
      displayVideoDecoder.value = selection;
      AppSettingsController.instance.setVideoDecoder(selection);
    }
  }

  void editCustomDecoder() {
    showCustomDecoderDialog();
  }

  void showCustomDecoderDialog() {
    TextEditingController textController = TextEditingController(
      text: customVideoDecoder.value,
    );

    Get.dialog(
      AlertDialog(
        title: const Text("输入自定义解码器"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: "解码器字符串",
                hintText: "例如: FFmpeg:hwaccel=cuda:hwcontext=cuda",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "格式: DecoderName:key1=value1:key2=value2",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text("取消")),
          TextButton(
            onPressed: () {
              String input = textController.text.trim();
              if (input.isNotEmpty) {
                customVideoDecoder.value = input;
                videoDecoders[customDecoderKey] =
                    "自定义解码器 (${customVideoDecoder.value})";
                displayVideoDecoder.value = customDecoderKey;
                AppSettingsController.instance.setVideoDecoder(input);
                Get.back();
              } else {
                SmartDialog.showToast("请输入有效的解码器字符串");
              }
            },
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }

  void setLogEnable(dynamic e) {
    AppSettingsController.instance.setLogEnable(e);
    if (e) {
      Log.initWriter();
      Future.delayed(const Duration(milliseconds: 100), loadLogFiles);
    } else {
      Log.disposeWriter();
    }
  }

  Future<void> loadLogFiles() async {
    var supportDir = await getApplicationSupportDirectory();
    var logDir = Directory("${supportDir.path}/log");
    if (!logDir.existsSync()) {
      await logDir.create();
    }
    logFiles.clear();
    await logDir.list().forEach((element) {
      var file = element as File;
      var name = p.basename(file.path);
      var time = file.lastModifiedSync();
      var size = file.lengthSync();
      logFiles.add(LogFileModel(name, file.path, time, size));
    });
    //logFiles 名称倒序
    logFiles.sort((a, b) => b.time.compareTo(a.time));
  }

  Future<void> cleanLog() async {
    if (AppSettingsController.instance.logEnable.value) {
      SmartDialog.showToast("请先关闭日志记录");
      return;
    }

    var supportDir = await getApplicationSupportDirectory();
    var logDir = Directory("${supportDir.path}/log");
    if (logDir.existsSync()) {
      await logDir.delete(recursive: true);
    }
    loadLogFiles();
  }

  Future<void> shareLogFile(LogFileModel item) async {
    final params = ShareParams(
      files: [XFile(item.path)],
      text: '分享日志文件',
    );

    await SharePlus.instance.share(params);
  }

  Future<void> saveLogFile(LogFileModel item) async {
    var filePath = await FilePicker.platform.saveFile(
      allowedExtensions: ['log'],
      type: FileType.custom,
      fileName: item.name,
    );
    if (filePath != null) {
      var file = File(item.path);
      await file.copy(filePath);
      SmartDialog.showToast("保存成功");
    }
  }

  Future<void> exportConfig() async {
    try {
      // 组装数据
      var data = {
        "type": "simple_live",
        "platform": Platform.operatingSystem,
        "version": 1,
        "time": DateTime.now().millisecondsSinceEpoch,
        "config": LocalStorageService.instance.settingsBox.toMap(),
        "shield": LocalStorageService.instance.shieldBox.toMap(),
      };

      var bytes = Uint8List.fromList(utf8.encode(jsonEncode(data)));

      // FilePicker 直接写入
      var inlineSave = Platform.isAndroid || Platform.isIOS || kIsWeb;

      var path = await FilePicker.platform.saveFile(
        allowedExtensions: ['json'],
        type: FileType.custom,
        fileName: "simple_live_config.json",
        bytes: inlineSave ? bytes : null,
      );

      if (path == null && !kIsWeb) {
        SmartDialog.showToast("保存取消");
        return;
      }

      // 桌面平台需要手动写入
      if (!inlineSave && path != null) {
        await File(path).writeAsBytes(bytes);
      }

      SmartDialog.showToast("保存成功");
    } catch (e) {
      Log.logPrint(e);
      SmartDialog.showToast("导出失败:$e");
    }
  }

  Future<void> importConfig() async {
    try {
      var file = await FilePicker.platform.pickFiles(
        allowedExtensions: ['json'],
        type: FileType.custom,
      );
      if (file == null) {
        return;
      }
      var filePath = file.files.single.path!;
      var data = jsonDecode(await File(filePath).readAsString());
      if (data["type"] != "simple_live") {
        SmartDialog.showToast("不支持的配置文件");
        return;
      }
      // 检查platform
      if (data["platform"] != Platform.operatingSystem &&
          !await Utils.showAlertDialog("导入配置文件平台不匹配,是否继续导入?", title: "平台不匹配")) {
        return;
      }
      LocalStorageService.instance.settingsBox.clear();
      LocalStorageService.instance.shieldBox.clear();
      LocalStorageService.instance.settingsBox.putAll(data["config"]);
      LocalStorageService.instance.shieldBox.putAll(
        data["shield"].cast<String, String>(),
      );
      SmartDialog.showToast("导入成功,重启生效");
    } catch (e) {
      Log.logPrint(e);
      SmartDialog.showToast("导入失败:$e");
    }
  }

  void resetDefaultConfig() {
    Utils.showAlertDialog("是否重置所有配置为默认值?").then((value) {
      if (value) {
        LocalStorageService.instance.settingsBox.clear();
        LocalStorageService.instance.shieldBox.clear();
        SmartDialog.showToast("重置成功,重启生效");
      }
    });
  }
}

class LogFileModel {
  late String name;
  late String path;
  late DateTime time;
  late int size;
  LogFileModel(this.name, this.path, this.time, this.size);
}
