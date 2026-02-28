import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final BoxConstraints? constraints;

  const GlassmorphicContainer({
    this.constraints,
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1.5,
    this.gradient,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(20);
    final defaultGradient = gradient ?? _getDefaultGradient(isDark);
    final defaultBorderColor = borderColor ?? 
        (isDark 
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.4));
    final defaultShadow = boxShadow ?? _getDefaultShadow(isDark);

    Widget container = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      constraints: constraints,
      decoration: BoxDecoration(
        gradient: defaultGradient,
        borderRadius: defaultBorderRadius,
        border: Border.all(
          color: defaultBorderColor,
          width: borderWidth ?? 1.5,
        ),
        boxShadow: defaultShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }

  Gradient _getDefaultGradient(bool isDark) {
    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.coolBlue.withOpacity(0.3),
          AppColors.primaryPurple.withOpacity(0.25),
          AppColors.coolCyan.withOpacity(0.2),
          AppColors.primaryBlue.withOpacity(0.15),
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.95),
          Colors.white.withOpacity(0.85),
          Colors.white.withOpacity(0.9),
          Colors.white.withOpacity(0.75),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );
    }
  }

  List<BoxShadow> _getDefaultShadow(bool isDark) {
    if (isDark) {
      return [
        // Enhanced 3D shadows with cool colors for dark mode
        BoxShadow(
          color: AppColors.coolBlue.withOpacity(0.15),
          blurRadius: 15,
          offset: const Offset(0, 6),
          spreadRadius: 1,
        ),
        BoxShadow(
          color: AppColors.coolPurple.withOpacity(0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0.5,
        ),
        BoxShadow(
          color: AppColors.coolCyan.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];
    } else {
      return [
        // Premium 3D shadows for light mode
        BoxShadow(
          color: AppColors.coolBlue.withOpacity(0.2),
          blurRadius: 25,
          offset: const Offset(0, 10),
          spreadRadius: 2,
        ),
        BoxShadow(
          color: AppColors.coolPurple.withOpacity(0.15),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 1,
        ),
        BoxShadow(
          color: AppColors.primaryBlue.withOpacity(0.1),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];
    }
  }
}

// Glassmorphic card variant
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: child,
    );
  }
}

