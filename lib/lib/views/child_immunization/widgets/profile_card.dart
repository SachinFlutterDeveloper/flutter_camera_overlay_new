import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  const CardButton(
      {super.key,
      required this.height,
      required this.width,
      required this.color,
      required this.title,
      required this.onPressed});

  final double height, width;
  final Color color;
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        clipBehavior: Clip.hardEdge,
        style: ButtonStyle(
            enableFeedback: true,
            shadowColor: MaterialStateProperty.all(Colors.grey.shade400),
            fixedSize:
                MaterialStateProperty.all(Size(width * .25, height * .035)),
            elevation: MaterialStateProperty.all(5),
            backgroundColor: MaterialStateProperty.all(
              color,
            ),
            padding: MaterialStateProperty.all(const EdgeInsets.all(5)),
            maximumSize: MaterialStateProperty.all(Size.infinite),
            shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))))),
        onPressed: onPressed,
        child: Text(title,
            textScaleFactor: 1.0,
            style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.normal)),
      ),
    );
  }
}
