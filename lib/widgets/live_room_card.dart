import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/controller/app_settings_controller.dart';
import 'package:simple_live_app/app/sites.dart';
import 'package:simple_live_app/app/utils.dart';
import 'package:simple_live_app/routes/app_navigation.dart';
import 'package:simple_live_app/widgets/net_image.dart';
import 'package:simple_live_app/widgets/shadow_card.dart';
import 'package:simple_live_core/simple_live_core.dart';

class LiveRoomCard extends StatelessWidget {
  final Site site;
  final LiveRoomItem item;
  final Function()? onLongPress;
  const LiveRoomCard(this.site, this.item, {super.key, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return ShadowCard(
      onTap: () {
        AppNavigator.toLiveRoomDetail(site: site, roomId: item.roomId);
      },
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: NetImage(
                  AppSettingsController.instance.showKeyframe.value &&
                          item.keyframe != null &&
                          item.keyframe!.isNotEmpty
                      ? item.keyframe!
                      : item.cover,

                  fit: BoxFit.cover,
                  height: 110,
                  width: double.infinity,
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Image.asset(
                  site.logo,
                  height: 24,
                  width: 24,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                right: 0,
                left: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black87,
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: Text(
                          item.areaName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Remix.fire_fill,
                            color: Colors.white,
                            size: 14,
                          ),
                          AppStyle.hGap4,
                          Text(
                            Utils.onlineToString(item.online),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: AppStyle.edgeInsetsA8.copyWith(bottom: 4),
            child: Row(
              children: [
                NetImage(
                  item.userAvatar,
                  width: 32,
                  height: 32,
                  borderRadius: 16,
                ),
                AppStyle.hGap8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppStyle.hGap4,
                      Text(
                        item.userName,
                        maxLines: 1,
                        style: const TextStyle(
                          height: 1.4,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
