import 'package:digihealthcardapp/res/colors.dart';
import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onPress;
  const RoundButton(
      {Key? key,
      required this.title,
      this.loading = false,
      required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      onTap: onPress,
      child: Ink(
        height: 50,
        width: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.primaryColor,
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

class RoundButtonBlack extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onPress;
  const RoundButtonBlack(
      {Key? key,
      required this.title,
      this.loading = false,
      required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      onTap: onPress,
      child: Ink(
        height: 50,
        width: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.black,
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
