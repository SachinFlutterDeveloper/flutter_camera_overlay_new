import 'dart:convert';
import 'dart:io';

import 'package:digihealthcardapp/models/user_model.dart';
import 'package:digihealthcardapp/repositories/auth_repositories.dart';
import 'package:digihealthcardapp/res/app_url.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/user_view_model.dart';
import 'package:digihealthcardapp/views/social_login/signup_with_fb.dart';
import 'package:digihealthcardapp/views/social_login/signup_with_google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialViewModel with ChangeNotifier {
  AccessToken? _accessToken;
  AccessToken? get accessToken => _accessToken;

  Map<String, dynamic>? userData;
  Map<String, dynamic>? get _userData => userData;

  bool _socialSignUploading = false;
  bool get socialSignUploading => _socialSignUploading;

  setSignUpLoading(bool value) {
    _socialSignUploading = value;
    notifyListeners();
  }

  void setToken(AccessToken? value) {
    _accessToken = value;
    notifyListeners();
  }

  void setUser(Map<String, dynamic>? value) {
    userData = value;
    notifyListeners();
  }

  //SignIn with Facebook
  loginWithFacebook(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance
          .login(permissions: ['public_profile', 'email']);
      DialogBoxes.showLoadingNoTimer();
      if (result.status == LoginStatus.success) {
        // tokenAPI();
        setToken(result.accessToken);
        final userData = await FacebookAuth.instance.getUserData();
        setUser(userData);
        debugPrint('FB User: ${userData.toString()}');
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String email = userData['email'].toString();
        final String name = userData['name'].toString();
        final String picture = userData['picture']['data']['url'].toString();
        final String imageUrl = picture;
        await prefs.setString('image', imageUrl);
        final String socialId = userData['id'].toString();
        const String socialLoginPlat = 'facebook';
        await prefs.setString('social_id', socialId.toString());
        await prefs.setString('from_social', socialLoginPlat.toString());
        final String? token = prefs.getString('device_token');
        final String? userToken = prefs.getString('access_token');
        final String? latitude = prefs.getString('lat');
        final String? longitude = prefs.getString('long');
        final String? profileImgUrl = prefs.getString('image');
        Map<String, String> header = {"Oauthtoken": "Bearer $userToken"};
        Map data = {
          'email': email.toString(),
          'first_name': name.toString(),
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'device_token': token.toString(),
          'type': 'patient',
          'hospital_id': 'HOSPITAL_ID_EMCURA',
          'picture': profileImgUrl.toString(),
          'social_id': socialId.toString(),
          'gender': '_',
          'from_social': socialLoginPlat.toString(),
          'current_app': 'CURRENT_APP',
          'platform': (Platform.isAndroid) ? 'android' : 'iphone'
        };
        if (!context.mounted) return;
        socialApiForFB(data, header, context);
        if (kDebugMode) {
          print('Login Success, $data $header');
        }
      } else {
        DialogBoxes.cancelLoading();
        if (kDebugMode) {
          print(result.status);
          print(result.message);
        }
      }
    } on SocketException {
      DialogBoxes.cancelLoading;
      if (!context.mounted) return;
      Utils.errorSnackBar('Please check your internet connection', context);
    } catch (e) {
      DialogBoxes.cancelLoading;
      debugPrint('Error signing in with facebook: $e');
    }
  }

  logoutF(BuildContext context) async {
    await FacebookAuth.instance.logOut();
    setToken(null);
    setUser(null);
  }

  //SignIn with Google
  static final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: <String>['email']);

  static signOut() => _googleSignIn.signOut();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  signInWithGoogle(BuildContext context) async {
    DialogBoxes.showLoadingNoTimer();
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      if (!context.mounted) return;
      checkGoogleUser(context);
      tokenAPI();
    } on SocketException catch (e) {
      DialogBoxes.cancelLoading;
      debugPrint('Socket error: $e');
      Utils.errorSnackBar('Please check your internet connection', context);
    } catch (e) {
      DialogBoxes.cancelLoading();
      if (kDebugMode) {
        print("Error signing in with Google: $e");
      }
    }
  }

  Future<void> checkGoogleUser(BuildContext context) async {
    User? gUser = _auth.currentUser;
    if (gUser != null) {
      String googleAccountId = gUser.providerData[0].uid.toString();
      if (kDebugMode) {
        print('Google Account ID: $gUser');
      }
      debugPrint('user id Send to server: ${gUser.providerData[0].uid}');
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String email = gUser.email.toString();
      final String name = gUser.displayName.toString();
      final String picture = gUser.photoURL.toString();
      if (picture != null) {
        final String imageUrl = picture;
        await prefs.setString('image', imageUrl);
      }
      final String socialId = gUser.providerData[0].uid.toString();
      const String socialLoginPlat = 'google';
      await prefs.setString('social_id', socialId.toString());
      await prefs.setString('from_social', socialLoginPlat.toString());
      final String? token = prefs.getString('device_token');
      final String? userToken = prefs.getString('access_token');
      final String? latitude = prefs.getString('lat');
      final String? longitude = prefs.getString('long');
      final String? imageUrl = prefs.getString('image');

      Map<String, String> header = {"Oauthtoken": "Bearer $userToken"};
      Map data = {
        'email': email.toString(),
        'first_name': name.toString(),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'device_token': token.toString(),
        'type': 'patient',
        'hospital_id': 'HOSPITAL_ID_EMCURA',
        'picture': imageUrl.toString(),
        'social_id': socialId.toString(),
        'gender': '_',
        'from_social': socialLoginPlat.toString(),
        'current_app': 'CURRENT_APP',
        'platform': (Platform.isAndroid) ? 'android' : 'iphone'
      };
      if (!context.mounted) return;
      DialogBoxes.cancelLoading();
      socialApiForGoogle(data, header, context);
      if (kDebugMode) {
        print('Login Success, $data $header');
      }
    }
  }

  signOutG() {
    signOut();
    _auth.signOut();
  }

  /// Sign in with Apple
  Future<void> signInWithApple(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    DialogBoxes.showLoadingNoTimer();
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      if (credential.email != null) {
        await sp.setString('email_appleUser', credential.email.toString());
        await sp.setString('name_appleUser', credential.givenName.toString());
        await sp.setString('appleId', credential.userIdentifier.toString());
      } else if (credential.userIdentifier != null) {
        await sp.setString('appleId', credential.userIdentifier.toString());
      }
      if (!context.mounted) return;
      DialogBoxes.cancelLoading();
      checkAppleUser(context);
      debugPrint(credential.toString());
    } on SocketException {
      DialogBoxes.cancelLoading;
      if (!context.mounted) return;
      Utils.errorSnackBar('Please check your internet connection', context);
    } catch (e) {
      debugPrint('Error Signing in with Apple: $e');
      DialogBoxes.cancelLoading();
    }
  }

  Future<void> checkAppleUser(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String email = prefs.getString('email_appleUser').toString();
    final String name = prefs.getString('name_appleUser').toString();
    await prefs.setString('image', '');
    final String socialId = prefs.getString('appleId').toString();
    const String socialLoginPlat = 'apple';
    await prefs.setString('social_id', socialId.toString());
    await prefs.setString('from_social', socialLoginPlat.toString());
    final String? token = prefs.getString('device_token');
    final String? userToken = prefs.getString('access_token');
    final String? latitude = prefs.getString('lat');
    final String? longitude = prefs.getString('long');
    final String? imageUrl = prefs.getString('image');

    Map<String, String> header = {"Oauthtoken": "Bearer $userToken"};
    Map data = {
      'email': email.toString(),
      'first_name': name.toString(),
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'device_token': token.toString(),
      'type': 'patient',
      'hospital_id': 'HOSPITAL_ID_EMCURA',
      'picture': imageUrl.toString(),
      'social_id': socialId.toString(),
      'gender': '_',
      'from_social': socialLoginPlat.toString(),
      'current_app': 'CURRENT_APP',
      'platform': 'iphone'
    };
    if (!context.mounted) return;
    socialApiForApple(data, header, context);
    if (kDebugMode) {
      print('Apple Login Success, $data $header');
    }
  }

  final _myRepo = AuthRepositories();

  //Facebook Server Api
  Future<void> socialApiForFB(
      dynamic data, dynamic header, BuildContext context) async {
    setSignUpLoading(true);
    DialogBoxes.showLoadingNoTimer();
    _myRepo.socialLogin(context, data, header).then((value) async {
      DialogBoxes.cancelLoading();
      setSignUpLoading(false);
      final userPreference =
          Provider.of<User_view_model>(context, listen: false);
      userPreference.saveUser(
        user(
          id: value['user']['id'].toString(),
          firstName: value['user']['first_name'].toString(),
          lastName: value['user']['last_name'].toString(),
          email: value['user']['email'].toString(),
          image: value['user']['image'].toString(),
          phone: value['user']['phone'].toString(),
          username: value['user']['username'].toString(),
          relationship: value['user']['relationship'].toString(),
          birthdate: value['user']['birthdate'].toString(),
          country: value['user']['country'].toString(),
          state: value['user']['state'].toString(),
          city: value['user']['city'].toString(),
          zipcode: value['user']['zipcode'].toString(),
          residency: value['user']['residency'].toString(),
          maritalStatus: value['user']['marital_status'].toString(),
          gender: value['user']['gender'].toString(),
        ),
      );
      final isApproved = value['user']['is_approved'].toString();
      final fName = value['user']['first_name'].toString();
      final lName = value['user']['last_name'].toString();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('approval_code', isApproved);
      final accessToken = value['user']['access_token'].toString();
      await prefs.setString('access_token', accessToken);
      if (!context.mounted) return;
      if (isApproved == '1') {
        Future.delayed(const Duration(milliseconds: 600), () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Navigator.pushReplacementNamed(context, RoutesName.splash);
        });
        (lName != null)
            ? Utils.snackBarMessage('Welcome, $fName $lName', context)
            : Utils.snackBarMessage('Welcome, $fName', context);
      } else if (isApproved == '0') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FacebookSignUp(
                      userData: _userData ?? userData,
                      isHome: false,
                    )));
      } else {
        return;
      }
      if (kDebugMode) {
        print(value.toString());
      }
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      if (kDebugMode) {
        Utils.snackBarMessage(error.toString(), context);
        print(error.toString());
      }
    });
  }

  //Google login server Api

  Future<void> socialApiForGoogle(
      dynamic data, dynamic header, BuildContext context) async {
    setSignUpLoading(true);
    DialogBoxes.showLoadingNoTimer();
    _myRepo.socialLogin(context, data, header).then((value) async {
      setSignUpLoading(false);
      DialogBoxes.cancelLoading();
      final userPreference =
          Provider.of<User_view_model>(context, listen: false);
      userPreference.saveUser(
        user(
          id: value['user']['id'].toString(),
          firstName: value['user']['first_name'].toString(),
          lastName: value['user']['last_name'].toString(),
          email: value['user']['email'].toString(),
          image: value['user']['image'].toString(),
          phone: value['user']['phone'].toString(),
          username: value['user']['username'].toString(),
          relationship: value['user']['relationship'].toString(),
          birthdate: value['user']['birthdate'].toString(),
          country: value['user']['country'].toString(),
          state: value['user']['state'].toString(),
          city: value['user']['city'].toString(),
          zipcode: value['user']['zipcode'].toString(),
          residency: value['user']['residency'].toString(),
          maritalStatus: value['user']['marital_status'].toString(),
          gender: value['user']['gender'].toString(),
        ),
      );
      final fName = value['user']['first_name'].toString();
      final lName = value['user']['last_name'].toString();
      final isApproved = value['user']['is_approved'].toString();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('approval_code', isApproved);
      final accessToken = value['user']['access_token'].toString();
      await prefs.setString('access_token', accessToken);

      if (!context.mounted) return;
      if (isApproved == '1') {
        (lName != null)
            ? Utils.snackBarMessage('Welcome, $fName $lName', context)
            : Utils.snackBarMessage('Welcome, $fName', context);
        Future.delayed(const Duration(milliseconds: 600), () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Navigator.pushReplacementNamed(context, RoutesName.splash);
        });
      } else if (isApproved == '0') {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const GoogleSignup()));
      } else {
        return;
      }
      if (kDebugMode) {
        print(value.toString());
      }
    }).onError((error, stackTrace) {
      setSignUpLoading(false);
      DialogBoxes.cancelLoading();
      if (kDebugMode) {
        Utils.snackBarMessage(error.toString(), context);
        print("error: $error");
      }
    });
  }

//Apple login server Api
  Future<void> socialApiForApple(
      dynamic data, dynamic header, BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setSignUpLoading(true);
    DialogBoxes.showLoadingNoTimer();
    if (!context.mounted) return;
    _myRepo.appleLogin(context, data, header).then((value) async {
      DialogBoxes.cancelLoading();
      final userPreference =
          Provider.of<User_view_model>(context, listen: false);
      userPreference.saveUser(
        user(
          id: value['user']['id'].toString(),
          firstName: value['user']['first_name'].toString(),
          lastName: value['user']['last_name'].toString(),
          email: value['user']['email'].toString(),
          image: value['user']['image'].toString(),
          phone: value['user']['phone'].toString(),
          username: value['user']['username'].toString(),
          relationship: value['user']['relationship'].toString(),
          birthdate: value['user']['birthdate'].toString(),
          country: value['user']['country'].toString(),
          state: value['user']['state'].toString(),
          city: value['user']['city'].toString(),
          zipcode: value['user']['zipcode'].toString(),
          residency: value['user']['residency'].toString(),
          maritalStatus: value['user']['marital_status'].toString(),
          gender: value['user']['gender'].toString(),
          isApproved: value['user']['is_approved'].toString(),
        ),
      );
      final fName = value['user']['first_name'].toString();
      final lName = value['user']['last_name'].toString();
      final email = value['user']['email'].toString();
      final isApproved = value['user']['is_approved'].toString();
      final prefs = await SharedPreferences.getInstance();
      final accessToken = value['user']['access_token'].toString();
      if (accessToken.isEmpty) {
        tokenAPI();
      }
      await prefs.setString('access_token', accessToken);
      await prefs.setString('approval_code', isApproved);
      if (!context.mounted) return;
      if (isApproved.isNotEmpty && isApproved == '1') {
        (lName.isNotEmpty)
            ? Utils.snackBarMessage('Welcome, $fName $lName', context)
            : Utils.snackBarMessage('Welcome, $fName', context);
        Future.delayed(const Duration(milliseconds: 600), () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Navigator.pushReplacementNamed(context, RoutesName.splash);
        });
      } else if (isApproved.isNotEmpty || isApproved == '0') {
        if (kDebugMode) {
          print(sp.getString('email_appleUser').toString() +
              sp.getString('name_appleUser').toString());
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GoogleSignup(
                      isApple: true,
                      appleName: (fName != '' && fName != 'null') ? fName : '',
                      applelName: (lName != '' && lName != 'null') ? lName : '',
                      appleEmail: (email != '' && email != 'null') ? email : '',
                    )));
      }
      if (kDebugMode) {
        print(value.toString());
      }
    }).onError((error, stackTrace) {
      setSignUpLoading(false);
      DialogBoxes.cancelLoading();
      if (kDebugMode) {
        Utils.snackBarMessage(error.toString(), context);
        print("error: $error");
      }
    });
  }

  //Header token
  Future<void> tokenAPI() async {
    var response = await http.post(Uri.parse(AppUrl.accessToken), body: {
      'code': '123',
      'grant_type': 'client_credentials',
      'client_secret': '123',
      'client_id': 'zohaib'
    });

    if (response.statusCode == 200) {
      // API call was successful, handle response data here
      var responseData = json.decode(response.body);
      final accessToken = responseData['access_token'];
      if (kDebugMode) {
        print("-- response $responseData");
        print('Token API Hit $accessToken');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
    } else {
      // API call failed, handle error here
      if (kDebugMode) {
        print('Error: ${response.statusCode}');
      }
    }
  }
}
