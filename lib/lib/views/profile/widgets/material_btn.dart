import 'package:flutter/material.dart';

class MaterialBtn extends StatelessWidget {
  const MaterialBtn(
      {super.key,
      required this.title,
      required this.color,
      required this.materialCallBack});

  final String title;
  final Color color;
  final VoidCallback materialCallBack;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        padding: const EdgeInsets.all(10),
        enableFeedback: true,
        splashColor: Colors.white,
        color: color,
        onPressed: materialCallBack,
        child: Center(
          child: Text(
            title,
            textScaleFactor: 1.0,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ));
  }
}
