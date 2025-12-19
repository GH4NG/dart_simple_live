import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/models/db/follow_user.dart';
import 'package:simple_live_app/widgets/net_image.dart';

class FollowUserItem extends StatefulWidget {
  final FollowUser item;
  final Function()? onRemove;
  final Function()? onTap;
  final Function()? onLongPress;
  final bool playing;

  const FollowUserItem({
    required this.item,
    this.onRemove,
    this.onTap,
    this.onLongPress,
    this.playing = false,
    super.key,
  });

  @override
  State<FollowUserItem> createState() => _FollowUserItemState();
}

class _FollowUserItemState extends State<FollowUserItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final site = Sites.allSites[item.siteId]!;
    final bool isLive = item.liveStatus.value == 2;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        borderRadius: AppStyle.radius12,
        splashColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: .08),
        child: Container(
          margin: AppStyle.edgeInsetsV4,
          padding: AppStyle.edgeInsetsA12,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppStyle.radius12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLive
                        ? Colors.red
                        : Colors.grey.withValues(alpha: .3),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: AppStyle.radius24,
                  child: NetImage(item.face, width: 48, height: 48),
                ),
              ),
              AppStyle.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.userName,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: .2,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.liveAreaName.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.liveAreaName,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        AppStyle.hGap8,
                        if (widget.playing || item.liveStatus.value != 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: widget.playing
                                  ? Colors.green.withValues(alpha: .12)
                                  : (isLive
                                        ? Colors.red.withValues(alpha: .12)
                                        : Colors.grey.withValues(alpha: .12)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.playing ? "观看中" : (isLive ? "直播中" : "未开播"),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: widget.playing
                                    ? Colors.green
                                    : (isLive ? Colors.red : Colors.grey),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (item.liveTitle.isNotEmpty &&
                        (widget.playing || isLive)) ...[
                      AppStyle.vGap4,
                      Text(
                        item.liveTitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    AppStyle.vGap4,
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Image.asset(site.logo, width: 16),
                              AppStyle.hGap4,
                              Text(
                                site.name,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11,
                                    ),
                              ),
                              AppStyle.hGap8,
                              if (isLive && item.liveStartTime != null)
                                Flexible(
                                  child: Text(
                                    '已开播 ${formatLiveDuration(item.liveStartTime)}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (item.watchDuration != null &&
                            item.watchDuration!.isNotEmpty)
                          Container(
                            width: 60,
                            height: 20,
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                AppStyle.hGap4,
                                Expanded(
                                  child: Text(
                                    item.watchDuration!,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.onRemove != null && !widget.playing) ...[
                AppStyle.hGap4,
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.onRemove,
                  child: Container(
                    padding: AppStyle.edgeInsetsA4,
                    child: const Icon(
                      Remix.dislike_line,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String getStatus(int status) {
    if (status == 0) return "读取中";
    if (status == 1) return "未开播";
    return "直播中";
  }

  String formatLiveDuration(String? startTimeStampString) {
    if (startTimeStampString == null ||
        startTimeStampString.isEmpty ||
        startTimeStampString == "0") {
      return "";
    }
    try {
      int startTimeStamp = int.parse(startTimeStampString);
      int currentTimeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      int durationInSeconds = currentTimeStamp - startTimeStamp;
      int hours = durationInSeconds ~/ 3600;
      int minutes = (durationInSeconds % 3600) ~/ 60;

      if (hours == 0 && minutes == 0) return "不足1分钟";
      return '${hours > 0 ? "$hours小时" : ""}${minutes > 0 ? "$minutes分钟" : ""}';
    } catch (_) {
      return "--小时--分钟";
    }
  }
}
