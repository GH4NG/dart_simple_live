import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' as mpv;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/app/log.dart';
import 'package:simple_live_app/modules/live_room/player/base_player.dart';

class LibMPV extends BasePlayer {
  mpv.Player? _player;
  VideoController? _controller;
  final StreamController<PlayerState> _stateController =
      StreamController.broadcast();

  @override
  Stream<PlayerState> get stateStream => _stateController.stream;

  @override
  Future<void> init() async {
    register();
    _player = mpv.Player(
      configuration: mpv.PlayerConfiguration(
        title: "Simple Live Player",
        logLevel: AppSettingsController.instance.logEnable.value
            ? mpv.MPVLogLevel.info
            : mpv.MPVLogLevel.error,
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

    _player!.stream.error.listen((event) {
      Log.w('MPV error: $event');
    });

    _player!.stream.playing.listen((_) => _updateState());
    _player!.stream.completed.listen((_) => _updateState());
    _player!.stream.tracks.listen((_) => _updateState());
    _player!.stream.width.listen((_) => _updateState());
    _player!.stream.height.listen((_) => _updateState());
  }

  void _updateState() {
    if (_player == null) return;
    final playing = _player!.state.playing;
    final completed = _player!.state.completed;
    PlaybackState state;
    if (completed) {
      state = PlaybackState.stopped;
    } else if (playing) {
      state = PlaybackState.playing;
    } else {
      state = PlaybackState.paused;
    }

    final newState = PlayerState(
      playbackState: state,
      mediaInfo: MediaInfo(),
      videoSize: Size(
        _player!.state.width?.toDouble() ?? 0,
        _player!.state.height?.toDouble() ?? 0,
      ),
    );
    lastState = newState;
    _stateController.add(newState);
  }

  @override
  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    _controller = null;
    _stateController.close();
  }

  @override
  Widget? videoWidget(Key key, {BoxFit fit = BoxFit.contain}) {
    if (_controller == null) {
      return const SizedBox.expand();
    }
    return Video(
      key: key,
      controller: _controller!,
      fit: fit,
      controls: NoVideoControls,
    );
  }

  @override
  Future<void> open(BuildContext context) async {}

  @override
  Future<void> loadVideo(
    String url, {
    Map<String, String>? headers,
    bool play = true,
  }) async {
    await _player?.open(mpv.Media(url, httpHeaders: headers), play: play);
    _updateState();
  }

  @override
  Future<void> pause() async {
    await _player?.pause();
  }

  @override
  Future<void> play() async {
    await _player?.play();
  }

  @override
  Future<void> playOrPause() async {
    await _player?.playOrPause();
  }

  @override
  Future<void> setVolume(double volume) async {
    await _player?.setVolume(volume);
  }

  @override
  Future<void> stop() async {
    await _player?.stop();
    _updateState();
  }

  @override
  Future<Uint8List?> snapshot() async {
    return await _player?.screenshot();
  }

  static void register() {
    mpv.MediaKit.ensureInitialized();
  }
}
