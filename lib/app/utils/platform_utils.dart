import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class PlatformUtils {
  //  基础平台判断
  static bool get isAndroid => Platform.isAndroid;

  static bool get isIOS => Platform.isIOS;

  static bool get isWindows => Platform.isWindows;

  static bool get isLinux => Platform.isLinux;

  static bool get isMacOS => Platform.isMacOS;

  static bool get isMobile => isAndroid || isIOS;

  static bool get isDesktop => isWindows || isLinux || isMacOS;

  // Android TV
  static bool _isAndroidTV = false;

  static bool get isAndroidTV => _isAndroidTV;

  //  Firebase
  static bool get isSupportFirebase => isMacOS || isIOS || isAndroid;

  static Future<void> init() async {
    if (!isAndroid) {
      _isAndroidTV = false;
      return;
    }

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    final features = androidInfo.systemFeatures
        .map((e) => e.toLowerCase())
        .toSet();

    const tvFeatures = {
      'android.software.leanback',
      'android.hardware.type.television',
      'android.software.live_tv',
    };

    _isAndroidTV = features.any(tvFeatures.contains);
  }
}
