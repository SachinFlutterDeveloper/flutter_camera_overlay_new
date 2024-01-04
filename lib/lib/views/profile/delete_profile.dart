import 'dart:async';

import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/home_view_model.dart';
import 'package:digihealthcardapp/views/profile/viewmodels/change_password.viewmodel.dart';
import 'package:digihealthcardapp/views/profile/widgets/appbar_leading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onepref/onepref.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteProfile extends StatefulWidget {
  const DeleteProfile({Key? key}) : super(key: key);

  @override
  State<DeleteProfile> createState() => _DeleteProfileState();
}

class _DeleteProfileState extends State<DeleteProfile> {
  String firstName = '', lastName = '', phone = '';
  String? _msg;
  int? status;
  TextEditingController? otpController;
  FocusNode? otpFocus;
  final formKey = GlobalKey<FormState>();
  SharedPreferences? sp;

  @override
  void initState() {
    super.initState();
    fetchLabels();
    otpController = TextEditingController();
    otpFocus = FocusNode();
  }

  List<String> deleteScreenLabels = [
    "We’re sorry to hear you’d like to delete your account.",
    "Please note that if you delete your account, you won’t be able to reactivate it later.",
    "Your basic profile information, profile picture, all your saved cards and any other data will be removed permanently and will not be recoverable.",
    "Additional Steps Required :",
    "A unique one time code will be generated and sent to you registered phone number.",
    "You need to verify by enter that one time code in next step.",
    "An unique One Time Code has been generated and sent to your following registered phone number :",
    "Please enter the One Time Code below :",
    "Permanently delete my account",
    "You have active subscriptions. Please cancel your subscription before you delete your account in order to avoid auto renewal of this subscription."
  ];

  Future<void> fetchLabels() async {
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    deleteScreenLabels = await homeViewModel.fetchlabels();
    SharedPreferences prefs_ = await SharedPreferences.getInstance();
    lastName = prefs_.getString('last_name') ?? '';
    firstName = prefs_.getString('first_name') ?? '';
    phone = prefs_.getString('phone') ?? '';
    setState(() {});
  }

  void _showConfirmRemovalDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text(
            'Confirm',
            textScaleFactor: 1.0,
          ),
          content: Text(
            OnePref.getString('delete_text').toString(),
            textScaleFactor: 1.0,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'NOT NOW',
                textScaleFactor: 1.0,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: const Text(
                'YES',
                textScaleFactor: 1.0,
              ),
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                final String? userToken = prefs.getString('access_token');
                final String? key = prefs.getString('verify_key');
                final String? userID = prefs.getString('id');
                final headers = {"Oauthtoken": "Bearer $userToken"};
                final body = {
                  'verify_key': key.toString(),
                  'code': otpController?.text.toString(),
                  'user_id': userID.toString(),
                };
                if (!context.mounted) return;
                context
                    .read<ChangePasswordVM>()
                    .delOTPApi(body, headers, context);
                if (kDebugMode) {
                  print('Api hit $body $headers');
                }
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
  }

  void _showConfirmDialog() {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text(
              'Confirm',
              textScaleFactor: 1.0,
            ),
            content: const Text(
              'Are you sure? do you want to send OTC request for '
              'permanently delete your account?',
              textScaleFactor: 1.0,
            ),
            actions: [
              TextButton(
                child: const Text(
                  'NOT NOW',
                  textScaleFactor: 1.0,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                  onPressed: () async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    final String? userId = prefs.getString('id');
                    final String? userToken = prefs.getString('access_token');
                    final headers = {"Oauthtoken": "Bearer $userToken"};
                    final body = {'user_id': userId.toString()};
                    if (!context.mounted) return;
                    context.read<ChangePasswordVM>().deleteAccount(
                        body, headers, context, deleteScreenLabels[9]);
                    if (kDebugMode) {
                      print('Api hit $body $headers');
                    }
                    Navigator.of(ctx).pop();
                  },
                  child: const Text(
                    'YES',
                    textScaleFactor: 1.0,
                  )),
            ],
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    otpFocus?.dispose();
//    errorController?.close();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;

    return DrawerWidget(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Delete Account',
              textScaleFactor: 1.0,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ),
            leadingWidth: 80,
            leading: AppbarLeading(
              backCallBack: () => Navigator.pop(context, '1122'),
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RoutesName.home, (route) => false);
                  },
                  icon: const ImageIcon(
                    AssetImage(
                      'Assets/home.png',
                    ),
                    color: AppColors.primaryColor,
                  )),
            ],
          ),
          body: (context.watch<ChangePasswordVM>().statusCode == null ||
                  context.watch<ChangePasswordVM>().statusCode!.isEmpty)
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $firstName $lastName',
                          textScaleFactor: 1.0,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: height * .020,
                        ),
                        Text(deleteScreenLabels[0],
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 18,
                            )),
                        SizedBox(
                          height: height * .020,
                        ),
                        Text(deleteScreenLabels[1],
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 18,
                            )),
                        SizedBox(
                          height: height * .020,
                        ),
                        Text(deleteScreenLabels[2],
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 18,
                            )),
                        SizedBox(
                          height: height * .020,
                        ),
                        Text(deleteScreenLabels[3],
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: height * .020,
                        ),
                        Text(deleteScreenLabels[4],
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 18,
                            )),
                        SizedBox(
                          height: height * .020,
                        ),
                        Text(deleteScreenLabels[5],
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 18,
                            )),
                        SizedBox(
                          height: height * .10,
                        ),
                        SizedBox(
                          height: height * .068,
                          width: width * .88,
                          child: CupertinoButton(
                              minSize: 10,
                              color: AppColors.primaryColor,
                              child: const Center(
                                child: Text(
                                  'Send OTC to my phone',
                                  textScaleFactor: 1.0,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                              ),
                              onPressed: () {
                                _showConfirmDialog();
                              }),
                        ),
                        SizedBox(
                          height: height * .01,
                        ),
                        SizedBox(
                          height: height * .068,
                          width: width * .88,
                          child: CupertinoButton(
                              minSize: 20,
                              color: AppColors.black,
                              child: const Center(
                                child: Text(
                                  'Not Now',
                                  textScaleFactor: 1.0,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context, '1122');
                              }),
                        )
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'OTC has been sent successfully',
                          textScaleFactor: 1.0,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: height * .030,
                        ),
                        Text(
                          deleteScreenLabels[6],
                          textScaleFactor: 1.0,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(
                          height: height * .030,
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Mobile Number: ',
                                textScaleFactor: 1.0,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[500]),
                              ),
                              Text(
                                phone,
                                textScaleFactor: 1.0,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: height * .030,
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          elevation: 5,
                          color: Theme.of(context).cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  deleteScreenLabels[7],
                                  textScaleFactor: 1.0,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  height: height * .030,
                                ),
                                Form(
                                  key: formKey,
                                  child: Pinput(
                                    defaultPinTheme:
                                        AppColors.defaultTheme(context),
                                    submittedPinTheme:
                                        AppColors.defaultTheme(context)
                                            .copyWith(
                                      decoration:
                                          AppColors.defaultTheme(context)
                                              .decoration
                                              ?.copyWith(
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                  border: Border.all(
                                                      color: AppColors
                                                          .primaryLightColor,
                                                      width: 2.0)),
                                    ),
                                    focusedPinTheme: AppColors.defaultTheme(
                                            context)
                                        .copyDecorationWith(
                                            border: Border.all(
                                                color: AppColors.primaryColor,
                                                width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Theme.of(context).cardColor),
                                    controller: otpController,
                                    focusNode: otpFocus,
                                    autofocus: true,
                                    onChanged: (value) {
                                      debugPrint(value);
                                    },
                                    pinAnimationType: PinAnimationType.fade,
                                    onTapOutside: (e) {
                                      otpFocus?.unfocus();
                                    },
                                    pinputAutovalidateMode:
                                        PinputAutovalidateMode.onSubmit,
                                    animationDuration:
                                        const Duration(milliseconds: 300),
                                  ),
                                  /* PinCodeTextField(
                                    appContext: context,
                                    length: 4,
                                    animationType: AnimationType.fade,
                                    onChanged: (value) {
                                      debugPrint(value);
                                    },
                                    pinTheme: PinTheme(
                                        shape: PinCodeFieldShape.box,
                                        fieldHeight: 50,
                                        fieldWidth: 40,
                                        selectedFillColor:
                                            AppColors.primaryLightColor,
                                        activeColor:
                                            AppColors.primaryLightColor,
                                        selectedColor:
                                            AppColors.primaryLightColor,
                                        activeFillColor:
                                            AppColors.primaryLightColor,
                                        inactiveColor:
                                            AppColors.primaryLightColor,
                                        inactiveFillColor:
                                            AppColors.primaryLightColor),
                                    autoFocus: false,
                                    autoDisposeControllers: true,
                                    autoUnfocus: true,
                                    // cursorColor: AppColors.black,
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
                                SizedBox(
                                  height: height * .030,
                                ),
                                InkWell(
                                  onTap: () async {
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
                                      _showConfirmRemovalDialog();
                                    }
                                  },
                                  child: Ink(
                                    height: height * .06,
                                    width: width * .6,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.red,
                                    ),
                                    child: Center(
                                        child: Text(
                                      deleteScreenLabels[8],
                                      textScaleFactor: 1.0,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    )),
                                  ),
                                ),
                                SizedBox(
                                  height: height * .030,
                                ),
                                InkWell(
                                  onTap: () => DialogBoxes.showConfirmationDialog(
                                      context,
                                      () {},
                                      'Are you sure? Do you want to exit this process?',
                                      false,
                                      true),
                                  child: Ink(
                                    height: height * .05,
                                    width: width * .6,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.grey[800],
                                    ),
                                    child: const Center(
                                        child: Text(
                                      'Not Now',
                                      textScaleFactor: 1.0,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    )),
                                  ),
                                ),
                                SizedBox(
                                  height: height * .08,
                                ),
                                const Text('Not received a code?',
                                    textScaleFactor: 1.0,
                                    style: TextStyle(
                                      fontSize: 14,
                                    )),
                                const SizedBox(
                                  height: .01,
                                ),
                                MaterialButton(
                                    color: AppColors.primaryLightColor,
                                    onPressed: () {
                                      // Navigator.pop(context);
                                      context
                                          .read<ChangePasswordVM>()
                                          .setStatus('');
                                    },
                                    child: const Text(
                                      'Resend Code',
                                      textScaleFactor: 1.0,
                                      style: TextStyle(color: AppColors.white),
                                    )),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
