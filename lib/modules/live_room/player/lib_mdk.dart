import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:fvp/mdk.dart' as mdk;
import 'package:fvp/fvp.dart' as fvp;
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/app/log.dart';
import 'package:simple_live_app/modules/live_room/live_room_controller.dart';
import 'package:simple_live_app/modules/live_room/player/base_player.dart';
import 'package:simple_live_app/modules/live_room/player/player_controls.dart';

class LibMDK extends BasePlayer {
  static void register() {
    final logLevel =
        {
          0: "error", // 错误
          1: "warning", // 警告
          2: "debug", // 简略
          3: "all", // 所有日志
          -1: "off", // 关闭日志
        }[AppSettingsController.instance.playerLogLevel.value] ??
        "off"; // 默认 "off"

    final finalLogLevel = AppSettingsController.instance.playerLogEnable.value
        ? logLevel
        : "off";

    fvp.registerWith(
      options: {
        'platforms': ['windows', 'macos', 'linux', 'android', 'ios'],
        'lowLatency': 2,
        'global': {'log': finalLogLevel},
        'tunnel': AppSettingsController.instance.mdkAndroidTunnel.value,
      },
    );
  }

  mdk.Player? _player;
  final StreamController<PlayerState> _stateController =
      StreamController.broadcast();
  final ValueNotifier<int?> _textureId = ValueNotifier(null);

  @override
  Stream<PlayerState> get stateStream => _stateController.stream;

  @override
  Future<void> init() async {
    if (_player != null) {
      _player?.dispose();
      _player = null;
    }

    register();

    _player = mdk.Player();

    WakelockPlus.enable();
    setupPlayerDebugInfoSubscription();
  }

  @override
  Widget? videoWidget(
    Key key,
    double? aspectRatio,
    BoxFit fit,
  ) {
    final controller = Get.find<LiveRoomController>();

    return ValueListenableBuilder<int?>(
      key: key,
      valueListenable: _textureId,
      builder: (context, id, _) {
        if (id == null || id < 0) {
          return const SizedBox.expand(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return StreamBuilder<PlayerState>(
          stream: stateStream,
          initialData: lastState,
          builder: (context, snapshot) {
            final state = snapshot.data ?? lastState;
            final hasVideoSize =
                (state.width ?? 0) > 0 && (state.height ?? 0) > 0;

            final double preferredRatio =
                aspectRatio ??
                (hasVideoSize
                    ? state.width!.toDouble() / state.height!.toDouble()
                    : 16 / 9);

            return SizedBox.expand(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: AspectRatio(
                      aspectRatio: preferredRatio,
                      child: Texture(
                        textureId: id,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                  playerControls(context, controller),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Future<void> dispose() async {
    WakelockPlus.disable();
    _textureId.value = null;
    _player?.dispose();
    _player = null;
    _stateController.close();
    _textureId.dispose();
  }

  @override
  Future<void> loadVideo(
    String url, {
    Map<String, String>? headers,
    bool play = true,
  }) async {
    final player = _player;
    if (player == null) return;

    if (player.state != mdk.PlaybackState.stopped) {
      player
        ..state = mdk.PlaybackState.stopped
        ..waitFor(mdk.PlaybackState.stopped);
    }

    if (headers != null && headers.isNotEmpty) {
      final headerString = headers.entries
          .map((e) => "${e.key}: ${e.value}")
          .join("\r\n");
      player.setProperty("avio.headers", headerString);
    }

    final settings = AppSettingsController.instance;
    if (settings.customPlayerDecoder.value) {
      final vDec = settings.videoDecoder.value;
      if (vDec.isNotEmpty && vDec != "FFmpeg") {
        player.videoDecoders = [vDec];
      }
      final aDec = settings.audioDecoder.value;
      if (aDec.isNotEmpty && aDec != "FFmpeg") {
        player.audioDecoders = [aDec];
      }
    }

    player
      ..media = url
      ..prepare()
      ..state = mdk.PlaybackState.playing;

    lastState = lastState.copyWith(playlist: [url]);
    _stateController.add(lastState);

    final id = await player.updateTexture();
    if (id < 0) {
      SimpleLiveLogger().w('MDK texture invalid: $id');
      _textureId.value = null;
      return;
    }
    _textureId.value = id;

    if (play) {
      await this.play();
    }
  }

  @override
  Future<void> play() async {
    _player?.state = mdk.PlaybackState.playing;
  }

  @override
  Future<void> setVolume(double volume) async {
    final player = _player;
    if (player == null) return;
    final normalized = (volume.clamp(0, 100)) / 100;
    player.volume = normalized;
  }

  @override
  Future<void> pause() async {
    _player?.state = mdk.PlaybackState.paused;
  }

  @override
  Future<void> stop() async {
    _player?.state = mdk.PlaybackState.stopped;
    _textureId.value = null;
  }

  @override
  Future<void> playOrPause() async {
    final player = _player;
    if (player == null) return;
    if (player.state == mdk.PlaybackState.playing) {
      await pause();
    } else {
      await play();
    }
  }

  @override
  Future<Uint8List?> snapshot() async {
    final width = lastState.width;
    final height = lastState.height;
    final Uint8List? rgbaData = await _player?.snapshot(
      width: width,
      height: height,
    );
    if (rgbaData == null || width == null || height == null) {
      return null;
    }
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgbaData,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    final ui.Image image = await completer.future;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> setupPlayerDebugInfoSubscription() async {
    _player?.onEvent((mdk.MediaEvent event) {
      // SimpleLiveLogger().d("MDK: ${event.toString()}");

      switch (event.category) {
        case "render.video":
          if (event.detail == "1st_frame") {
            SimpleLiveLogger().d("MDK: 首帧已渲染");
          }

        case "video":
          if (event.detail != "size") break;
          SimpleLiveLogger().d("MDK: 视频帧大小变化");

          final codec = _player?.mediaInfo.video?.firstOrNull?.codec;
          if (codec == null) {
            SimpleLiveLogger().d("MDK: 未获取到视频编码信息");
            break;
          }

          final videoWidth = codec.width;
          final videoHeight = codec.height;
          final mediaInfo = _player?.mediaInfo;
          final videoTrack = mediaInfo?.video?[0].codec;
          final audioTrack = mediaInfo?.audio?[0].codec;
          final isVertical = videoHeight > 0 && videoWidth > 0
              ? videoHeight > videoWidth
              : null;
          lastState = lastState.copyWith(
            width: videoWidth,
            height: videoHeight,
            isVertical: isVertical,
            fps: codec.frameRate,
            videoParams: videoTrack.toString(),
            audioParams: audioTrack.toString(),
          );
          _stateController.add(lastState);
          SimpleLiveLogger().d(
            "MDK: 视频尺寸变化: ${videoWidth}x$videoHeight, fps=${codec.frameRate}, isVertical=$isVertical",
          );
          break;
      }
    });
  }
}
