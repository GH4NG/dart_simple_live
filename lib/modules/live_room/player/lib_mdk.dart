import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:fvp/mdk.dart' as mdk;
import 'package:fvp/fvp.dart' as fvp;
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/app/log.dart';
import 'package:simple_live_app/modules/live_room/player/base_player.dart';

class LibMDK extends BasePlayer {
  static void register() {
    fvp.registerWith(
      options: {
        'platforms': ['windows', 'macos', 'linux', 'android', 'ios'],
        'global': {
          'log': 'all', // off, error, warning, info, debug, all(default)
        },
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
    register();
    _player = mdk.Player();
    _player!.onStateChanged((oldState, newState) {
      _updateState();
    });
    _player!.onEvent((event) {
      // TODO: Handle events
    });
  }

  void _updateState() {
    if (_player == null) return;
    final info = _player!.mediaInfo;
    final newState = PlayerState(
      playbackState: _mapState(_player!.state),
      mediaInfo: MediaInfo(
        duration: info.duration,
        bitRate: info.bitRate,
        format: info.format ?? '',
        streams: info.streams,
        video: info.video
            ?.map(
              (v) => MediaStream(
                index: v.index,
                codec: MediaCodec(
                  codec: v.codec.codec,
                  width: v.codec.width,
                  height: v.codec.height,
                  frameRate: v.codec.frameRate,
                  format: v.codec.format.toString(),
                ),
              ),
            )
            .toList(),
        audio: info.audio
            ?.map(
              (a) => MediaStream(
                index: a.index,
                codec: MediaCodec(
                  codec: a.codec.codec,
                  width: 0,
                  height: 0,
                  frameRate: a.codec.frameRate.toDouble(),
                  format: '',
                ),
              ),
            )
            .toList(),
        metadata: info.metadata,
      ),
      videoSize: _getVideoSize(),
      textureId: _textureId.value,
    );
    lastState = newState;
    _stateController.add(newState);
  }

  Size _getVideoSize() {
    if (_player == null) return Size.zero;
    final codec = _player!.mediaInfo.video?.firstOrNull?.codec;
    if (codec != null) {
      return Size(codec.width.toDouble(), codec.height.toDouble());
    }
    return Size.zero;
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
  Future<void> open(BuildContext context) async {}

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
    _updateState();
    if (play) {
      await this.play();
    }
  }

  @override
  Future<void> pause() async {
    _player?.state = mdk.PlaybackState.paused;
  }

  @override
  Future<void> play() async {
    _player?.state = mdk.PlaybackState.playing;
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
  Future<void> setVolume(double volume) async {
    final player = _player;
    if (player == null) return;
    final normalized = (volume.clamp(0, 100)) / 100;
    player.volume = normalized;
  }

  @override
  Future<void> stop() async {
    _player?.state = mdk.PlaybackState.stopped;
    _textureId.value = null;
    _updateState();
  }

  PlaybackState _mapState(mdk.PlaybackState state) {
    switch (state) {
      case mdk.PlaybackState.stopped:
        return PlaybackState.stopped;
      case mdk.PlaybackState.playing:
        return PlaybackState.playing;
      case mdk.PlaybackState.paused:
        return PlaybackState.paused;
      default:
        return PlaybackState.stopped;
    }
  }

  @override
  Future<Uint8List?> snapshot() async {
    final player = _player;
    if (player == null) return null;

    final rgbaData = await player.snapshot();
    if (rgbaData == null) return null;

    final size = _getVideoSize();
    if (size == Size.zero) return null;

    final width = size.width.toInt();
    final height = size.height.toInt();

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

  @override
  Widget? videoWidget(Key key, {BoxFit fit = BoxFit.contain}) {
    return ValueListenableBuilder<int?>(
      key: key,
      valueListenable: _textureId,
      builder: (context, id, _) {
        if (id == null || id < 0) {
          return const SizedBox.expand();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = lastState.videoSize;
            if (size == Size.zero) {
              return const SizedBox.expand();
            }
            return FittedBox(
              fit: fit,
              alignment: Alignment.center,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: Texture(textureId: id),
              ),
            );
          },
        );
      },
    );
  }
}
