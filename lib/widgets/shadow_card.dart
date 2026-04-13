import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/widgets/tv_focusable.dart';

class ShadowCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final Function()? onTap;
  final Function()? onLongPress;
  final bool dpadAutofocus;
  final bool dpadEnabled;
  final bool dpadEntryPoint;
  final int dpadEntryPriority;
  final String? dpadRegion;
  final String? dpadDebugLabel;
  const ShadowCard({
    required this.child,
    this.radius = 8.0,
    this.onTap,
    this.onLongPress,
    this.dpadAutofocus = false,
    this.dpadEnabled = true,
    this.dpadEntryPoint = false,
    this.dpadEntryPriority = 0,
    this.dpadRegion,
    this.dpadDebugLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final content = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: Get.isDarkMode
            ? []
            : [
                BoxShadow(
                  blurRadius: 4,
                  color: Colors.grey.withAlpha(50),
                ),
              ],
      ),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onLongPress: onLongPress,
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppStyle.radius8,
            ),
            child: child,
          ),
        ),
      ),
    );

    return TvFocusable(
      onSelect: onTap,
      autofocus: dpadAutofocus,
      enabled: dpadEnabled,
      region: dpadRegion,
      isEntryPoint: dpadEntryPoint,
      entryPriority: dpadEntryPriority,
      debugLabel: dpadDebugLabel,
      borderRadius: BorderRadius.circular(radius),
      child: content,
    );
  }
}
