import 'package:digihealthcardapp/res/colors.dart';
import 'package:flutter/material.dart';

class RoundButtonLight extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onPress;
  final Color? color;
  const RoundButtonLight(
      {Key? key,
      required this.title,
      this.loading = false,
      required this.onPress,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashFactory: InkSplash.splashFactory,
      onTap: onPress,
      child: Container(
        height: 50,
        width: 320,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color((Theme.of(context).brightness == Brightness.light)
                  ? 0xffDDDDDD
                  : 0xff263238),
              blurRadius: 6.0,
              spreadRadius: 2.0,
              offset: const Offset(0.0, 0.0),
            )
          ],
          borderRadius: BorderRadius.circular(10),
          color: color ?? AppColors.primaryLightColor,
        ),
        child: Center(
            child: loading
                ? const CircularProgressIndicator(
                    color: AppColors.white,
                  )
                : Text(
                    title,
                    textScaleFactor: 1.0,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18),
                  )),
      ),
    );
  }
}
