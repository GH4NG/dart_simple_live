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

    _player!.stream.playing.listen((_) => _updateState());
    _player!.stream.completed.listen((_) => _updateState());
    _player!.stream.tracks.listen((_) => _updateState());
    _player!.stream.width.listen((_) => _updateState());
    _player!.stream.height.listen((_) => _updateState());
    _player!.stream.buffering.listen((_) => _updateState());

    _player!.stream.error.listen((event) {
      Log.w('MPV error: $event');
    });
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

    _updateState();
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
    _updateState();
  }

  @override
  Future<void> playOrPause() async {
    await _player?.playOrPause();
  }

  @override
  Future<Uint8List?> snapshot() async {
    return await _player?.screenshot();
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

    // Filter video tracks to only those with valid dimensions
    final videoTracks = _player!.state.tracks.video
        .where((e) => (e.w ?? 0) > 0 && (e.h ?? 0) > 0)
        .map(
          (e) => MediaStream(
            index: int.tryParse(e.id) ?? 0,
            codec: MediaCodec(
              codec: e.title ?? e.id,
              format: e.language ?? '',
              width: e.w ?? 0,
              height: e.h ?? 0,
              frameRate: e.fps ?? 0,
            ),
          ),
        )
        .toList();

    // Map audio tracks
    final audioTracks = _player!.state.tracks.audio
        .map(
          (e) => MediaStream(
            index: int.tryParse(e.id) ?? 0,
            codec: MediaCodec(
              codec: e.title ?? e.id,
              format: e.language ?? '',
              frameRate: e.bitrate?.toDouble() ?? 0,
            ),
          ),
        )
        .toList();

    final newState = PlayerState(
      playbackState: state,
      mediaInfo: MediaInfo(
        duration: _player!.state.duration.inMilliseconds,
        streams: videoTracks.length + audioTracks.length,
        video: videoTracks,
        audio: audioTracks,
        metadata: {
          'vo': AppSettingsController.instance.videoOutputDriver.value,
          'ao': AppSettingsController.instance.audioOutputDriver.value,
          'hwdec': AppSettingsController.instance.videoHardwareDecoder.value,
          'videoParams': _player!.state.videoParams.toString(),
          'audioParams': _player!.state.audioParams.toString(),
        },
      ),
      videoSize: Size(
        _player!.state.width?.toDouble() ?? 0,
        _player!.state.height?.toDouble() ?? 0,
      ),
      buffering: _player!.state.buffering,
    );
    lastState = newState;
    _stateController.add(newState);
  }
}
