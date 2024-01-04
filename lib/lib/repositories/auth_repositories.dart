import 'package:digihealthcardapp/data/network/base_api_services.dart';
import 'package:digihealthcardapp/data/network/network_api_services.dart';
import 'package:digihealthcardapp/res/app_url.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class AuthRepositories {
  final BaseApiService _apiService = NetworkApiServices();

  Future<dynamic> loginApi(BuildContext context,dynamic data, dynamic header) async {
    try {
      if (kDebugMode) {
        print(AppUrl.loginUrl);
      }
      dynamic response =
          await _apiService.getPostApiResponse(context,AppUrl.loginUrl, data, header);
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<dynamic> signupApi(BuildContext context,dynamic data, dynamic header) async {
    if (kDebugMode) {
      print(AppUrl.signupUrl);
    }
    try {
      dynamic response =
          await _apiService.getPostApiResponse(context,AppUrl.signupUrl, data, header);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> otpApi(BuildContext context,dynamic data, dynamic header) async {
    if (kDebugMode) {
      print(AppUrl.otpUrl);
    }
    try {
      dynamic response =
          await _apiService.getPostApiResponse(context,AppUrl.otpUrl, data, header);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> simpleOTPVerify(BuildContext context,dynamic data, dynamic header) async {
    if (kDebugMode) {
      print(AppUrl.simpleOTPVerify);
    }
    try {
      dynamic response = await _apiService.getPostApiResponse(context,
          AppUrl.simpleOTPVerify, data, header);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> otpResendApi(BuildContext context,dynamic data, dynamic header) async {
    if (kDebugMode) {
      print(AppUrl.otpResend);
    }
    try {
      dynamic response =
          await _apiService.getPostApiResponse(context,AppUrl.otpResend, data, header);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> forgotPass(BuildContext context,dynamic data, dynamic header) async {
    if (kDebugMode) {
      print(AppUrl.forgotPass);
    }
    try {
      dynamic response =
          await _apiService.getPostApiResponse(context,AppUrl.forgotPass, data, header);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateProfile(BuildContext context,dynamic data, dynamic header) async {
    try {
      if (kDebugMode) {
        print(AppUrl.update);
      }
      dynamic response =
          await _apiService.getPostApiResponse(context,AppUrl.update, data, header);
      if (kDebugMode) {
        print('APP URL: ${AppUrl.update}');
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> changePassword(BuildContext context,dynamic data, dynamic header) async {
    try {
      if (kDebugMode) {
        print(AppUrl.changePassword);
      }
      dynamic response = await _apiService.getPostApiResponse(context,
          AppUrl.changePassword, data, header);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteOTPReq(BuildContext context,dynamic data, dynamic header) async {
    try {
      if (kDebugMode) {
        print(AppUrl.deleteAccount);
      }
      dynamic response = await _apiService.getPostApiResponse(context,
          AppUrl.deleteAccount, data, header);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> verifyDeleteOTP(BuildContext context,dynamic data, dynamic header) async {
    try {
      if (kDebugMode) {
        print(AppUrl.delOTPverify);
      }
      dynamic response = await _apiService.getPostApiResponse(context,
          AppUrl.delOTPverify, data, header);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> socialLogin(BuildContext context,dynamic data, dynamic header) async {
    try {
      if (kDebugMode) {
        print(AppUrl.socialLogin);
      }
      dynamic response = await _apiService.getPostApiResponse(context,
          AppUrl.socialLogin, data, header);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> appleLogin(BuildContext context,dynamic data, dynamic header) async {
    try {
      if (kDebugMode) {
        print(AppUrl.appleLogin);
      }
      dynamic response = await _apiService.getPostApiResponse(context,
          AppUrl.appleLogin, data, header);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> logout(BuildContext context, dynamic data) async {
    try {
      debugPrint(AppUrl.logout);
      dynamic response = await _apiService.getPostApiResponse(
          context, AppUrl.logout, data, null);
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

}
