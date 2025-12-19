import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/widgets/settings/settings_card.dart';
import 'package:simple_live_app/widgets/settings/settings_menu.dart';
import 'package:simple_live_app/widgets/settings/settings_switch.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PlayerSettingsPage extends GetView<AppSettingsController> {
  const PlayerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("播放器设置")),
      body: ListView(
        padding: AppStyle.edgeInsetsA12,
        children: [
          SettingsCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPlayerTypeMenu(),
                AppStyle.divider,
                Obx(() {
                  switch (controller.playerType.value) {
                    case 0:
                      return _MpvSettings(controller);
                    case 1:
                      return _MdkSettings(controller);
                    default:
                      return const SizedBox.shrink();
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerTypeMenu() {
    return Obx(
      () => SettingsMenu<int>(
        title: "播放器内核",
        subtitle: "切换后下次播放生效",
        value: controller.playerType.value,
        valueMap: const {
          0: "MPV",
          1: "MDK",
        },
        onChanged: controller.setPlayerType,
      ),
    );
  }
}

class _MdkSettings extends StatelessWidget {
  final AppSettingsController c;
  const _MdkSettings(this.c);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Padding(
            padding: AppStyle.edgeInsetsA12.copyWith(top: 0),
            child: Text.rich(
              TextSpan(
                text:
                    "请勿随意修改以下设置，除非你知道自己在做什么。\n"
                    "在修改以下设置前，你应该先查阅 ",
                children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        launchUrlString(
                          "https://github.com/wang-bin/mdk-sdk/wiki/Decoders",
                        );
                      },
                      child: const Text(
                        "mdk-sdk/wiki",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          SettingsSwitch(
            title: "Android Tunnel",
            subtitle:
                "AMediacodec/MediaCodec 解码器直接输出到 SurfaceTexture 表面，不使用 OpenGL。可能更高效，但某些功能不支持。",
            value: c.mdkAndroidTunnel.value,
            onChanged: c.setMdkAndroidTunnel,
          ),
          SettingsSwitch(
            title: "自定义解码器",
            subtitle: "开启后可手动选择解码器",
            value: c.customPlayerDecoder.value,
            onChanged: c.setCustomPlayerDecoder,
          ),
          if (c.customPlayerDecoder.value) ...[
            AppStyle.divider,
            SettingsMenu(
              title: "视频解码器",
              value: c.videoDecoder.value,
              valueMap: c.videoDecoders,
              onChanged: c.setVideoDecoder,
            ),
            AppStyle.divider,
            SettingsMenu(
              title: "音频解码器",
              value: c.audioDecoder.value,
              valueMap: c.audioDecoders,
              onChanged: c.setAudioDecoder,
            ),
          ],
        ],
      ),
    );
  }
}

class _MpvSettings extends StatelessWidget {
  final AppSettingsController c;
  const _MpvSettings(this.c);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          SettingsSwitch(
            title: "硬件解码",
            subtitle: "开启后可降低CPU占用",
            value: c.hardwareDecode.value,
            onChanged: c.setHardwareDecode,
          ),
          AppStyle.divider,
          SettingsSwitch(
            title: "兼容模式",
            subtitle: "解决部分设备播放黑屏问题",
            value: c.playerCompatMode.value,
            onChanged: c.setPlayerCompatMode,
          ),
          AppStyle.divider,
          Padding(
            padding: AppStyle.edgeInsetsA12.copyWith(top: 0),
            child: Text.rich(
              TextSpan(
                text:
                    "以下高级设置直接对应 MPV 的底层参数。\n"
                    "错误配置可能导致黑屏、卡顿或无法播放。\n请先查阅 ",
                children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        launchUrlString(
                          "https://mpv.io/manual/stable/#video-output-drivers",
                        );
                      },
                      child: const Text(
                        "MPV的文档",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          AppStyle.divider,
          SettingsSwitch(
            title: "自定义输出驱动与硬件加速",
            subtitle: "高级设置，非必要请勿修改",
            value: c.customPlayerOutput.value,
            onChanged: c.setCustomPlayerOutput,
          ),
          if (c.customPlayerOutput.value) ...[
            AppStyle.divider,
            SettingsMenu(
              title: "视频输出 (--vo)",
              value: c.videoOutputDriver.value,
              valueMap: c.videoOutputs,
              onChanged: c.setVideoOutputDriver,
            ),
            AppStyle.divider,
            SettingsMenu(
              title: "音频输出 (--ao)",
              value: c.audioOutputDriver.value,
              valueMap: c.audioOutputs,
              onChanged: c.setAudioOutputDriver,
            ),
            AppStyle.divider,
            SettingsMenu(
              title: "硬件解码 (--hwdec)",
              value: c.videoHardwareDecoder.value,
              valueMap: c.hardwareDecoders,
              onChanged: c.setVideoHardwareDecoder,
            ),
          ],
        ],
      ),
    );
  }
}
