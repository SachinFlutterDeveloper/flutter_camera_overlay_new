import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:digihealthcardapp/models/custom_border.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/round_button.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/auth_view_model.dart';
import 'package:digihealthcardapp/viewModel/check_expiry.dart';
import 'package:digihealthcardapp/viewModel/user_view_model.dart';
import 'package:digihealthcardapp/views/child_immunization/widgets/profile_card.dart';
import 'package:digihealthcardapp/views/profile/viewmodels/change_password.viewmodel.dart';
import 'package:digihealthcardapp/views/scan_health_card/scan_card.dart';
import 'package:digihealthcardapp/views/subscription/viewmodels/subscription_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:onepref/onepref.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../app_url.dart';

class DialogBoxes {
  static void telehealth(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * .45,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'TeleHealth',
                      textScaleFactor: 1.0,
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Center(
                    child: Text(
                  'Telehealth services made for you.',
                  textScaleFactor: 1.0,
                )),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Now you can connect with a doctor from '
                  'your smartphone, tablet '
                  'or computer- anytime, day or night.',
                  textScaleFactor: 1.0,
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Download our OnlineCare Telehealth app from the google play store.',
                  textScaleFactor: 1.0,
                  style: TextStyle(),
                ),
                const SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  padding: const EdgeInsets.all(5),
                  enableFeedback: true,
                  splashColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: AppColors.primaryColor,
                  child: const Center(
                      child: Text(
                    'Download Now',
                    textScaleFactor: 1.0,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  )),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: AppColors.black,
                  padding: const EdgeInsets.all(5),
                  enableFeedback: true,
                  splashColor: Colors.white,
                  child: const Center(
                      child: Text(
                    'Not Now',
                    textScaleFactor: 1.0,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Timer? _timer;
  static void showLoading() {
    EasyLoading.show(
      status: 'Please wait...',
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );
    Timer(const Duration(milliseconds: 900), () {
      EasyLoading.dismiss();
    });
  }

  static void showLoadingWithDuration(int time) {
    EasyLoading.show(
      status: 'Please wait...',
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );
    Timer(Duration(milliseconds: time), () {
      EasyLoading.dismiss();
    });
  }

  static void showLoadingNoTimer() {
    _timer?.cancel();
    EasyLoading.show(
      status: 'Please wait...',
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );
  }

  static void cancelLoading() async {
    _timer?.cancel();
    await EasyLoading.dismiss();
  }

  static void buyWithCode(
      BuildContext context, TextEditingController freeCodeController) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              child: AlertDialog(
                shape: const CustomShapeBorder(radius: 10),
                actionsPadding: const EdgeInsets.all(10),
                actionsAlignment: MainAxisAlignment.center,
                contentPadding: const EdgeInsets.all(10),
                insetPadding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * .27,
                    horizontal: MediaQuery.of(context).size.width * .010),
                title: const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Center(
                      child: Text(
                    'Buy with your free code.',
                    textScaleFactor: 1.0,
                    style: TextStyle(fontSize: 18),
                  )),
                ),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: freeCodeController,
                      style: TextStyle(
                          fontSize: 16 / MediaQuery.textScaleFactorOf(context)),
                      decoration:
                          buildInputDecoration(context, 'Enter your code'),
                    )
                  ],
                ),
                actions: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      RoundButton(
                          title: 'Subscribe Now',
                          onPress: () {
                            Navigator.pop(ctx);
                            if (freeCodeController.text.isNotEmpty) {
                              codeSubscription(freeCodeController, context);
                            } else {
                              Utils.snackBarMessage(
                                  'Please enter your free code', context);
                            }
                          }),
                      const SizedBox(
                        height: 10,
                      ),
                      RoundButtonBlack(
                          title: "Not Now",
                          onPress: () {
                            Navigator.of(context).pop();
                            freeCodeController.clear();
                          })
                    ],
                  )
                ],
              ),
            ),
            Positioned(
                top: 170,
                child: Image.asset(
                  'Assets/icon_logo.png',
                  height: 50,
                  width: 50,
                )),
          ],
        );
      },
    );
  }

  static void subSuccessDialog(
      BuildContext context, String type, String? message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          insetPadding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * .35,
              horizontal: MediaQuery.of(context).size.width * .015),
          content: Text(
            (message != null)
                ? message
                : 'Your have successfully subscribed\nfor $type package.',
            textScaleFactor: 1.0,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            Center(
              child: CardButton(
                height: MediaQuery.sizeOf(context).height * .040,
                width: MediaQuery.sizeOf(context).width * .38,
                color: AppColors.primary,
                title: 'Done',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, RoutesName.home),
              ),
            )
          ],
        );
      },
    );
  }

  static void subCancelDialog(BuildContext context, String msg) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          insetPadding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * .35,
              horizontal: MediaQuery.of(context).size.width * .015),
          content: Text(
            msg,
            textScaleFactor: 1.0,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: <Widget>[
            Center(
              child: CardButton(
                height: MediaQuery.sizeOf(context).height * .040,
                width: MediaQuery.sizeOf(context).width * .38,
                color: AppColors.primary,
                title: 'Done',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, RoutesName.home),
              ),
            )
          ],
        );
      },
    );
  }

  static Future<void> codeSubscription(
      TextEditingController codeController, BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id');
    final String? userToken = prefs.getString('access_token');
    try {
      DialogBoxes.showLoadingNoTimer();
      var response = await http
          .post(Uri.parse(AppUrl.buyWithCode), headers: <String, String>{
        'Oauthtoken': 'Bearer $userToken',
      }, body: {
        "patient_id": userId.toString(),
        'package_code': codeController.text.toString(),
      });
      DialogBoxes.cancelLoading();
      if (!context.mounted) return;
      // API call was successful, handle response data here
      var responseData = json.decode(response.body);
      codeController.clear();
      if (responseData['status'] == 'error') {
        debugPrint(responseData.toString());
        Utils.errorSnackBar(responseData['message'].toString(), context);
      } else {
        debugPrint(responseData.toString());
        context.read<CheckExpiry>().checkExpiry(context, false);
        Utils.snackBarMessage(responseData['message'].toString(), context);
        subSuccessDialog(
          context,
          '',
          responseData['message'].toString(),
        );
      }
    } on SocketException {
      DialogBoxes.cancelLoading();
      if (!context.mounted) return;
      Utils.snackBarMessage('Check your internet', context);
    } catch (e) {
      DialogBoxes.cancelLoading();
      debugPrint(e.toString());
    }
  }

  static Future<void> showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          insetPadding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * .35,
              horizontal: MediaQuery.of(context).size.width * .015),
          title: const Text(
            'Logout',
            textScaleFactor: 1.0,
          ),
          content: const Text(
            'Are you sure you want to logout?',
            textScaleFactor: 1.0,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                textScaleFactor: 1.0,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Logout',
                textScaleFactor: 1.0,
              ),
              onPressed: () async {
                final userPref =
                    Provider.of<User_view_model>(context, listen: false);
                Navigator.pop(ctx);
                await context.read<AuthViewModel>().logout(context, false);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showUpdateDialog(BuildContext context, String preMsg,
      String appVersion, String postMsg, String? applink) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(horizontal: 25),
          insetPadding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * .28,
              horizontal: MediaQuery.of(context).size.width * .060),
          title: const Text(
            'Update',
            textScaleFactor: 1.0,
          ),
          content: RichText(
            textScaleFactor: 1.0,
            text: TextSpan(
              text: preMsg,
              style: Theme.of(context).primaryTextTheme.bodyMedium,
              children: <TextSpan>[
                TextSpan(
                    text: appVersion,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor)),
                TextSpan(
                    text: postMsg,
                    style: Theme.of(context).primaryTextTheme.bodyMedium),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Not Now',
                textScaleFactor: 1.0,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              onPressed: () async {
                if (Platform.isIOS) {
                  await appStoreApp(applink);
                } else {
                  await playStoreApp();
                }
                if (!context.mounted) return;
                Navigator.of(ctx).pop();
              },
              child: const Text(
                'Update Now',
                textScaleFactor: 1.0,
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> playStoreApp() async {
    final pkgInfo = await PackageInfo.fromPlatform();
    final String appPackageName = pkgInfo.packageName.toString();
    try {
      var url = "market://details?id=$appPackageName";
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
        var url =
            "https://play.google.com/store/apps/details?id=$appPackageName";

        final uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          throw Exception('can not load $url');
        }

        throw Exception('can not load $url');
      }
    } catch (e) {
      debugPrint(e.toString());
      var url = "https://play.google.com/store/apps/details?id=$appPackageName";

      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
        throw Exception('can not load $url');
      }
    }
  }

  static Future<void> appStoreApp(String? applink) async {
    final pkgInfo = await PackageInfo.fromPlatform();
    const String appStoreId = '1596310894';
    try {
      var url = applink ?? "https://apps.apple.com/app/id$appStoreId";
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
        var url = applink ?? "https://apps.apple.com/app/id$appStoreId";

        final uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          throw Exception('can not load $url');
        }

        throw Exception('can not load $url');
      }
    } catch (e) {
      debugPrint(e.toString());
      var url = applink ?? "https://apps.apple.com/app/id$appStoreId";

      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
        throw Exception('can not load $url');
      }
    }
  }

  static Future<void> showConfirmDialogDel(
      BuildContext context, VoidCallback removeImage) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(horizontal: 25),
          insetPadding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * .28,
              horizontal: MediaQuery.of(context).size.width * .060),
          title: const Text(
            'Confirm',
            textScaleFactor: 1.0,
          ),
          content: const Text(
            'Are you sure? Do you want to delete this file?',
            textScaleFactor: 1.0,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Not Now',
                textScaleFactor: 1.0,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              onPressed: removeImage,
              child: const Text(
                'Yes Delete',
                textScaleFactor: 1.0,
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showDashboardDialog(
      BuildContext context,
      String title,
      VoidCallback btnOneCall,
      String btnOneTxt,
      VoidCallback btnTwoCall,
      String btnTwoTxt) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(horizontal: 25),
          insetPadding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * .28,
              horizontal: MediaQuery.of(context).size.width * .060),
          title: Center(
              child: Text(
            title.toString(),
            textScaleFactor: 1.0,
          )),
          actions: <Widget>[
            Column(
              children: [
                InkWell(
                  onTap: btnOneCall,
                  child: Ink(
                    decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 10),
                      child: Center(
                          child: Text(
                        btnOneTxt,
                        textScaleFactor: 1.0,
                        style: const TextStyle(color: Colors.white),
                      )),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                InkWell(
                  onTap: btnTwoCall,
                  child: Ink(
                    decoration: const BoxDecoration(
                        color: AppColors.primaryLightColor,
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 10),
                      child: Center(
                          child: Text(btnTwoTxt,
                              textScaleFactor: 1.0,
                              style: const TextStyle(color: Colors.white))),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Ink(
                    decoration: const BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                      child: Center(
                          child: Text('Not Now',
                              textScaleFactor: 1.0,
                              style: TextStyle(color: Colors.white))),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static Future<void> fetchEmailDialog(
    BuildContext context,
    String userEmail,
    String adminEmail,
    Function syncCall,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(horizontal: 25),
          insetPadding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * .22,
              horizontal: MediaQuery.of(context).size.width * .060),
          title: const Center(
              child: Text(
            'Test Results',
            textScaleFactor: 1.0,
          )),
          content: Column(children: [
            const Text(
              'Please send test results to the following email address.'
              'After sending email please tap on sync email button to view '
              'your test results inside the app.',
              textScaleFactor: 1.0,
              textAlign: TextAlign.start,
            ),
            InkWell(
              onTap: () {
                final emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: adminEmail,
                );
                launchUrlString(emailLaunchUri.toString());
              },
              child: Text(
                adminEmail,
                textScaleFactor: 1.0,
                style: const TextStyle(color: Colors.blueAccent),
                textAlign: TextAlign.start,
              ),
            ),
            const Text(
              'Please make sure you have to send your test results from the'
              'email registered with your DigiHealthCard Health Wallet account.'
              'Your registered email is:',
              textScaleFactor: 1.0,
              textAlign: TextAlign.start,
            ),
            Text(
              OnePref.getString('email').toString(),
              textScaleFactor: 1.0,
              style: const TextStyle(color: Colors.blueAccent),
              textAlign: TextAlign.start,
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * .008,
            ),
          ]),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CardButton(
                  height: MediaQuery.sizeOf(context).height * .040,
                  width: MediaQuery.sizeOf(context).width * .38,
                  color: Colors.grey[900] ?? Colors.grey,
                  title: 'Continue',
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                const SizedBox(
                  width: 10,
                ),
                CardButton(
                    title: 'Sync',
                    onPressed: () async {
                      Navigator.pop(
                        ctx,
                      );
                      syncCall;
                    },
                    height: MediaQuery.sizeOf(context).height * .040,
                    width: MediaQuery.sizeOf(context).width * .38,
                    color: AppColors.primaryColor)
              ],
            )
          ],
        );
      },
    );
  }

  static Future<void> showConfirmationDialog(
      BuildContext context,
      VoidCallback delete,
      String message,
      bool isVaccination,
      bool isDeleteAcc) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(horizontal: 25),
          title: Text(
            isVaccination ? 'Vaccine Schedule' : 'Confirm',
            textScaleFactor: 1.0,
            textAlign: isVaccination ? TextAlign.center : TextAlign.start,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          content: isVaccination
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    const Text(
                      'We have derived our vaccination guidelines from the CDC (USA),',
                      textScaleFactor: 1.0,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () async {
                        var url = "https://www.cdc.gov/";
                        final uri = Uri.parse(url);
                        if (!await launchUrl(uri,
                            mode: LaunchMode.platformDefault)) {
                          throw Exception('can not load $url');
                        }
                      },
                      child: const Text(
                        'https://www.cdc.gov/',
                        textScaleFactor: 1.0,
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                )
              : Text(
                  message.toString(),
                  textScaleFactor: 1.0,
                ),
          actions: <Widget>[
            Visibility(
              visible: !isVaccination,
              child: TextButton(
                child: const Text(
                  'Not Now',
                  textScaleFactor: 1.0,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ),
            isVaccination
                ? Center(
                    child: CardButton(
                      height: MediaQuery.sizeOf(context).height * .040,
                      width: MediaQuery.sizeOf(context).width * .38,
                      color: AppColors.primary,
                      title: 'Continue',
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  )
                : TextButton(
                    onPressed: isDeleteAcc
                        ? () {
                            context.read<ChangePasswordVM>().setStatus('');
                            Navigator.pop(ctx);
                          }
                        : () {
                            Navigator.pop(ctx);
                            delete();
                          },
                    child: Text(
                      isDeleteAcc ? 'Yes Exit' : 'Yes Delete',
                      textScaleFactor: 1.0,
                    ),
                  ),
          ],
        );
      },
    );
  }

  static Future<void> showConfirmCancelSubscription(
      BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(horizontal: 25),
          insetPadding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * .28,
              horizontal: MediaQuery.of(context).size.width * .060),
          title: const Text(
            'Confirm',
            textScaleFactor: 1.0,
          ),
          content: const Text(
            'Are you sure? Do you want to cancel your subscription?',
            textScaleFactor: 1.0,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Not Now',
                textScaleFactor: 1.0,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await Provider.of<SubscriptionViewModel>(context, listen: false)
                    .cancelSubscription(context);
                if (!context.mounted) return;
              },
              child: const Text(
                'Yes Cancel',
                textScaleFactor: 1.0,
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showCheckSubscription(
      BuildContext context, String subsStatus) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(horizontal: 25),
          insetPadding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * .28,
              horizontal: MediaQuery.of(context).size.width * .060),
          title: const Text(
            'Confirm',
            textScaleFactor: 1.0,
          ),
          content: Text(
            subsStatus,
            textScaleFactor: 1.0,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Not Now',
                textScaleFactor: 1.0,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                var url = '';
                if (Platform.isIOS) {
                  url = 'https://apps.apple.com/account/subscriptions';
                } else {
                  url = "https://play.google.com/store/account/subscriptions";
                }
                try {
                  final uri = Uri.parse(url);
                  if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
                    throw Exception('can not load $url');
                  }
                } catch (e) {
                  final uri = Uri.parse(url);
                  if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
                    throw Exception('can not load $url');
                  }
                }
              },
              child: const Text(
                'Continue',
                textScaleFactor: 1.0,
              ),
            ),
          ],
        );
      },
    );
  }

  static void showPickImageDialog(
      BuildContext context, AsyncCallback byCamera, AsyncCallback byGallery) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext cont) {
          return CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: byCamera,
                child: const Text(
                  'Use Camera',
                  textScaleFactor: 1.0,
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: byGallery,
                child: const Text(
                  'Upload from files',
                  textScaleFactor: 1.0,
                ),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Not Now',
                  textScaleFactor: 1.0, style: TextStyle(color: Colors.red)),
            ),
          );
        });
  }

  static Future<bool> onWillPopDialog(
      BuildContext context, bool willPop, bool isStart) async {
    // Show a dialog to confirm exit
    bool confirmExit = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Confirm exit',
            textScaleFactor: 1.0,
          ),
          content: const Text(
            'Do you want to exit the verification Process? '
            'Please make sure that you verify else your account will not be created.',
            textScaleFactor: 1.0,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'NOT NOW',
                textScaleFactor: 1.0,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: const Text(
                'YES EXIT',
                textScaleFactor: 1.0,
              ),
              onPressed: () {
                showLoading();
                Navigator.pop(dialogContext, true);
                (isStart || willPop)
                    ? Navigator.pushReplacementNamed(context, RoutesName.login)
                    : Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    // Return whether the user confirmed the exit or not
    return confirmExit;
  }

  static String formatPhoneNumber(String dialCode, String number) {
    // Remove any non-numeric characters from the phone number
    String digits = number.replaceAll(RegExp(r'\D+'), '');
    String? formatted = dialCode;
    // Check if the phone number is too short to format
    // if (digits.length < 10) {
    //   return dialCode + number;
    // }
    // Add the country code prefix
    // formatted = '${digits.substring(0, 1)}-';

    // Add the area code
    formatted += '-${digits.substring(0, 3)}-';

    // Add the first three digits of the phone number
    formatted += '${digits.substring(3, 6)}-';

    // Add the last four digits of the phone number
    formatted += digits.substring(6);

    return formatted;
  }
}
