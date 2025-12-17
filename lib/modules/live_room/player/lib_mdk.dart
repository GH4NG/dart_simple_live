import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fvp/mdk.dart' as mdk;
import 'package:fvp/fvp.dart' as fvp;
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/app/log.dart';
import 'package:simple_live_app/modules/live_room/player/base_player.dart';

class LibMDK extends BasePlayer {
  static void register() {
    final logLevel =
        {
          0: "Error", // 错误
          1: "Warning", // 警告
          2: "Debug", // 简略
          3: "All", // 所有日志
          -1: "off", // 关闭日志
        }[AppSettingsController.instance.playerLogLevel.value] ??
        "off"; // 默认 "off"

    final finalLogLevel = AppSettingsController.instance.playerLogEnable.value
        ? logLevel
        : "off";

    fvp.registerWith(
      options: {
        'global': {'log': finalLogLevel},
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

    setupPlayerDebugInfoSubscription();
  }

  @override
  Widget? videoWidget(
    Key key,
    double? aspectRatio,
    BoxFit fit,
  ) {
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
              child: Align(
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: preferredRatio,
                  child: Texture(
                    textureId: id,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Future<void> dispose() async {
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
      ..loop = 0;

    lastState = lastState.copyWith(playlist: [url]);

    final ret = await player.prepare();
    if (ret < 0) {
      Log.w('MDK prepare failed: $ret');
      return;
    }

    final id = await player.updateTexture();
    if (id < 0) {
      Log.w('MDK texture invalid: $id');
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
    return await _player?.snapshot();
  }

  Future<void> setupPlayerDebugInfoSubscription() async {
    _player?.onEvent((mdk.MediaEvent event) {
      // Log.d("MDK: ${event.toString()}");

      switch (event.category) {
        case "render.video":
          if (event.detail == "1st_frame") {
            Log.d("MDK: 首帧已渲染");
          }

        case "video":
          if (event.detail != "size") break;
          Log.d("MDK: 视频帧大小变化");

          final codec = _player?.mediaInfo.video?.firstOrNull?.codec;
          if (codec == null) {
            Log.d("MDK: 未获取到视频编码信息");
            break;
          }

          Log.d(
            "MDK: 视频宽: ${codec.width}, 高: ${codec.height}, 帧率: ${codec.frameRate}",
          );

          final mediaInfo = _player?.mediaInfo;
          final videoTrack = mediaInfo?.video?[0].codec;
          final audioTrack = mediaInfo?.audio?[0].codec;

          lastState = lastState.copyWith(
            width: codec.width,
            height: codec.height,
            fps: codec.frameRate,
            videoParams: videoTrack.toString(),
            audioParams: audioTrack.toString(),
          );
          _stateController.add(lastState);
          break;
      }
    });
  }
}
