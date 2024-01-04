import 'dart:async';

import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/auth_view_model.dart';
import 'package:digihealthcardapp/viewModel/otp_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onepref/onepref.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPScreen extends StatefulWidget {
  final bool isHome;
  const OTPScreen({Key? key, required this.isHome}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController? otpController;
  late final FocusNode otpFocus;
  // StreamController<ErrorAnimationType>? errorController;
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool hasError = false;
  String currentText = "";
  var number = '';

  @override
  void initState() {
    otpFocus = FocusNode();
    super.initState();
    otpController = TextEditingController();
    // errorController = StreamController<ErrorAnimationType>();
    Future.delayed(Duration.zero, () {
      context.read<OTP_Model>().startTimer(60);
    });
  }

  @override
  void dispose() {
    // errorController!.close();
    otpController?.dispose();
    otpFocus.dispose();
    super.dispose();
  }

  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message!,
          textScaleFactor: 1.0,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  PinTheme defaultTheme(BuildContext context) {
    return PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200, width: 2.0),
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).cardColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final authViewMode = Provider.of<AuthViewModel>(context);
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;

    final focusedPinTheme = defaultTheme(context).copyDecorationWith(
        border: Border.all(color: AppColors.primaryColor, width: 2.0),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardColor);

    final submittedPinTheme = defaultTheme(context).copyWith(
      decoration: defaultTheme(context).decoration?.copyWith(
          color: Theme.of(context).cardColor,
          border: Border.all(color: AppColors.primaryLightColor, width: 2.0)),
    );

    return WillPopScope(
      onWillPop: () =>
          DialogBoxes.onWillPopDialog(context, widget.isHome, false),
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () =>
                DialogBoxes.onWillPopDialog(context, widget.isHome, false),
          ),
          backgroundColor: AppColors.primary,
          title: const Text(
            'OTP Verification',
            textScaleFactor: 1.0,
            style: TextStyle(
                color: AppColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                    top: 50,
                    left: 20,
                    right: 20,
                    child: Container(
                      height: height * .4,
                      width: width * .7,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.black.withOpacity(.2),
                                offset: const Offset(3, 5),
                                blurRadius: 5,
                                spreadRadius: 7),
                          ]),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Positioned(
                              top: 10,
                              right: 10,
                              left: 10,
                              child: Text(
                                'Please enter 4 digit pin sent to your mobile phone.',
                                textScaleFactor: 1.0,
                              )),
                          SizedBox(
                            height: height * .025,
                          ),
                          Positioned(
                            top: 40,
                            right: 0,
                            left: 80,
                            child: Text(
                              'phone: ${OnePref.getString('phone') ?? '+1-123-xxx-xxxx'}',
                              textScaleFactor: 1.0,
                              style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 70,
                            right: 30,
                            left: 30,
                            child: Form(
                                key: formKey,
                                child: Pinput(
                                  defaultPinTheme: defaultTheme(context),
                                  submittedPinTheme: submittedPinTheme,
                                  focusedPinTheme: focusedPinTheme,
                                  controller: otpController,
                                  focusNode: otpFocus,
                                  autofocus: true,
                                  onChanged: (value) {
                                    debugPrint(value);
                                  },
                                  pinAnimationType: PinAnimationType.fade,
                                  onTapOutside: (e) {
                                    otpFocus.unfocus();
                                  },
                                  pinputAutovalidateMode:
                                      PinputAutovalidateMode.onSubmit,
                                  animationDuration:
                                      const Duration(milliseconds: 300),
                                )
                                /* PinCodeTextField(
                                appContext: context,
                                autoDismissKeyboard: true,
                                mainAxisAlignment: MainAxisAlignment.center,
                                length: 4,
                                animationType: AnimationType.fade,
                                onChanged: (value) {
                                  debugPrint(value);
                                },
                                pinTheme: PinTheme(
                                    fieldOuterPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 10),
                                    shape: PinCodeFieldShape.box,
                                    fieldHeight: 50,
                                    fieldWidth: 40,
                                    selectedFillColor:
                                        AppColors.primaryLightColor,
                                    activeColor: AppColors.primaryLightColor,
                                    selectedColor: AppColors.primaryLightColor,
                                    activeFillColor:
                                        AppColors.primaryLightColor,
                                    inactiveColor: AppColors.primaryLightColor,
                                    inactiveFillColor:
                                        AppColors.primaryLightColor),
                                autoFocus: true,
                                focusNode: otpFocus,
                                autoDisposeControllers: true,
                                autoUnfocus: true,
                                cursorColor: AppColors.black,
                                animationDuration:
                                    const Duration(milliseconds: 300),
                                enableActiveFill: false,
                                enablePinAutofill: true,
                                errorAnimationController: errorController,
                                controller: otpController,
                                keyboardType: TextInputType.number,
                                onCompleted: (v) {
                                  debugPrint('Completed');
                                },
                              ),
                            */
                                ),
                          ),
                          Positioned(
                            top: 140,
                            right: 20,
                            left: 20,
                            child: MaterialButton(
                                color: AppColors.primaryLightColor,
                                onPressed: () async {
                                  {
                                    formKey.currentState!.validate();
                                    if (otpController!.text.isEmpty) {
                                      Utils.snackBarMessage(
                                          'Please enter OTP', context);
                                      // errorController!
                                      //     .add(ErrorAnimationType.shake);
                                    } else if (otpController!.text.length < 4) {
                                      Utils.snackBarMessage(
                                          'Please enter full OTP', context);
                                      // errorController!
                                      //     .add(ErrorAnimationType.shake);
                                    } else {
                                      final SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      final String? userToken =
                                          prefs.getString('access_token');
                                      final String? email =
                                          prefs.getString('email');
                                      final String? fname =
                                          prefs.getString('first_name');
                                      final String? lname =
                                          prefs.getString('last_name');
                                      final String? password =
                                          prefs.getString('password');
                                      final String? phone =
                                          prefs.getString('phone');
                                      final String? userId =
                                          prefs.getString('patient_id');
                                      final String? socialID =
                                          prefs.getString('social_id');
                                      final String? fromSOCIAL =
                                          prefs.getString('from_social');
                                      final isHome =
                                          prefs.getBool('isHome') ?? false;
                                      if (kDebugMode) {
                                        print('$phone');
                                      }
                                      if (!isHome) {
                                        Map<String, String> header = {
                                          "Oauthtoken": "Bearer $userToken"
                                        };

                                        Map data = {
                                          'phone': phone.toString(),
                                          'code':
                                              otpController?.text.toString(),
                                          'first_name': fname.toString(),
                                          'last_name': lname.toString(),
                                          'email': email.toString(),
                                          if (password != null)
                                            'password': password.toString(),
                                          'social_id': (socialID == null ||
                                                  socialID == '' &&
                                                      (password == null ||
                                                          password.isEmpty))
                                              ? '111'
                                              : socialID.toString(),
                                          'from_social': (fromSOCIAL == null ||
                                                  fromSOCIAL == '' &&
                                                      (password == null ||
                                                          password.isEmpty))
                                              ? 'register form'
                                              : fromSOCIAL.toString()
                                        };
                                        if (!context.mounted) return;
                                        await authViewMode.otpApi(
                                            data, header, context);
                                        if (kDebugMode) {
                                          print('Api hit $data');
                                        }
                                      } else {
                                        Map<String, String> header = {
                                          "Oauthtoken": "Bearer $userToken"
                                        };

                                        Map data = {
                                          'phone': phone.toString(),
                                          'code':
                                              otpController?.text.toString(),
                                          'user_id': userId
                                        };
                                        if (!context.mounted) {
                                          return;
                                        }
                                        await authViewMode.simpleOTPVerify(
                                            data, header, context);
                                        if (kDebugMode) {
                                          print('Api hit $data');
                                        }
                                      }
                                    }
                                  }
                                },
                                child: const Text(
                                  'Proceed',
                                  textScaleFactor: 1.0,
                                  style: TextStyle(color: AppColors.white),
                                )),
                          ),
                          SizedBox(
                            height: height * .030,
                          ),
                          Consumer<OTP_Model>(
                              builder: (context, value, child) => value
                                      .isRunning
                                  ? Positioned(
                                      top: 220,
                                      left: 20,
                                      right: 20,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.timer_outlined,
                                            color: AppColors.primaryColor,
                                          ),
                                          SizedBox(
                                            width: width * .050,
                                          ),
                                          Consumer<OTP_Model>(
                                            builder: (context, timer, child) {
                                              return Text(
                                                '00:00:${timer.start}',
                                                textScaleFactor: 1.0,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 20),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  : Positioned(
                                      top: 180,
                                      left: 10,
                                      right: 10,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: height * .030,
                                          ),
                                          const Text(
                                            'Not received a code?',
                                            textScaleFactor: 1.0,
                                            style: TextStyle(
                                                color: AppColors.black),
                                          ),
                                          MaterialButton(
                                              shape: const Border.symmetric(),
                                              color: AppColors.primaryColor,
                                              onPressed: () async {
                                                {
                                                  context
                                                      .read<OTP_Model>()
                                                      .startTimer(60);
                                                }
                                                {
                                                  final SharedPreferences
                                                      prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  final String? phoneNumber =
                                                      prefs.getString('phone');
                                                  if (kDebugMode) {
                                                    print('Otp: $phoneNumber');
                                                  }
                                                  final String? userToken =
                                                      prefs.getString(
                                                          'access_token');
                                                  Map<String, String> header = {
                                                    "Oauthtoken":
                                                        "Bearer $userToken"
                                                  };
                                                  Map data = {
                                                    'phone':
                                                        phoneNumber.toString(),
                                                  };
                                                  if (!context.mounted) {
                                                    return;
                                                  }
                                                  authViewMode.otpResendApi(
                                                      data, header, context);
                                                  if (kDebugMode) {
                                                    print('Api hit $data');
                                                  }
                                                }
                                              },
                                              child: const Text(
                                                'Resend Code',
                                                textScaleFactor: 1.0,
                                                style: TextStyle(
                                                    color: AppColors.white),
                                              )),
                                        ],
                                      ),
                                    )),
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
