import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:digihealthcardapp/generated/assets.dart';
import 'package:digihealthcardapp/res/app_url.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/global_drawer.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/check_expiry.dart';
import 'package:digihealthcardapp/viewModel/home_screen_model.dart';
import 'package:digihealthcardapp/views/chat_ai/chat_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:onepref/onepref.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final String subscription;
  const HomeScreen({Key? key, this.subscription = 'error'}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Text> titles = [
    const Text(
      'Immunization',
      textScaleFactor: 1.0,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 14),
    ),
    const Text('Health Card',
        textScaleFactor: 1.0,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14)),
    const Text('Test Results',
        textScaleFactor: 1.0,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14)),
    const Text('Vaccination\nCenter',
        textScaleFactor: 1.0,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14)),
    const Text('ID Card',
        textScaleFactor: 1.0,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14)),
    const Text('DigiChat AI',
        textScaleFactor: 1.0,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14)),
    const Text('Share App',
        textScaleFactor: 1.0,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 14, color: Colors.red, fontWeight: FontWeight.w900)),
    const Text('My Profile',
        textScaleFactor: 1.0,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14)),
    const Text('Logout',
        textScaleFactor: 1.0,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14)),
  ];
  var expStatus = 'error';
  List<String> imageUrls = [
    Assets.assetsChildImmunization,
    Assets.assetsShowcard,
    Assets.assetsIcTestResult,
    Assets.assetsTestLocations,
    Assets.assetsIcIdCard,
    Assets.digiAIChat,
    Assets.assetsIcShareApp,
    Assets.assetsIcProfile,
    Assets.assetsIcLogoutCc,
  ];

  @override
  void initState() {
    context.read<CheckExpiry>().checkExpiry(context, false);
    fetchLabels();
    Future.delayed(const Duration(seconds: 1), () {
      fetchLabels();
    });
    context.read<CheckExpiry>().checkVersion(context);
    Provider.of<HomeModel>(context, listen: false).loadPermission();
    super.initState();
  }

  String billing = 'trail';
  String message = '';
  var permissionStatus = false;
  Future<void> fetchLabels() async {
    billing = OnePref.getString('billing') ?? 'trail';
    message = OnePref.getString('sub_message') ??
        'Your subscription will be expired in 6 months.';
    expStatus = OnePref.getString('trial_status') ?? 'error';
    if (Platform.isAndroid) {
      var status = await Permission.camera.status;
      permissionStatus = status.isGranted || status.isLimited;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // If the list does not exist in SharedPreferences, fetch it from the server
    final response = await http.post(
      Uri.parse(
        AppUrl.labels,
      ),
    );
    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);

      final String testResultEmail =
          jsonBody['data']['testresults']['email'].toString();
      final String footerline1 = jsonBody['data']['footer']['line1'].toString();
      final String footerline2 = jsonBody['data']['footer']['line2'].toString();
      final String shareText =
          jsonBody['data']['share_text']['text'].toString();
      final String infoEmail = jsonBody['data']['info']['emailinfo'].toString();
      List<dynamic> patientreg =
          jsonBody['data']['patient_registeration'] as List;
      final String deleteText = jsonBody['data']['delete_text'].toString();
      final String policyUrl = patientreg[0]['url'].toString();
      final String termsUrl = patientreg[1]['url'].toString();
      final String subPolicyUrl = patientreg[2]['url'].toString();
      final String securityUrl = patientreg[3]['url'].toString();
      if (kDebugMode) {
        print(patientreg);
        print(footerline2 + securityUrl + policyUrl);
      }
      // Save the card types to SharedPreferences
      await prefs.setString('fetch_email', testResultEmail);
      await prefs.setString('share_text', shareText);
      await prefs.setString('footer_l1', footerline1);
      await prefs.setString('footer_l2', footerline2);
      await prefs.setString('security_url', securityUrl);
      await prefs.setString('sub_url', subPolicyUrl);
      await prefs.setString('policy_url', policyUrl);
      await prefs.setString('terms_url', termsUrl);
      await prefs.setString('info_mail', infoEmail);
      await prefs.setString('delete_text', deleteText);
    } else {
      throw Exception('Failed to fetch URl');
    }
    setState(() {
      expStatus = OnePref.getString('trial_status') ?? 'error';
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    List<VoidCallback> imageCallbacks = [
      () => DialogBoxes.showDashboardDialog(
          context,
          'Immunization',
          () {
            Navigator.popAndPushNamed(context, RoutesName.immunization);
          },
          'Child Immunization',
          () {
            Utils.snackBarMessage('Coming soon..', context);
            Navigator.pop(context);
          },
          'Adult Immunization') /*Navigator.pushNamed(context, RoutesName.immunization)*/,
      () => DialogBoxes.showDashboardDialog(
          context,
          'Health Cards',
          () {
            Navigator.popAndPushNamed(context, RoutesName.showCard);
          },
          'Show Cards',
          () {
            Navigator.popAndPushNamed(context, RoutesName.scanCard);
          },
          'Scan Card'),
      () => Navigator.pushNamed(context, RoutesName.test),
      () => Navigator.pushNamed(context, RoutesName.testLocation),
      () => DialogBoxes.showDashboardDialog(
          context,
          'Identity Cards',
          () {
            Navigator.popAndPushNamed(context, RoutesName.showID);
          },
          'Show Cards',
          () {
            Navigator.popAndPushNamed(context, RoutesName.scanID);
          },
          'Scan Card'),
      () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  const AIChat())) /*DialogBoxes.telehealth(context)*/,
      () async {
        SharedPreferences sp = await SharedPreferences.getInstance();
        Share.share(sp.getString('share_text').toString());
      },
      () => Navigator.pushNamed(context, RoutesName.profile),
      () => DialogBoxes.showLogoutDialog(this.context),
    ];

    return DrawerWidget(
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Dashboard',
                textScaleFactor: 1.0,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    onPressed: () {
                      DrawerWidget.of(context)?.toggle();
                    },
                    icon: const ImageIcon(
                      AssetImage(Assets.assetsSidemenu),
                      color: AppColors.primaryColor,
                    ),
                  );
                },
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, left: 25, right: 25, bottom: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Platform.isAndroid
                              ? Consumer<HomeModel>(
                                  builder: (context, value, child) {
                                  if (value.hasCameraPermission == true ||
                                      permissionStatus == true) {
                                    return SizedBox(
                                      height: height * .015,
                                    );
                                  } else {
                                    return Container(
                                      height: height * .18,
                                      width: width,
                                      decoration: BoxDecoration(
                                          color: Colors.white24,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.black26,
                                              width: .5)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Permissions Required.',
                                              textScaleFactor: 1.0,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            const Text(
                                              'Please allow the required permissions. Please note that certain app '
                                              'features will not work until '
                                              'you will not allow the required permissions.',
                                              textScaleFactor: 1.0,
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          backgroundColor:
                                                              AppColors
                                                                  .primaryColor),
                                                  onPressed: () {
                                                    Navigator.pushNamed(context,
                                                        RoutesName.permissions);
                                                  },
                                                  child: const Text(
                                                    'Review & Allow Permissions',
                                                    textScaleFactor: 1.0,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12),
                                                  )),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                })
                              : const SizedBox.shrink(),
                          SizedBox(
                            height: height * .005,
                          ),
                          if (expStatus == 'error')
                            Container(
                              height: height * .17,
                              width: width,
                              decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.black26, width: .5)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Trial Expired.',
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const Text(
                                      'Your trial period has been expired. Please do proceed and select'
                                      ' a subscription package.',
                                      textScaleFactor: 1.0,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              backgroundColor:
                                                  AppColors.primaryColor),
                                          onPressed: () {
                                            Navigator.pushNamed(context,
                                                RoutesName.subscription);
                                          },
                                          child: const Text(
                                            'Subscribe Now',
                                            textScaleFactor: 1.0,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          )),
                                    )
                                  ],
                                ),
                              ),
                            )
                          else if (OnePref.getString('trial_status')
                                      ?.toLowerCase() ==
                                  'success' &&
                              billing == 'trail')
                            Container(
                              height: height * .10,
                              width: width,
                              decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.black26, width: .5)),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Trial Period',
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      message,
                                      textScaleFactor: 1.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          SizedBox(
                            height: height * .005,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Image(
                                image: (Theme.of(context).brightness ==
                                        Brightness.light)
                                    ? const AssetImage('Assets/logo.png')
                                    : const AssetImage('Assets/white_log.png')),
                          ),
                          SizedBox(
                            height: height * .03,
                          ),
                          SizedBox(
                            height: height * .60,
                            child: GridView.count(
                              mainAxisSpacing: 40,
                              crossAxisSpacing: 20,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              clipBehavior: Clip.none,
                              childAspectRatio: 1,
                              crossAxisCount: 3,
                              children:
                                  List.generate(imageCallbacks.length, (index) {
                                if (expStatus == 'error' &&
                                    index >= 0 &&
                                    index <= 5) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 5, right: 5, top: 10),
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      clipBehavior: Clip.none,
                                      children: [
                                        Opacity(
                                           opacity: 0.5,
                                          child: Image.asset(
                                            imageUrls[index],
                                            fit: BoxFit.cover,
                                            color: (Theme.of(context)
                                                        .brightness ==
                                                    Brightness.dark)
                                                ? Colors.white
                                                : null,
                                          ),
                                        ),
                                        Positioned(
                                            right: -5,
                                            left: -5,
                                            top: 100,
                                            child: Opacity(
                                                opacity: .5,
                                                child: titles[index])),
                                      ],
                                    ),
                                  );
                                } else {
                                  return InkWell(
                                    splashFactory: InkRipple.splashFactory,
                                    customBorder:
                                        const CircleBorder(eccentricity: .0),
                                    onTap: imageCallbacks[index],
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 5, right: 5, top: 10),
                                      child: Stack(
                                        alignment: Alignment.topCenter,
                                        clipBehavior: Clip.none,
                                        children: [
                                          Image.asset(
                                            imageUrls[index],
                                            fit: BoxFit.cover,
                                            color: (Theme.of(context)
                                                        .brightness ==
                                                    Brightness.dark)
                                                ? Colors.white
                                                : null,
                                          ),
                                          Positioned(
                                              right: -5,
                                              left: -5,
                                              top: 100,
                                              child: titles[index]),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              }),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    var url = 'https://digihealthcard.com';
                    final uri = Uri.parse(url);
                    if (!await launchUrl(uri,
                        mode: LaunchMode.platformDefault)) {
                      throw Exception('can not load $url');
                    }
                  },
                  child: SizedBox(
                    width: width,
                    height: height * .090,
                    child: Image.asset(
                      'Assets/ad.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
