import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:simple_live_app/app/controller/base_controller.dart';
import 'package:simple_live_app/app/log.dart';
import 'package:simple_live_app/app/utils.dart';
import 'package:simple_live_app/routes/route_path.dart';

class SyncScanQRController extends BaseController {
  final MobileScannerController scannerController = MobileScannerController();
  bool pause = false;
  Future<void> onBarcodeDetected(BarcodeCapture capture) async {
    if (pause || capture.barcodes.isEmpty) {
      return;
    }

    final barcode = capture.barcodes.first;
    final code = barcode.rawValue ?? '';
    Log.d('Scan result: $code');

    pause = true;
    // 扫码成功后暂停摄像头
    await scannerController.stop();
    // 处理扫码结果
    if (code.isEmpty) {
      pause = false;
      await _resumeScanning();
      return;
    }

    if (code.length == 5) {
      Get.offAndToNamed(RoutePath.kRemoteSyncRoom, arguments: code);
      return;
    }

    final addressList = code.split(';');
    if (addressList.length >= 2) {
      //弹窗选择
      await showPickerAddress(addressList);
    } else {
      Get.back(result: code);
    }
  }

  void toggleTorch() {
    scannerController.toggleTorch();
  }

  void switchCamera() {
    scannerController.switchCamera();
  }

  Future<void> _resumeScanning() async {
    pause = false;
    await scannerController.start();
  }

  Future<void> showPickerAddress(List<String> addressList) async {
    SmartDialog.showToast("扫描到多个地址，请选择一个连接");
    var address = await Utils.showBottomSheet(
      title: '请选择地址',
      child: ListView.builder(
        itemBuilder: (_, i) {
          return ListTile(
            title: Text(addressList[i]),
            onTap: () {
              Get.back(result: addressList[i]);
            },
          );
        },
        itemCount: addressList.length,
      ),
    );
    if (address != null && address.isNotEmpty) {
      Get.back(result: address);
    } else {
      await _resumeScanning();
    }
  }

  @override
  void onClose() {
    scannerController.dispose();

    super.onClose();
  }
}
