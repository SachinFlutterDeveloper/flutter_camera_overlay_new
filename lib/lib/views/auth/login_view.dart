import 'dart:async';
import 'dart:io';

import 'package:digihealthcardapp/generated/assets.dart';
import 'package:digihealthcardapp/res/app_url.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/res/components/round_button.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/Location_view_model.dart';
import 'package:digihealthcardapp/viewModel/Theme_view_model.dart';
import 'package:digihealthcardapp/viewModel/auth_view_model.dart';
import 'package:digihealthcardapp/viewModel/check_expiry.dart';
import 'package:digihealthcardapp/viewModel/home_view_model.dart';
import 'package:digihealthcardapp/viewModel/social_view_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late FocusNode emailFocusNode = FocusNode();
  late FocusNode passwordFocusNode = FocusNode();
  bool isLoggedIn = false;

  @override
  void initState() {
    context.read<CheckExpiry>().getURl();
    context.read<HomeViewModel>().fetchLocURl();
    Provider.of<themeChanger>(context, listen: false).loadURL();
    fetchLocation();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    super.initState();
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final ValueNotifier<bool> _obscurePassword = ValueNotifier(true);

  bool isGLoggedIn = true;

  double? lat;
  double? lng;

  String id = '';

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> fetchLocation() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.getLocation();
    final position = locationProvider.position;
    if (position != null) {
      lat = position.latitude;
      lng = position.longitude;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('lat', lat.toString());
      await prefs.setString('long', lng.toString());
      // Use the latitude and longitude values here
    }
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    // ignore: unused_local_variable
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    String? token = await messaging.getToken();
    if (token != null) {
      if (kDebugMode) {
        print('Firebase Messaging token: $token');
      }
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('device_token', token);
    }
  }

  Future<void> fetchId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id');
    setState(() {
      id = ('$userId');
    });
  }

  int _tapCounter = 0;

  void _handleTap() {
    _tapCounter++;
    if (_tapCounter >= 6) {
      showDialog<void>(
        barrierDismissible: false, // user must tap button!
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'URL MODE',
              textScaleFactor: 1.0,
            ),
            actions: <Widget>[
              Column(
                children: [
                  Consumer<themeChanger>(builder: (context, Value, child) {
                    return RadioListTile<int>(
                      title: const Text(
                        'Demo URL',
                        textScaleFactor: 1.0,
                      ),
                      value: 0,
                      groupValue: Value.number,
                      onChanged: (newValue) {
                        Value.setURL(newValue ?? 0);
                        Navigator.pop(context);
                        AppUrl.updateBaseUrl(Value.number);
                        Utils.toastMessage('Demo URL');
                        if (kDebugMode) {
                          print(AppUrl.baseUrl);
                        }
                        _tapCounter = 0;
                        // Dismiss dialog
                      },
                    );
                  }),
                  Consumer<themeChanger>(builder: (context, value, child) {
                    return RadioListTile<int>(
                      title: const Text(
                        'Live URL',
                        textScaleFactor: 1.0,
                      ),
                      value: 1,
                      groupValue: value.number,
                      onChanged: (newValue) {
                        value.setURL(newValue ?? 1);
                        Navigator.pop(context);
                        AppUrl.updateBaseUrl(value.number);
                        Utils.toastMessage('Live URL');
                        if (kDebugMode) {
                          print(AppUrl.baseUrl);
                        }
                        _tapCounter = 0;
                      },
                    );
                  }),
                ],
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final authViewMode = Provider.of<AuthViewModel>(context);
    final socialAuth = Provider.of<SocialViewModel>(context);
    EasyLoading.init();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, right: 20, left: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _handleTap(),
                      child: Image(
                          image:
                              (Theme.of(context).brightness == Brightness.light)
                                  ? const AssetImage('Assets/logo.png')
                                  : const AssetImage('Assets/white_log.png')),
                    ),
                    SizedBox(
                      height: height * .040,
                    ),
                    TextFormField(
                      focusNode: emailFocusNode,
                      controller: emailController,
                      style: TextStyle(
                          fontSize: 16 / MediaQuery.textScaleFactorOf(context)),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(
                            fontSize:
                                16 / MediaQuery.textScaleFactorOf(context)),
                        fillColor: Theme.of(context).cardColor,
                        filled: true,
                        prefixIcon: const Icon(Icons.email_outlined),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppColors.primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Color(0xffE4E7EB)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onTapOutside: (event) {
                        emailFocusNode.unfocus();
                      },
                      onFieldSubmitted: (value) {
                        Utils.fieldFocusChange(
                            context, emailFocusNode, passwordFocusNode);
                      },
                    ),
                    SizedBox(
                      height: height * .015,
                    ),
                    ValueListenableBuilder(
                        valueListenable: _obscurePassword,
                        builder: (context, value, child) {
                          return TextFormField(
                            focusNode: passwordFocusNode,
                            controller: passwordController,
                            style: TextStyle(
                                fontSize:
                                    16 / MediaQuery.textScaleFactorOf(context)),
                            onTapOutside: (event) {
                              passwordFocusNode.unfocus();
                            },
                            obscureText: _obscurePassword.value,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                  fontSize: 16 /
                                      MediaQuery.textScaleFactorOf(context)),
                              fillColor: Theme.of(context).cardColor,
                              filled: true,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: InkWell(
                                  onTap: () {
                                    _obscurePassword.value =
                                        !_obscurePassword.value;
                                  },
                                  child: Icon(_obscurePassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: AppColors.primaryColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Color(0xffE4E7EB)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }),
                    SizedBox(
                      height: height * .03,
                    ),
                    RoundButton(
                        title: 'Login',
                        onPress: () async {
                          if (emailController.text.isEmpty) {
                            Utils.snackBarMessage(
                                'Please enter email', context);
                          } else if (passwordController.text.isEmpty) {
                            Utils.snackBarMessage(
                                'Please enter password', context);
                          } else if (passwordController.text.length < 3) {
                            Utils.snackBarMessage(
                                'Password should not be less than 6 digits',
                                context);
                          } else {
                            FirebaseMessaging messaging =
                                FirebaseMessaging.instance;
                            String? token = await messaging.getToken();
                            if (kDebugMode) {
                              print('Firebase Messaging token: $token');
                            }
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setString('device_token', token ?? '');
                            await prefs.setString('lat', lat.toString());
                            await prefs.setString('long', lng.toString());
                            final String? userToken =
                                prefs.getString('access_token');
                            Map<String, String> header = {
                              "Oauthtoken": "Bearer $userToken"
                            };
                            Map data = {
                              'email': emailController.text.toString(),
                              'password': passwordController.text.toString(),
                              'latitude': lat.toString(),
                              'longitude': lng.toString(),
                              'device_token': token.toString(),
                              'type': 'patient',
                              'platform': 'android'
                            };
                            if (!context.mounted) return;
                            authViewMode.loginApi(data, header, context);
                            if (kDebugMode) {
                              print('Api hit ${data.values}');
                            }
                            if (authViewMode.loading) DialogBoxes.showLoading();
                          }
                        }),
                    SizedBox(
                      height: height * .01,
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, RoutesName.forgot);
                        },
                        child: const Text(
                          'Forgot Password?',
                          textScaleFactor: 1.0,
                          style: TextStyle(
                              fontSize: 18,
                              color: AppColors.blue,
                              decoration: TextDecoration.underline),
                        )),
                    SizedBox(
                      height: height * .04,
                    ),
                    /* InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                      onTap: () => socialAuth.loginWithFacebook(context),
                      child: const Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Image(
                            image: AssetImage('Assets/fb login.png'),
                            height: 60,
                          ),
                          Center(
                              child: Text(
                            'Login with Facebook',
                            textScaleFactor: 1.0,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ))
                        ],
                      ),
                    ),
                     */
                    SizedBox(
                      height: height * .008,
                    ),
                    (Platform.isIOS)
                        ? InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            onTap: () => socialAuth.signInWithApple(context),
                            child: const Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Image(
                                  image: AssetImage(Assets.appleLogin),
                                  height: 60,
                                ),
                                Center(
                                    child: Text(
                                  'Login with Apple',
                                  textScaleFactor: 1.0,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ))
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                    SizedBox(
                      height: height * .008,
                    ),
                    InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                      onTap: () => socialAuth.signInWithGoogle(context),
                      child: const Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Image(
                            image: AssetImage('Assets/google login.png'),
                            height: 60,
                          ),
                          Center(
                              child: Text(
                            'Login with Google',
                            textScaleFactor: 1.0,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * .03,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 142,
                          height: 1,
                          color: Colors.black,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            'OR',
                            textScaleFactor: 1.0,
                          ),
                        ),
                        Container(
                          width: 142,
                          height: 1,
                          color: Colors.black,
                        )
                      ],
                    ),
                    SizedBox(
                      height: height * .03,
                    ),
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            fixedSize: const Size(320, 50),
                            side: const BorderSide(
                                color: AppColors.primaryColor, width: 1)),
                        onPressed: () {
                          Navigator.pushNamed(context, RoutesName.signup);
                        },
                        child: const Text(
                          'Create an Account',
                          textScaleFactor: 1.0,
                          style: TextStyle(
                            color: AppColors.primaryColor,
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
