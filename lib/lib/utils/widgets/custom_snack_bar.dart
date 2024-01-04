import 'package:flutter/material.dart';

class CustomSnackBar extends SnackBar {
  final double marginBottom;

  CustomSnackBar({
    Key? key,
    required Widget content,
    this.marginBottom = 30.0, // Adjust the margin as needed
  }) : super(
          key: key,
          content: content,
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          margin: EdgeInsets.only(bottom: marginBottom),
        );
}
