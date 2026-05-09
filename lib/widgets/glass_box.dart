import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget child;
  final double blur;
  final double opacity;
  final Color color;
  final BorderRadius borderRadius;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;

  const GlassBox({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.color = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.border,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: color.withAlpha((opacity * 255).toInt()),
            borderRadius: borderRadius,
            border: border ??
                Border.all(
                  color: color.withAlpha((0.1 * 255).toInt()),
                  width: 1.0,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}
