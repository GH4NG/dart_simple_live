import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart' as mpv;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/app/log.dart';
import 'package:simple_live_app/modules/live_room/live_room_controller.dart';
import 'package:simple_live_app/modules/live_room/player/base_player.dart';
import 'package:simple_live_app/modules/live_room/player/player_controls.dart';

class LibMPV extends BasePlayer {
  static void register() {
    mpv.MediaKit.ensureInitialized();
  }

  mpv.Player? _player;
  VideoController? _controller;
  final StreamController<PlayerState> _stateController =
      StreamController.broadcast();

  @override
  Stream<PlayerState> get stateStream => _stateController.stream;

  @override
  Future<void> init() async {
    if (_player != null) {
      await _player?.dispose();
      _player = null;
      _controller = null;
    }

    register();

    _player = mpv.Player(
      configuration: mpv.PlayerConfiguration(
        title: "Simple Live Player",
        logLevel: mpv
            .MPVLogLevel
            .values[AppSettingsController.instance.playerLogLevel.value],
      ),
    );
    _controller = VideoController(
      _player!,
      configuration: AppSettingsController.instance.customPlayerOutput.value
          ? VideoControllerConfiguration(
              vo: AppSettingsController.instance.videoOutputDriver.value,
              hwdec: AppSettingsController.instance.hardwareDecode.value
                  ? 'auto'
                  : 'no',
            )
          : AppSettingsController.instance.playerCompatMode.value
          ? const VideoControllerConfiguration(
              vo: 'mediacodec_embed',
              hwdec: 'mediacodec',
            )
          : VideoControllerConfiguration(
              enableHardwareAcceleration:
                  AppSettingsController.instance.hardwareDecode.value,
              androidAttachSurfaceAfterVideoParameters: false,
            ),
    );

    setupPlayerDebugInfoSubscription();
  }

  @override
  Widget? videoWidget(
    Key key,
    double? aspectRatio,
    BoxFit fit,
  ) {
    if (_controller == null) {
      return null;
    }
    final roomController = Get.find<LiveRoomController>();
    return Video(
      key: roomController.globalPlayerKey,
      controller: _controller!,
      pauseUponEnteringBackgroundMode:
          AppSettingsController.instance.playerAutoPause.value,
      resumeUponEnteringForegroundMode:
          AppSettingsController.instance.playerAutoPause.value,
      controls: (state) {
        return playerControls(state.context, roomController);
      },
      aspectRatio: aspectRatio,
      fit: fit,
    );
  }

  @override
  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    _controller = null;
    _stateController.close();
  }

  @override
  Future<void> open(BuildContext context) async {}

  @override
  Future<void> loadVideo(
    String url, {
    Map<String, String>? headers,
    bool play = true,
  }) async {
    if (_player == null) return;
    await _player?.stop();

    await _player?.open(mpv.Media(url, httpHeaders: headers), play: play);
  }

  @override
  Future<void> play() async {
    await _player?.play();
  }

  @override
  Future<void> setVolume(double volume) async {
    await _player?.setVolume(volume);
  }

  @override
  Future<void> pause() async {
    await _player?.pause();
  }

  @override
  Future<void> stop() async {
    await _player?.stop();
  }

  @override
  Future<void> playOrPause() async {
    await _player?.playOrPause();
  }

  @override
  Future<Uint8List?> snapshot() async {
    return await _player?.screenshot();
  }

  StreamSubscription<mpv.PlayerLog>? playerLogSubscription;
  StreamSubscription<int?>? playerWidthSubscription;
  StreamSubscription<int?>? playerHeightSubscription;
  StreamSubscription<mpv.VideoParams>? playerVideoParamsSubscription;
  StreamSubscription<mpv.AudioParams>? playerAudioParamsSubscription;
  StreamSubscription<mpv.Playlist>? playerPlaylistSubscription;
  StreamSubscription<mpv.Track>? playerTracksSubscription;
  StreamSubscription<double?>? playerAudioBitrateSubscription;

  Future<void> setupPlayerDebugInfoSubscription() async {
    await playerLogSubscription?.cancel();
    if (AppSettingsController.instance.playerLogEnable.value) {
      playerLogSubscription = _player!.stream.log.listen((event) {
        if (AppSettingsController.instance.playerLogEnable.value) {
          Log.d("MPV: ${event.toString()}");
        }
      });
    }
  }

  Future<void> cancelPlayerDebugInfoSubscription() async {
    await playerLogSubscription?.cancel();
    await playerWidthSubscription?.cancel();
    await playerHeightSubscription?.cancel();
    await playerVideoParamsSubscription?.cancel();
    await playerAudioParamsSubscription?.cancel();
    await playerPlaylistSubscription?.cancel();
    await playerTracksSubscription?.cancel();
    await playerAudioBitrateSubscription?.cancel();
  }
}
