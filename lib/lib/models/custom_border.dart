import 'package:flutter/material.dart';

class CustomShapeBorder extends ShapeBorder {
  final double radius;

  const CustomShapeBorder({required this.radius});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    // Do nothing
  }

  @override
  ShapeBorder scale(double t) {
    return CustomShapeBorder(radius: radius * t);
  }
}
