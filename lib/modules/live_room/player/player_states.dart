class PlayerState {
  final List playlist;

  final bool buffering;

  final String audioParams;

  final String audioTrack;

  final String videoParams;

  final String videoTrack;

  final int? width;

  final int? height;

  final double? fps;

  const PlayerState({
    this.playlist = const [],
    this.buffering = false,
    this.audioParams = "",
    this.audioTrack = "",
    this.videoParams = "",
    this.videoTrack = "",
    this.width,
    this.height,
    this.fps,
  });

  PlayerState copyWith({
    List? playlist,
    bool? buffering,
    String? audioParams,
    String? audioTrack,
    String? videoParams,
    String? videoTrack,
    int? width,
    int? height,
    double? fps,
  }) {
    return PlayerState(
      playlist: playlist ?? this.playlist,
      buffering: buffering ?? this.buffering,
      audioParams: audioParams ?? this.audioParams,
      audioTrack: audioTrack ?? this.audioTrack,
      videoParams: videoParams ?? this.videoParams,
      videoTrack: videoTrack ?? this.videoTrack,
      width: width ?? this.width,
      height: height ?? this.height,
      fps: fps ?? this.fps,
    );
  }

  @override
  String toString() =>
      'Player('
      'playlist: $playlist, '
      'buffering: $buffering, '
      'audioParams: $audioParams, '
      'audioTrack: $audioTrack, '
      'videoParams: $videoParams, '
      'videoTrack: $videoTrack, '
      'width: $width, '
      'height: $height, '
      'fps: $fps'
      ')';
}
