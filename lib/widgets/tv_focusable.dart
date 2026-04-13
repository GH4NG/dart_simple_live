import 'package:dpad/dpad.dart';
import 'package:flutter/material.dart';
import 'package:simple_live_app/app/utils/platform_utils.dart';

class TvFocusable extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSelect;
  final VoidCallback? onFocus;
  final bool autofocus;
  final bool enabled;
  final String? region;
  final bool isEntryPoint;
  final int entryPriority;
  final String? debugLabel;
  final BorderRadius? borderRadius;
  final double scale;

  const TvFocusable({
    required this.child,
    this.onSelect,
    this.onFocus,
    this.autofocus = false,
    this.enabled = true,
    this.region,
    this.isEntryPoint = false,
    this.entryPriority = 0,
    this.debugLabel,
    this.borderRadius,
    this.scale = 1.03,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!PlatformUtils.isAndroidTV) {
      return child;
    }

    final radius = borderRadius ?? BorderRadius.circular(12);
    final color = Theme.of(context).colorScheme.primary;

    return DpadFocusable(
      enabled: enabled,
      autofocus: autofocus,
      onFocus: onFocus,
      onSelect: onSelect,
      region: region,
      isEntryPoint: isEntryPoint,
      entryPriority: entryPriority,
      debugLabel: debugLabel,
      builder: FocusEffects.combine([
        FocusEffects.scale(scale: scale),
        FocusEffects.glow(
          glowColor: color,
          blurRadius: 18,
          spreadRadius: 1.5,
          borderRadius: radius,
        ),
        FocusEffects.border(
          focusColor: color,
          width: 2.5,
          borderRadius: radius,
        ),
      ]),
      child: child,
    );
  }
}
