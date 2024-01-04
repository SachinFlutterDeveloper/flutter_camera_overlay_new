import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/viewModel/Theme_view_model.dart';
import 'package:digihealthcardapp/viewModel/check_expiry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewModel/services/splash_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashService splashServ = SplashService();

  CheckExpiry check = CheckExpiry();

  @override
  void initState() {
    context.read<CheckExpiry>().getURl();
    Provider.of<themeChanger>(context, listen: false).loadURL();
    check.checkExpiry(context, false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;
    return SafeArea(
        child: Scaffold(
      body: Stack(children: [
        SizedBox(
          height: height,
          width: width,
          child: Image.asset(
            'Assets/bg_cc_splash.png',
            fit: BoxFit.fill,
          ),
        ),
        Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Image.asset(
                'Assets/white_log.png',
                height: height * .12,
//              width: width * .50,
              ),
            )),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Center(
                child: Text(
              '"This app is for Personal use only"',
              textScaleFactor: 1.0,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )),
            const SizedBox(
              height: 30,
            ),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 60),
              borderRadius: BorderRadius.circular(50),
              color: AppColors.primary,
              child: const Text(
                'CONTINUE',
                textScaleFactor: 1.0,
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Colors.white),
              ),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, RoutesName.home, (Route<dynamic> route) => false),
            ),
            const SizedBox(
              height: 120,
            )
          ],
        ),
      ]),
    ));
  }
}
