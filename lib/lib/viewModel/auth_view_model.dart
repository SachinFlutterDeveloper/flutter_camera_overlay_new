import 'dart:convert';
import 'dart:io';

import 'package:digihealthcardapp/models/user_model.dart';
import 'package:digihealthcardapp/repositories/auth_repositories.dart';
import 'package:digihealthcardapp/res/app_url.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/user_view_model.dart';
import 'package:digihealthcardapp/views/auth/otp_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel with ChangeNotifier {
  final _myRepo = AuthRepositories();

  bool _loading = false;

  bool get loading => _loading;

  bool _signUploading = false;

  bool get signUploading => _signUploading;

  bool _otpLoading = false;

  bool get otpLoading => _otpLoading;

  bool _saveCardLoading = false;

  bool get saveCardLoading => _saveCardLoading;

  bool _checkBoxValue = false;

  bool get checkBoxValue => _checkBoxValue;

  bool _checkBoxValueTerms = false;

  bool get checkBoxValueTerms => _checkBoxValueTerms;

  bool _checkBoxValueSub = false;

  bool get checkBoxValueSub => _checkBoxValueSub;

  bool _checkBoxValueSec = false;

  bool get checkBoxValueSec => _checkBoxValueSec;
  bool _changePassword = false;

  bool get changePassword => _changePassword;

  setChangePassLoading(bool value) {
    _changePassword = value;
    notifyListeners();
  }

  setCheckBox(bool val) {
    _checkBoxValue = val;
    notifyListeners();
  }

  setCheckBoxTerms(bool val) {
    _checkBoxValueTerms = val;
    notifyListeners();
  }

  setCheckBoxSub(bool val) {
    _checkBoxValueSub = val;
    notifyListeners();
  }

  setCheckBoxSec(bool val) {
    _checkBoxValueSec = val;
    notifyListeners();
  }

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  setotpLoading(bool value) {
    _otpLoading = value;
    notifyListeners();
  }

  setSignUpLoading(bool value) {
    _checkBoxValue = false;
    _checkBoxValueSub = false;
    _checkBoxValueSec = false;
    _checkBoxValueTerms = false;
    _signUploading = value;
    notifyListeners();
  }

  setSaveCardLoading(bool value) {
    _saveCardLoading = value;
    notifyListeners();
  }

  Future<void> loginApi(
      dynamic data, dynamic header, BuildContext context) async {
    try {
      /* _myRepo.loginApi(data, header).then((userData) async {
        debugPrint('userData: $data $header');
        setLoading(false);
      final status = userData['status'].toString();
        if (status == 'success') {
          final User_view_model userPreference;
          if (context.mounted) {
            userPreference =
                Provider.of<User_view_model>(context, listen: false);
            userPreference.saveUser(
              user(
                id: userData['user']['id'].toString(),
                firstName: userData['user']['first_name'].toString(),
                lastName: userData['user']['last_name'].toString(),
                email: userData['user']['email'].toString(),
                image: userData['user']['image'].toString(),
                phone: userData['user']['phone'].toString(),
                username: userData['user']['username'].toString(),
                relationship: userData['user']['relationship'].toString(),
                birthdate: userData['user']['birthdate'].toString(),
                country: userData['user']['country'].toString(),
                state: userData['user']['state'].toString(),
                city: userData['user']['city'].toString(),
                zipcode: userData['user']['zipcode'].toString(),
                residency: userData['user']['residency'].toString(),
                maritalStatus: userData['user']['marital_status'].toString(),
                gender: userData['user']['gender'].toString(),
              ),
            );
            
            // final msg = 'Welcome, ${data['user']['first_name'].toString()}'
            final prefs = await SharedPreferences.getInstance();
            ' ${userData['user']['last_name'].toString()}';
            if(!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, RoutesName.splash, (route) => false);
            if (userData['user']['id'] != 'null' || data['user']['id'] != '') {
              if (userData['user']['is_approved'] == '0') {
                final user = userData['user'];
                prefs.setBool('isHome', true);
                prefs.setString('patient_id', userData['user']['id']);
                if (!context.mounted) {
                  return;
                }
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => FacebookSignUp(
                              userData: user,
                              isHome: true,
                            )));
              } else if (userData['user']['is_approved'] == '1') {
                prefs.setBool('isHome', false);
                if (!context.mounted) {
                  return;
                }
                Navigator.pushNamedAndRemoveUntil(
                    context, RoutesName.splash, (route) => false);
              }
              final accessToken = userData['user']['access_token'].toString();
              debugPrint('token_____: $accessToken');
              await prefs.setString('access_token', accessToken);
              await tokenAPI();
              // await checkExpiry();
            }
          }
        } else {
          final message = userData['msg'].toString();
          if (message != 'null' || message != '') {
            if (context.mounted) {
              Utils.snackBarMessage(message, context);
            }
          }
          if (kDebugMode) {
            print(userData.toString());
            print(message);
          }
        }
      }).onError((error, stackTrace) {
        setLoading(false);
        Utils.snackBarMessage(error.toString(), context);
      }); */
      debugPrint('login data: ${jsonEncode(data)} ');
      DialogBoxes.showLoadingNoTimer();
      var response = await http.post(Uri.parse(AppUrl.loginUrl),
          body: data, headers: header);
      DialogBoxes.cancelLoading();
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        final status = data['status'].toString();
        debugPrint("response: ${data.toString()}");
        if (status == 'success') {
          final User_view_model userPreference;
          if (!context.mounted) return;
          userPreference = Provider.of<User_view_model>(context, listen: false);
          userPreference.saveUser(
            user(
              id: data['user']['id'].toString(),
              firstName: data['user']['first_name'].toString(),
              lastName: data['user']['last_name'].toString(),
              email: data['user']['email'].toString(),
              image: data['user']['image'].toString(),
              phone: data['user']['phone'].toString(),
              username: data['user']['username'].toString(),
              relationship: data['user']['relationship'].toString(),
              birthdate: data['user']['birthdate'].toString(),
              country: data['user']['country'].toString(),
              state: data['user']['state'].toString(),
              city: data['user']['city'].toString(),
              zipcode: data['user']['zipcode'].toString(),
              residency: data['user']['residency'].toString(),
              maritalStatus: data['user']['marital_status'].toString(),
              gender: data['user']['gender'].toString(),
              isApproved: data['user']['is_approved'].toString(),
            ),
          );
          String msg = '';
          if (data['user']['last_name'] != null) {
            msg =
                'Welcome, ${data['user']['first_name'].toString()} ${data['user']['last_name'].toString()}';
          } else {
            msg = 'Welcome, ${data['user']['first_name'].toString()}';
          }
          Future.delayed(const Duration(milliseconds: 600), () {
            Utils.snackBarMessage(msg, context);
          });
          final prefs = await SharedPreferences.getInstance();
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(
              context, RoutesName.splash, (route) => false);
          if (data['user']['id'] != 'null' || data['user']['id'] != '') {
            if (data['user']['is_approved'] == '0') {
              prefs.setBool('isHome', true);
              final accessToken = data['user']['access_token'].toString();
              Map<String, String> otpHeader = {
                "Oauthtoken": "Bearer $accessToken",
              };
              Map otpData = {
                'first_name': prefs.getString('first_name').toString(),
                'last_name': prefs.getString('last_name').toString(),
                'email': prefs.getString('email').toString(),
                'phone': prefs.getString('phone').toString(),
              };
              await context
                  .read<AuthViewModel>()
                  .socialOTPApi(otpData, otpHeader, context, true);
              debugPrint(
                'otp hit home: ${jsonEncode(otpData)} ${jsonEncode(otpHeader)}',
              );
              if (!context.mounted) return;
            } else if (data['user']['is_approved'] == '1') {
              prefs.setBool('isHome', false);
              Navigator.pushNamedAndRemoveUntil(
                  context, RoutesName.splash, (route) => false);
            }
            final accessToken = data['user']['access_token'].toString();
            debugPrint('token_____$accessToken');
            await prefs.setString('access_token', accessToken);
            if (accessToken == 'null' || accessToken.isEmpty) {
              await tokenAPI();
            }
          }
        } else {
          if (!context.mounted) return;
          final message = data['msg'].toString();
          if (message != 'null' || message != '') {
            Utils.errorSnackBar(message, context);
          }
          debugPrint(data.toString());
          debugPrint(message);
        }
      }
    } on SocketException catch (e) {
      DialogBoxes.cancelLoading();
      if (!context.mounted) return;
      Utils.errorSnackBar('Please check your internet', context);
      debugPrint(e.toString());
    }
  }

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
        print('Token API Hit $accessToken');
        print("-- response $responseData");
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

  Future<void> signupApi(
      dynamic data, dynamic header, BuildContext context) async {
    DialogBoxes.showLoadingNoTimer();
    _myRepo.signupApi(context, data, header).then((value) async {
      DialogBoxes.cancelLoading();
      if (value['status'] == 'success') {
        final msg = value['msg'].toString();
        Utils.snackBarMessage(msg, context);

        Future.delayed(const Duration(seconds: 1), () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Navigator.pushNamed(context, RoutesName.otp);
          setSignUpLoading(false);
        });
      } else {
        Utils.errorSnackBar(value['msg'].toString(), context);
      }
      debugPrint(value.toString());
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      if (kDebugMode) {
        Utils.errorSnackBar(error.toString(), context);
        print(error.toString());
      }
    });
  }

  Future<void> otpApi(
      dynamic data, dynamic header, BuildContext context) async {
    DialogBoxes.showLoadingNoTimer();
    _myRepo.otpApi(context, data, header).then((value) async {
      DialogBoxes.cancelLoading();
      if (value['status'].toString() == 'success') {
        final User_view_model userPreference;
        final msg = value['message'].toString();
        Utils.snackBarMessage(msg, context);
        if (value['user']['is_approved'].toString() == '1') {
          userPreference = Provider.of<User_view_model>(context, listen: false);
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
          final accessToken = value['user']['access_token'].toString();
          debugPrint('token_____$accessToken');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', accessToken);
          if (!context.mounted) return;
          String msg = '';
          if (value['user']['last_name'] != null) {
            msg =
                'Welcome, ${value['user']['first_name'].toString()} ${value['user']['last_name'].toString()}';
          } else {
            msg = 'Welcome, ${value['user']['first_name'].toString()}';
          }
          Utils.snackBarMessage(msg, context);
          if (value['user']['id'] != null || value['user']['id'] != '') {
            if (value['user']['is_approved'].toString() == '0') {
              Navigator.pushReplacementNamed(context, RoutesName.login);
            } else if (value['user']['is_approved'].toString() == '1') {
              prefs.setBool('isHome', false);
              Future.delayed(const Duration(seconds: 1), () {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                Navigator.pushNamedAndRemoveUntil(
                    context, RoutesName.splash, (route) => false);
              });
            }
            debugPrint(value['user'].toString());
            final accessToken = value['user']['access_token'].toString();
            debugPrint('token_____$accessToken');
            await prefs.setString('access_token', accessToken);
          }
        } else {
          Navigator.pushReplacementNamed(context, RoutesName.login);
        }
      } else {
        final message = value['message'].toString();
        if (message.isNotEmpty) {
          await Utils.errorSnackBar(message, context);
        }
      }
      debugPrint(value.toString());
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      Utils.errorSnackBar(error.toString(), context);
      debugPrint(error.toString());
    });
  }

  Future<void> simpleOTPVerify(
      dynamic data, dynamic header, BuildContext context) async {
    DialogBoxes.showLoadingNoTimer();
    _myRepo.simpleOTPVerify(context, data, header).then((value) {
      DialogBoxes.cancelLoading();
      final msg = value['message'].toString();
      if (value['status'] == 'success') {
        Utils.snackBarMessage(msg, context);
        Future.delayed(const Duration(seconds: 1)).then((value) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Navigator.pushReplacementNamed(context, RoutesName.splash);
        });
      } else {
        Utils.snackBarMessage(msg, context);
      }
      debugPrint(value.toString());
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      Utils.errorSnackBar(error.toString(), context);
      debugPrint(error.toString());
    });
  }

  Future<void> otpResendApi(
      dynamic data, dynamic header, BuildContext context) async {
    DialogBoxes.showLoadingNoTimer();
    _myRepo.otpResendApi(context, data, header).then((value) {
      DialogBoxes.cancelLoading();
      final msg = value['message'].toString();
      if (value['status'] == 'success') {
        Utils.snackBarMessage(msg, context);
      } else {
        Utils.errorSnackBar(msg, context);
      }
      debugPrint(value.toString());
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      Utils.errorSnackBar(error.toString(), context);
      debugPrint(error.toString());
    });
  }

  Future<void> forgotPassApi(
      dynamic data, dynamic header, BuildContext context) async {
    DialogBoxes.showLoadingNoTimer();
    _myRepo.forgotPass(context, data, header).then((value) {
      DialogBoxes.cancelLoading();
      if (value['status'] == 'success') {
        final msg = value['msg'].toString();
        final message = value['message'].toString();
        (msg.isNotEmpty)
            ? Utils.snackBarMessage(msg, context)
            : Utils.snackBarMessage(message, context);
        Future.delayed(const Duration(seconds: 1)).then((value) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Navigator.pushNamedAndRemoveUntil(
              context, RoutesName.login, (route) => false);
        });
      } else {
        final msg = value['msg'].toString();
        final message = value['message'].toString();
        (msg.isNotEmpty)
            ? Utils.errorSnackBar(msg, context)
            : Utils.errorSnackBar(message, context);
      }
      if (kDebugMode) {
        print(value.toString());
      }
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      if (kDebugMode) {
        Utils.errorSnackBar(error.toString(), context);
        print(error.toString());
      }
    });
  }

  Future<void> socialOTPApi(
      dynamic data, dynamic header, BuildContext context, bool isHome) async {
    DialogBoxes.showLoadingNoTimer();
    _myRepo.otpResendApi(context, data, header).then((value) {
      DialogBoxes.cancelLoading();
      final msg = value['message'].toString();
      if (value['status'] == 'success') {
        Utils.snackBarMessage(msg, context);
        Future.delayed(const Duration(milliseconds: 800), () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          if (isHome) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OTPScreen(isHome: true),
              ),
            );
          } else {
            Navigator.pushNamed(context, RoutesName.otp);
          }
        });
      } else {
        Utils.errorSnackBar(msg, context);
      }
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      if (kDebugMode) {
        Utils.errorSnackBar(error.toString(), context);
        print(error.toString());
      }
    });
  }

  Future<dynamic> logout(BuildContext context, bool isExpired) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    DialogBoxes.showLoadingNoTimer();
    final id = sp.getString('id').toString();
    dynamic data = {
      'id': id,
      'type': 'patient',
    };
    debugPrint('${AppUrl.logout} $data ');
    if (!context.mounted) return;
    _myRepo.logout(context, data).then((value) {
      DialogBoxes.cancelLoading();
      if (value['status'] == 'success') {
        context.read<User_view_model>().remove();
        Future.delayed(const Duration(milliseconds: 300), () {
          debugPrint(value.toString());

          if (!isExpired) {
            final msg = value['msg'].toString();
            Utils.snackBarMessage(msg, context);
          } else {
            Utils.snackBarMessage(
                'Your session has been expired please login again', context);
          }
        });
        Navigator.pushReplacementNamed(context, RoutesName.login);
      } else {
        final msg = value['msg'].toString();
        debugPrint('${AppUrl.logout} $msg $data');
        Utils.errorSnackBar(msg, context);
      }
      return value;
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      if (kDebugMode) {
        print(error.toString());
        Utils.errorSnackBar(error.toString(), context);
      }
    });
  }
}
