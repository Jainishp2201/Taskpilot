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
    
    // Claymorphism uses two shadows: a light top-left and a dark bottom-right
    // to give the illusion of a solid 3D object pushing out of the surface.
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Darker shadow on bottom right
          BoxShadow(
            color: const Color(0xFFC4D1DF).withOpacity(0.8), // darker grey-blue
            offset: Offset(depth / 2, depth / 2),
            blurRadius: depth,
            spreadRadius: 1,
          ),
          // Lighter shadow on top left
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
