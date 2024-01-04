import 'dart:convert';
import 'dart:io';

import 'package:digihealthcardapp/models/pkg_expiration_data.dart';
import 'package:digihealthcardapp/repositories/check_creds_repo.dart';
import 'package:digihealthcardapp/res/app_url.dart';
import 'package:digihealthcardapp/utils/routes/routes_name.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:onepref/onepref.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart' '';

import '../res/components/dialog_boxes.dart';

class CheckExpiry with ChangeNotifier {
  final _checkCredentials = CheckCredentialsRepository();

  Future<void> checkExpiry(BuildContext context, bool isFromCanceled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id');
    final String? userToken = prefs.getString('access_token');
    try {
      final data = {
        "patient_id": userId.toString(),
      };
      final header = <String, String>{
        'Oauthtoken': 'Bearer $userToken',
      };
      debugPrint('Check Expiry: ${AppUrl.subExpiry} $data $header');
      var response = await http.post(Uri.parse(AppUrl.subExpiry),
          headers: header, body: data);

      if (response.statusCode == 200) {
        // API call was successful, handle response data here
        var responseData = json.decode(response.body);
        final pkgExpData = ExpData.fromJson(responseData);
        if (!context.mounted) return;
        if (isFromCanceled && pkgExpData.status == 'error') {
          Utils.snackBarMessage(
              'Your subscription has been cancelled', context);
          Future.delayed(const Duration(milliseconds: 600), () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            Navigator.pushReplacementNamed(context, RoutesName.home);
          });
        }
        debugPrint('response: ${pkgExpData.status} ${responseData.toString()}');
        await prefs.setString('trial_status', pkgExpData.status.toString());
        await prefs.setString('billing', pkgExpData.billing.toString());
        if (pkgExpData.data != null) {
          await prefs.setString(
              'start_date', pkgExpData.data!.dateof.toString());
          await prefs.setString('end_date', pkgExpData.data!.expiry.toString());
          await prefs.setString(
              'sub_mode', pkgExpData.data!.pkgMode.toString());
          await prefs.setString(
              'sub_amount', pkgExpData.data!.amount.toString());
          await prefs.setString(
              'sub_name', pkgExpData.data!.packageName.toString());
          await prefs.setString(
              'sub_type', pkgExpData.data!.pkgType.toString());
          await prefs.setString(
              'sub_id', pkgExpData.data!.subscriptionId.toString());
          await prefs.setString(
              'pkg_status', pkgExpData.data!.status.toString());
        } else {
          await prefs.setString('start_date', '');
          await prefs.setString('end_date', '');
          await prefs.setString('sub_mode', '');
          await prefs.setString('sub_amount', '');
          await prefs.setString('sub_name', '');
          await prefs.setString('sub_type', '');
          await prefs.setString('sub_id', '');
          await prefs.setString('pkg_status', '');
        }
        await prefs.setString('sub_message', pkgExpData.message.toString());
        if (kDebugMode) {
          print(
              '--Expiry response: ${pkgExpData.status.toString()} ${pkgExpData.message.toString()} ${pkgExpData.data?.dateof.toString()}');
        }
      } else {
        debugPrint('check Expiry: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Error: ${e.toString()}');
    }
  }

  Future<void> checkVersion(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final pkgInfo = await PackageInfo.fromPlatform();
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    final currentVersion = pkgInfo.version;
    final String? userId = prefs.getString('id');
    final String? deviceToken = token;
    final platform = Platform.isIOS ? 'iphone' : 'android';

    final headers = <String, String>{
      'Oauthtoken': 'Bearer ${prefs.getString('access_token')}',
    };

    final body = {
      'patient_id': userId.toString(),
      'timezone': Intl.systemLocale.toString(),
      'platform': platform,
      'device_token': deviceToken,
      'app_version': currentVersion.toString()
    };
    debugPrint('$body $headers');
    if (!context.mounted) return;
    _checkCredentials.saveToken(context, body, headers).then((value) {
      debugPrint(value.toString());
      if (value['success'].toString() == '1') {
        debugPrint(value.toString());
        compareVersion(context, value);
      }
    }).onError((error, stackTrace) {
      debugPrint(error.toString());
      throw error.toString();
    });
  }

  compareVersion(BuildContext context, dynamic value) async {
    final pkgInfo = await PackageInfo.fromPlatform();
    final appVersion = value['app_version'].toString();
    final currentVersion = pkgInfo.version.toString();

    String postMsg = Platform.isIOS
        ? " is available on the appstore. Please keep your app up to date in order to get latest features and better performance."
        : " is available on the google play. Please keep your app up to date in order to get latest features and better performance.";

    debugPrint('version: $appVersion $currentVersion');
    OnePref.setString('app_version', appVersion);
    if (!context.mounted) return;

    final result = compareVersions(currentVersion, appVersion);
    if (result < 0) {
      DialogBoxes.showUpdateDialog(
          context, 'New version ', appVersion, postMsg, value['app_link']);
    } else if (result > 0) {
      debugPrint(
          'Current Version is $currentVersion greater than appstore version $appVersion');
    } else {
      debugPrint('Your app is upto date with playstore/appstore');
    }
  }

  Future<String> getURl() async {
    String url = 'https://digihealthcard.com/url987.json';
    try {
      var response = await http.post(Uri.parse(url));
      var baseURL = '';
      if (response.statusCode == 200) {
        final value = jsonDecode(response.body);
        baseURL = value['url'];
        debugPrint('Base Url: ${value['url'].toString()}');
        OnePref.setString('base_url', value['url'].toString());
      }
      return baseURL;
    } catch (error) {
      debugPrint('Error: ${error.toString()}');
    }
    return '';
    // _checkCredentials.getBaseUrl(context).then((value) {
    //   debugPrint(value.toString());
    //   if (value['url'] != null || value['url'].toString().isNotEmpty) {
    //     debugPrint('Base Url: ${value['url'].toString()}');
    //     OnePref.setString('base_url', value['url'].toString());
    //   }
    // }).onError((error, stackTrace) {
    //   debugPrint('Error: ${error.toString()}');
    // });
  }
}

int compareVersions(String currentVersion, String latestVersion) {
  List<int> vCurrentSegments =
      currentVersion.split('.').map(int.parse).toList();
  List<int> vLatestSegments = latestVersion.split('.').map(int.parse).toList();

  for (int i = 0; i < vCurrentSegments.length; i++) {
    debugPrint('version current $vCurrentSegments latest $vLatestSegments');
    if (vCurrentSegments[i] < vLatestSegments[i]) {
      return -1;
    } else if (vCurrentSegments[i] > vLatestSegments[i]) {
      return 1;
    }
  }

  return 0; // Both versions are equal
}
