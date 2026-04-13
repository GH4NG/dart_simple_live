import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:simple_live_app/modules/live_room/player/player_states.dart';

export 'package:simple_live_app/modules/live_room/player/player_states.dart';

abstract class BasePlayer {
  Stream<PlayerState> get stateStream;

  PlayerState lastState = const PlayerState();

  Future<void> init();

  Widget? videoWidget(
    Key key,
    double? aspectRatio,
    BoxFit fit,
    bool showControls,
  );

  Future<void> dispose();

  Future<void> loadVideo(
    String url, {
    Map<String, String>? headers,
    bool play = true,
  });

  Future<void> play();

  Future<void> setVolume(double volume);

  Future<void> pause();

  Future<void> stop();

  Future<void> playOrPause();

  Future<Uint8List?> snapshot();
}
