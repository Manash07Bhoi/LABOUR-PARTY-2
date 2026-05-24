import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: width,
      height: height,
      blur: 8,
      color: Colors.black.withAlpha(100),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withAlpha(30), Colors.white.withAlpha(10)],
      ),
      border: Border.fromBorderSide(
        BorderSide(color: Colors.white.withAlpha(40), width: 0.5),
      ),
      shadowStrength: 2,
      shadowColor: Colors.black.withAlpha(50),
      borderRadius: BorderRadius.circular(borderRadius),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
