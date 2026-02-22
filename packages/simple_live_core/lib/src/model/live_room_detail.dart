import 'dart:convert';

class LiveRoomDetail {
  /// 房间ID
  final String roomId;

  /// 房间标题
  final String title;

  /// 封面
  final String cover;

  /// 关键帧
  final String? keyframe;

  /// 分区名称
  final String areaName;

  /// 用户名
  final String userName;

  /// 头像
  final String userAvatar;

  /// 在线
  final int online;

  /// 介绍
  final String? introduction;

  /// 公告
  final String? notice;

  /// 状态
  final bool status;

  /// 附加信息
  final dynamic data;

  /// 弹幕附加信息
  final dynamic danmakuData;

  /// 是否录播
  final bool isRecord;

  /// 链接
  final String url;

  /// 显示时间
  final String? showTime;

  LiveRoomDetail({
    required this.roomId,
    required this.title,
    required this.cover,
    this.keyframe,
    required this.areaName,
    required this.userName,
    required this.userAvatar,
    required this.online,
    this.introduction,
    this.notice,
    required this.status,
    this.data,
    this.danmakuData,
    required this.url,
    this.isRecord = false,
    this.showTime,
  });

  LiveRoomDetail copyWith({
    String? roomId,
    String? title,
    String? cover,
    String? keyframe,
    String? areaName,
    String? userName,
    String? userAvatar,
    int? online,
    String? introduction,
    String? notice,
    bool? status,
    dynamic data,
    dynamic danmakuData,
    String? url,
    bool? isRecord,
  }) {
    return LiveRoomDetail(
      roomId: roomId ?? this.roomId,
      title: title ?? this.title,
      cover: cover ?? this.cover,
      keyframe: keyframe ?? this.keyframe,
      areaName: areaName ?? this.areaName,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      online: online ?? this.online,
      introduction: introduction ?? this.introduction,
      notice: notice ?? this.notice,
      status: status ?? this.status,
      data: data ?? this.data,
      danmakuData: danmakuData ?? this.danmakuData,
      isRecord: isRecord ?? this.isRecord,
      url: url ?? this.url,
    );
  }

  LiveRoomDetail updateData(dynamic newData) {
    return copyWith(data: newData);
  }

  LiveRoomDetail updateDanmakuData(dynamic newDanmakuData) {
    return copyWith(danmakuData: newDanmakuData);
  }

  @override
  String toString() {
    return json.encode({
      "roomId": roomId,
      "title": title,
      "cover": cover,
      "areaName": areaName,
      "userName": userName,
      "userAvatar": userAvatar,
      "online": online,
      "introduction": introduction,
      "notice": notice,
      "status": status,
      "data": data,
      "danmakuData": danmakuData.toString(),
      "url": url,
      "isRecord": isRecord,
      "showTime": showTime,
    });
  }
}
