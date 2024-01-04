import 'dart:convert';

import 'package:digihealthcardapp/data/app_exceptions.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:digihealthcardapp/viewModel/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import 'widgets/custom_snack_bar.dart';
import 'widgets/snack_bar_content.dart';

class Utils {
  static dynamic returnResponse(BuildContext context, Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
        context.read<AuthViewModel>().logout(context, true);
        Utils.snackBarMessage(
            'Your current token is expired or invalid. please login again.',
            context);
        throw UnauthorisedException(response.body.toString());
      case 500:
        throw InternalServerException(response.body.toString());
      default:
        throw FetchDataException(
            'Error occured while communicating with the server \n with status code${response.statusCode}');
    }
  }

  static void fieldFocusChange(
      BuildContext context, FocusNode current, FocusNode nextFocus) {
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      fontSize: 14,
      gravity: ToastGravity.CENTER_LEFT,
      timeInSecForIosWeb: 3,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  static snackBarMessage(String message, BuildContext context) {
    AppKeys.rootScaffoldMessengerKey.currentState?.removeCurrentSnackBar();
    AppKeys.rootScaffoldMessengerKey.currentState?.showSnackBar(CustomSnackBar(
        content: SnackBarContent(message: message, color: AppColors.primary)));
  }

  static errorSnackBar(String message, BuildContext context) {
    AppKeys.rootScaffoldMessengerKey.currentState?.removeCurrentSnackBar();
    AppKeys.rootScaffoldMessengerKey.currentState?.showSnackBar(CustomSnackBar(
        content: SnackBarContent(message: message, color: Colors.deepOrange)));
  }

  static showSnackBar(String message) {
    AppKeys.rootScaffoldMessengerKey.currentState?.removeCurrentSnackBar();
    AppKeys.rootScaffoldMessengerKey.currentState?.showSnackBar(CustomSnackBar(
        marginBottom: 80,
        content: SnackBarContent(message: message, color: AppColors.primary)));
  }
}
