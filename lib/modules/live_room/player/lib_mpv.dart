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

    _player = mpv.Player(
      configuration: mpv.PlayerConfiguration(
        title: "Simple Live Player",
        logLevel: mpv
            .MPVLogLevel
            .values[AppSettingsController.instance.playerLogLevel.value],
      ),
    );

    var hAenable = AppSettingsController.instance.hardwareDecode.value;
    var hardwareDecoder =
        AppSettingsController.instance.videoHardwareDecoder.value;
    _controller = VideoController(
      _player!,
      configuration: VideoControllerConfiguration(
        enableHardwareAcceleration: hAenable,
        hwdec: hAenable ? hardwareDecoder : 'no',
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
      key: UniqueKey(),
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
    await cancelPlayerDebugInfoSubscription();
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

    lastState = lastState.copyWith(buffering: true);
    _stateController.add(lastState);

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
  StreamSubscription<bool>? playerBufferingSubscription;
  StreamSubscription<mpv.VideoParams>? playerVideoParamsSubscription;
  StreamSubscription<mpv.AudioParams>? playerAudioParamsSubscription;
  StreamSubscription<mpv.Playlist>? playerPlaylistSubscription;
  StreamSubscription<mpv.Tracks>? playerTracksSubscription;

  Future<void> setupPlayerDebugInfoSubscription() async {
    await playerLogSubscription?.cancel();
    if (AppSettingsController.instance.playerLogEnable.value) {
      playerLogSubscription = _player!.stream.log.listen((event) {
        Log.d("MPV: ${event.toString()}");
      });
    }
    await playerWidthSubscription?.cancel();
    playerWidthSubscription = _player!.stream.width.listen((event) {
      lastState = lastState.copyWith(width: event ?? 0);
    });
    await playerHeightSubscription?.cancel();
    playerHeightSubscription = _player!.stream.height.listen((event) {
      lastState = lastState.copyWith(height: event ?? 0);
    });
    await playerBufferingSubscription?.cancel();
    playerBufferingSubscription = _player!.stream.buffering.listen((event) {
      lastState = lastState.copyWith(buffering: event);
      _stateController.add(lastState);
    });

    await playerVideoParamsSubscription?.cancel();
    playerVideoParamsSubscription = _player!.stream.videoParams.listen((event) {
      lastState = lastState.copyWith(videoParams: event.toString());
    });
    await playerAudioParamsSubscription?.cancel();
    playerAudioParamsSubscription = _player!.stream.audioParams.listen((event) {
      lastState = lastState.copyWith(audioParams: event.toString());
    });
    await playerPlaylistSubscription?.cancel();
    playerPlaylistSubscription = _player!.stream.playlist.listen((event) {
      lastState = lastState.copyWith(
        playlist: event.medias.map((e) => e.uri).toList(),
      );
    });
    await playerTracksSubscription?.cancel();
    playerTracksSubscription = _player!.stream.tracks.listen((event) {
      final validAudioTrack = event.audio.firstWhere(
        (track) => track.codec != null,
        orElse: () => const mpv.AudioTrack('unknown', null, null),
      );
      final validVideoTrack = event.video.firstWhere(
        (track) => track.codec != null,
        orElse: () => const mpv.VideoTrack('unknown', null, null),
      );

      final playerAudioTracks = validAudioTrack.toString();
      final playerVideoTracks = validVideoTrack.toString();

      lastState = lastState.copyWith(
        fps: validVideoTrack.fps,
        audioTrack: playerAudioTracks,
        videoTrack: playerVideoTracks,
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
