import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
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

  @override
  void onInit() {
    loadLogFiles();
    super.onInit();
  }

  void setLogEnable(dynamic e) {
    AppSettingsController.instance.setLogEnable(e);
    Future.delayed(const Duration(milliseconds: 100), loadLogFiles);
  }

  void setFirebaseEnable(bool e) {
    AppSettingsController.instance.setFirebaseEnable(e);
  }

  void setPlayerLogEnable(dynamic e) {
    AppSettingsController.instance.setPlayerLogEnable(e);
  }

  void setPlayerLogLevel(dynamic e) {
    AppSettingsController.instance.setPlayerLogLevel(e);
  }

  Future<void> loadLogFiles() async {
    var supportDir = await getApplicationSupportDirectory();
    var logDir = Directory("${supportDir.path}/logs");
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
    var logDir = Directory("${supportDir.path}/logs");
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

  Future<void> deleteLogFile(LogFileModel item) async {
    if (AppSettingsController.instance.logEnable.value) {
      if (logFiles.isNotEmpty && logFiles.first.path == item.path) {
        SmartDialog.showToast("日志正在写入，无法删除最新日志");
        return;
      }
    }

    final confirm = await Utils.showAlertDialog(
      "是否删除日志 ${item.name}?",
      title: "删除日志",
    );
    if (!confirm) return;

    try {
      var file = File(item.path);
      if (file.existsSync()) {
        file.deleteSync();
      }
      logFiles.removeWhere((e) => e.path == item.path);
      SmartDialog.showToast("删除成功");
    } catch (e) {
      SimpleLiveLogger().e(e);
      SmartDialog.showToast("删除失败: $e");
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
      SimpleLiveLogger().e(e);
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
      SimpleLiveLogger().e(e);
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
