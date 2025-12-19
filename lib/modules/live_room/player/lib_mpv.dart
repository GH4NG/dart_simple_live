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
      await cancelPlayerDebugInfoSubscription();
      await _player?.dispose();
      _player = null;
      _controller = null;
    }

    register();

    final settings = AppSettingsController.instance;
    _player = mpv.Player(
      configuration: mpv.PlayerConfiguration(
        title: "Simple Live Player",
        logLevel: mpv.MPVLogLevel.values[settings.playerLogLevel.value],
      ),
    );

    final hardwareAccelerationEnabled = settings.hardwareDecode.value;
    final hardwareDecoder = settings.videoHardwareDecoder.value;
    _controller = VideoController(
      _player!,
      configuration: VideoControllerConfiguration(
        enableHardwareAcceleration: hardwareAccelerationEnabled,
        hwdec: hardwareAccelerationEnabled ? hardwareDecoder : 'no',
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
    final settings = AppSettingsController.instance;
    return Video(
      key: key,
      controller: _controller!,
      pauseUponEnteringBackgroundMode: settings.playerAutoPause.value,
      resumeUponEnteringForegroundMode: settings.playerAutoPause.value,
      controls: (state) {
        return playerControls(state.context, roomController);
      },
      aspectRatio: aspectRatio,
      fit: fit,
    );
  }

  @override
  Future<void> dispose() async {
    await cancelPlayerDebugInfoSubscription();
    await _player?.dispose();
    _player = null;
    _controller = null;
    _stateController.close();
  }

  @override
  Future<void> loadVideo(
    String url, {
    Map<String, String>? headers,
    bool play = true,
  }) async {
    final player = _player;
    if (player == null) return;
    await player.stop();

    lastState = lastState.copyWith(buffering: true);
    _stateController.add(lastState);

    await player.open(mpv.Media(url, httpHeaders: headers), play: play);
  }

  @override
  Future<void> play() async {
    final player = _player;
    if (player == null) return;
    await player.play();
  }

  @override
  Future<void> setVolume(double volume) async {
    final player = _player;
    if (player == null) return;
    await player.setVolume(volume);
  }

  @override
  Future<void> pause() async {
    final player = _player;
    if (player == null) return;
    await player.pause();
  }

  @override
  Future<void> stop() async {
    final player = _player;
    if (player == null) return;
    await player.stop();
  }

  @override
  Future<void> playOrPause() async {
    final player = _player;
    if (player == null) return;
    await player.playOrPause();
  }

  @override
  Future<Uint8List?> snapshot() async {
    final player = _player;
    if (player == null) return null;
    return await player.screenshot();
  }

  void setState(PlayerState state) {
    lastState = state;
    _stateController.add(state);
  }

  StreamSubscription<mpv.PlayerLog>? playerLogSubscription;
  StreamSubscription<int?>? playerWidthSubscription;
  StreamSubscription<int?>? playerHeightSubscription;
  StreamSubscription<bool>? playerBufferingSubscription;
  StreamSubscription<mpv.VideoParams>? playerVideoParamsSubscription;
  StreamSubscription<mpv.AudioParams>? playerAudioParamsSubscription;
  StreamSubscription<mpv.Playlist>? playerPlaylistSubscription;
  StreamSubscription<mpv.Tracks>? playerTracksSubscription;

  Future<void> setupPlayerDebugInfoSubscription() async {
    final player = _player;
    if (player == null) return;

    var videoWidth = 0;
    var videoHeight = 0;

    final settings = AppSettingsController.instance;

    await playerLogSubscription?.cancel();
    if (settings.playerLogEnable.value) {
      playerLogSubscription = player.stream.log.listen((event) {
        Log.d("MPV: ${event.toString()}");
      });
    }

    await playerWidthSubscription?.cancel();
    playerWidthSubscription = player.stream.width.listen((event) {
      videoWidth = event ?? 0;
      final isVertical = videoHeight > 0 && videoWidth > 0
          ? videoHeight > videoWidth
          : null;
      setState(
        lastState.copyWith(
          height: videoHeight,
          width: videoWidth,
          isVertical: isVertical,
        ),
      );
    });

    await playerHeightSubscription?.cancel();
    playerHeightSubscription = player.stream.height.listen((event) {
      videoHeight = event ?? 0;
      final isVertical = videoHeight > 0 && videoWidth > 0
          ? videoHeight > videoWidth
          : null;
      setState(
        lastState.copyWith(
          height: videoHeight,
          width: videoWidth,
          isVertical: isVertical,
        ),
      );
    });

    await playerBufferingSubscription?.cancel();
    playerBufferingSubscription = player.stream.buffering.listen((event) {
      setState(lastState.copyWith(buffering: event));
    });

    await playerVideoParamsSubscription?.cancel();
    playerVideoParamsSubscription = player.stream.videoParams.listen((event) {
      setState(lastState.copyWith(videoParams: event.toString()));
    });

    await playerAudioParamsSubscription?.cancel();
    playerAudioParamsSubscription = player.stream.audioParams.listen((event) {
      setState(lastState.copyWith(audioParams: event.toString()));
    });

    await playerPlaylistSubscription?.cancel();
    playerPlaylistSubscription = player.stream.playlist.listen((event) {
      setState(
        lastState.copyWith(
          playlist: event.medias.map((e) => e.uri).toList(),
        ),
      );
    });

    await playerTracksSubscription?.cancel();
    playerTracksSubscription = player.stream.tracks.listen((event) {
      final validAudioTrack = event.audio.firstWhere(
        (track) => track.codec != null,
        orElse: () => const mpv.AudioTrack('unknown', null, null),
      );

      final validVideoTrack = event.video.firstWhere(
        (track) => track.codec != null,
        orElse: () => const mpv.VideoTrack('unknown', null, null),
      );

      setState(
        lastState.copyWith(
          fps: validVideoTrack.fps,
          audioTrack: validAudioTrack.toString(),
          videoTrack: validVideoTrack.toString(),
        ),
      );
    });
  }

  Future<void> cancelPlayerDebugInfoSubscription() async {
    await playerLogSubscription?.cancel();
    await playerWidthSubscription?.cancel();
    await playerHeightSubscription?.cancel();
    await playerBufferingSubscription?.cancel();
    await playerVideoParamsSubscription?.cancel();
    await playerAudioParamsSubscription?.cancel();
    await playerPlaylistSubscription?.cancel();
    await playerTracksSubscription?.cancel();
  }
}
