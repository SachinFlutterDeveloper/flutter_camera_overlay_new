import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

class AppKeys {
  static final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
}

class AppColors {
  static const Color primaryColor = Color(0xff2cbabb);
  static const Color primaryLightColor = Color(0xff78BBC0);
  static const Color primary = Color(0xff007a94);

  static const Color extra = Color(0xff06CED9);
  static const Color white = Colors.white;
  static const Color blue = Colors.blue;
  static const Color black = Colors.black;

  static PinTheme defaultTheme(BuildContext context) {
    return PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade500, width: 2.0),
          borderRadius: BorderRadius.circular(15),
          color: (Theme.of(context).brightness == Brightness.dark)
              ? Colors.grey[800]
              : AppColors.white),
    );
  }
}

const appOverlayDarkIcons = SystemUiOverlayStyle(
  statusBarColor: AppColors.primaryLightColor,
  statusBarBrightness: Brightness.light,
  statusBarIconBrightness: Brightness.light,
  systemNavigationBarColor: AppColors.primaryLightColor,
  systemNavigationBarIconBrightness: Brightness.dark,
);

const appOverlayLightIcons = SystemUiOverlayStyle(
  statusBarColor: AppColors.primaryLightColor,
  statusBarBrightness: Brightness.dark,
  statusBarIconBrightness: Brightness.light,
  systemNavigationBarColor: AppColors.primaryLightColor,
  systemNavigationBarIconBrightness: Brightness.dark,
);
