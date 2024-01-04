import 'package:digihealthcardapp/viewModel/check_expiry.dart';
import 'package:flutter/material.dart';
import 'package:onepref/onepref.dart';

class AppUrl {
  static String baseUrl = 'https://digihealthcard.com/demo/app/';

  static const URl_STATUS = "URL";

  static Future<void> updateBaseUrl(int number) async {
    debugPrint('number:' + '$number');
    baseUrl = (number == 0)
        ? (OnePref.getString('base_url') != null)
            ? '${OnePref.getString('base_url')}/app/'
            : '${await CheckExpiry().getURl()}/app/'
        : 'https://digihealthcard.com/app/';
  }

  //Post url
  static String get loginUrl => '${baseUrl}patient/login';
  static String get signupUrl => '${baseUrl}patient/patientSignup';
  static String get otpUrl => '${baseUrl}otp_code/verifyOtp';
  static String get otpResend => '${baseUrl}otp_code/otp_request';
  static String get simpleOTPVerify => '${baseUrl}otp_code/simpleVerifyOtp';
  static String get forgotPass => '${baseUrl}patient/forgotPassword';
  static String get saveCard => '${baseUrl}card/saveCard';
  static String get accessToken => '${baseUrl}auth/createToken';
  static String get showCards => '${baseUrl}card/getCards';
  static String get removeCards => '${baseUrl}card/delete';
  static String get removeidCards => '${baseUrl}idcards/delete';
  static String get removetestresults => '${baseUrl}testresults/delete';
  static String get healthCardPrint => '${baseUrl}card/getCard';
  static String get idCardPrint => '${baseUrl}idcards/getCard';
  static String get showTestResults => '${baseUrl}testresults/getResult';
  static String get fetchEmails => '${baseUrl}testresults/fetchemail';
  static String get showidCards => '${baseUrl}idcards/getCards';
  static String get saveidCard => '${baseUrl}idcards/saveCard';
  static String get saveTest => '${baseUrl}testresults/saveResult';
  static String get update => '${baseUrl}updateProfile';
  static String get changePassword => '${baseUrl}changepatientPassword';
  static String get deleteAccount =>
      '${baseUrl}otp_code/delete_account_otp_request';
  static String get delOTPverify =>
      '${baseUrl}otp_code/verifyotp_delete_account';
  static String get labels => '${baseUrl}general/labels';
  static String get profileImg => '${baseUrl}userProfileImg';
  static String get socialLogin => '${baseUrl}patient/social_login';
  static String get appleLogin => '${baseUrl}patient/apple_login';
  static String get subExpiry => '${baseUrl}subscriptions/checkexpiry';
  static String get subPlans => '${baseUrl}patient/getPackages';
  static String get verifySub => '${baseUrl}payments/inapp_pay';
  static String get getInvoices => '${baseUrl}payments/invoices';
  static String get cancelSub => '${baseUrl}subscriptions/cancel_subscription';
  static String get buyWithCode => '${baseUrl}packages/check_package';
  static String get addChild => '${baseUrl}childs/save';
  static String get updateChild => '${baseUrl}childs/update';
  static String get getChildren => '${baseUrl}childs';
  static String get childVaccines => '${baseUrl}child_vaccines';
  static String get applyVaccines => '${baseUrl}child_vaccines/apply_vaccine';
  static String get vaccinesApplied =>
      '${baseUrl}child_vaccines/appliedVaccines/';
  static String get removeChildProfile => '${baseUrl}childs/delete/';
  static String get childProfileImage => '${baseUrl}childs/uploadimage';
  static String get logout => '${baseUrl}logout';
  //Get url
  static String get cardtypes => '${baseUrl}card/card_types';
  static String get idcardtypes => '${baseUrl}idcards/card_types';
}
