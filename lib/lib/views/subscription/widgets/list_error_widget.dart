import 'package:flutter/material.dart';

class ListErrorWidget extends StatelessWidget {
  final String error;
  const ListErrorWidget({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: CircularProgressIndicator(),
        ),
        Text(
          error,
          textScaleFactor: 1.0,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
