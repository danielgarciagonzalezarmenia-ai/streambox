import 'dart:ui';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.opacity = 0.5,
    this.color,
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? AppTheme.surface.withValues(alpha: opacity),
              borderRadius: radius,
              border: border ??
                  Border.all(
                    color: AppTheme.glassBorder,
                    width: 0.8,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
