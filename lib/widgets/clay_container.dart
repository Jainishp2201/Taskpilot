import 'package:flutter/material.dart';

class ClayContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final double depth;

  const ClayContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 32.0,
    this.color,
    this.depth = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Theme.of(context).scaffoldBackgroundColor;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Warm dark shadow — bottom-right
          BoxShadow(
            color: const Color(0xFFC3B5AC).withOpacity(0.9),
            offset: Offset(depth / 2, depth / 2),
            blurRadius: depth,
            spreadRadius: 1,
          ),
          // White highlight — top-left
          BoxShadow(
            color: Colors.white,
            offset: Offset(-depth / 2, -depth / 2),
            blurRadius: depth,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}
