import 'package:flutter/material.dart';

class CircularBTN extends StatelessWidget {
  const CircularBTN({
    super.key,
    required this.height,
    required this.width,
    required this.color,
    required this.icon,
  });

  final double height;
  final double width;
  final Color color;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration:
          BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [
        BoxShadow(
          // blurStyle: BlurStyle.outer,
          spreadRadius: 2,
          blurRadius: 0.5,
          offset: const Offset(-1, -1),
          color: const Color(0xff78BBC0).withOpacity(0.3),
        ),
        BoxShadow(
          spreadRadius: -2,
          blurRadius: 10,
          offset: const Offset(5, 5),
          color: Colors.black.withOpacity(0.3),
        ),
      ]),
      child: icon,
    );
  }
}
