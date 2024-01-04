import 'dart:convert';
import 'dart:io';

import 'package:digihealthcardapp/data/network_exceptions.dart';
import 'package:digihealthcardapp/res/app_url.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/auth_view_model.dart';
import 'package:digihealthcardapp/viewModel/child_view_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardViewModel with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void selectIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<dynamic> saveCard(
      BuildContext context,
      Map<String, dynamic> body,
      bool isHealthCard,
      bool isTest,
      bool isVaccine,
      bool isAddChild,
      bool isChildProfile,
      bool isChildUpdate) async {
    DialogBoxes.showLoadingNoTimer();
    final cardVM = Provider.of<CardViewModel>(context, listen: false);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userToken = prefs.getString('access_token');
    if (!context.mounted) return;
    cardVM.setLoading(true);
    try {
      String url;
      if (isHealthCard) {
        url = AppUrl.saveCard;
      } else if (isTest) {
        url = AppUrl.saveTest;
      } else if (isVaccine) {
        url = AppUrl.applyVaccines;
      } else if (isAddChild) {
        url = AppUrl.addChild;
      } else if (isChildProfile) {
        url = AppUrl.childProfileImage;
      } else if (isChildUpdate) {
        url = AppUrl.updateChild;
      } else {
        url = AppUrl.saveidCard;
      }

      debugPrint('url: $url');
      Map<String, String> headers = {"Oauthtoken": "Bearer $userToken"};
      debugPrint('$headers ${body.toString()}');

      Dio dio = Dio();

      FormData formData = FormData.fromMap(body);

      Response response = await dio.post(url,
          data: formData,
          options: Options(
              method: 'POST',
              headers: headers,
              responseType: ResponseType.json));

      var decodedResponse = jsonDecode(response.data);
      debugPrint(response.statusCode.toString() + response.toString());
      if (response.statusCode == 200) {
        DialogBoxes.cancelLoading();
        if (!context.mounted) return;
        String responseBody = response.data.toString();
        if (decodedResponse['status'] == 'success' ||
            decodedResponse['success'] == 1) {
          final msg = decodedResponse['message'];
          cardVM.setLoading(false);
          Utils.snackBarMessage('Successfully $msg', context);
          if (!isChildProfile) {
            Future.delayed(const Duration(seconds: 2), () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.pop(context, '1122');
            });
          } else {
            context.read<ChildVM>().getChildren(context);
          }
          if (kDebugMode) {
            print(decodedResponse.toString() + responseBody.toString());
          }
        } else if (response.statusCode == 401) {
          context.read<AuthViewModel>().logout(context, true);
          Utils.snackBarMessage(
              'Your current current session expired. please login again!',
              context);
        } else {
          final msg = decodedResponse['message'];
          cardVM.setLoading(false);
          Utils.snackBarMessage('Successfully $msg', context);
        }
      }
    } on SocketException catch (e) {
      DialogBoxes.cancelLoading();
      NetworkExceptions exception = NetworkExceptions.fromDioException(e);
      String errorMsg = NetworkExceptions.getErrorMessage(exception);
      cardVM.setLoading(false);
      if (!context.mounted) return;
      Utils.snackBarMessage(errorMsg, context);
      if (kDebugMode) {
        print('Socket: $errorMsg');
      }
    } on DioException catch (e) {
      DialogBoxes.cancelLoading();
      NetworkExceptions exception = NetworkExceptions.fromDioException(e);
      String errorMsg = NetworkExceptions.getErrorMessage(exception);
      cardVM.setLoading(false);
      if (!context.mounted) return;
      Utils.snackBarMessage(errorMsg, context);
      if (kDebugMode) {
        print('dio: $errorMsg ${e.response} ${e.stackTrace}');
      }
    }
  }
}
