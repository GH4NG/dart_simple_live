import 'package:flutter/material.dart';

enum PlaybackState { stopped, playing, paused }

enum MediaType { video, audio, subtitle }

class MediaEvent {
  final int error;
  final String category;
  final String detail;

  const MediaEvent(this.error, this.category, this.detail);
}

class MediaCodec {
  final String codec;
  final int width;
  final int height;
  final double frameRate;
  final String format;

  MediaCodec({
    this.codec = '',
    this.width = 0,
    this.height = 0,
    this.frameRate = 0.0,
    this.format = '',
  });
}

class MediaStream {
  final int index;
  final MediaCodec codec;

  MediaStream({this.index = 0, required this.codec});

  @override
  String toString() {
    return 'Codec: ${codec.codec}, ${codec.width}x${codec.height}, ${codec.frameRate}fps';
  }
}

class MediaInfo {
  final int duration;
  final int bitRate;
  final String format;
  final int streams;
  final List<MediaStream>? video;
  final List<MediaStream>? audio;
  final Map<String, String> metadata;

  MediaInfo({
    this.duration = 0,
    this.bitRate = 0,
    this.format = '',
    this.streams = 0,
    this.video,
    this.audio,
    this.metadata = const {},
  });
}

class PlayerState {
  final PlaybackState playbackState;
  final MediaInfo mediaInfo;
  final Size videoSize;
  final int? textureId;
  final bool buffering;

  PlayerState({
    this.playbackState = PlaybackState.stopped,
    MediaInfo? mediaInfo,
    this.videoSize = Size.zero,
    this.textureId,
    this.buffering = false,
  }) : mediaInfo = mediaInfo ?? MediaInfo();

  PlayerState copyWith({
    PlaybackState? playbackState,
    MediaInfo? mediaInfo,
    Size? videoSize,
    int? textureId,
    bool? buffering,
  }) {
    return PlayerState(
      playbackState: playbackState ?? this.playbackState,
      mediaInfo: mediaInfo ?? this.mediaInfo,
      videoSize: videoSize ?? this.videoSize,
      textureId: textureId ?? this.textureId,
      buffering: buffering ?? this.buffering,
    );
  }
}
