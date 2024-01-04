import 'package:digihealthcardapp/repositories/auth_repositories.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onepref/onepref.dart';
import 'package:provider/provider.dart';

import '../../../utils/routes/routes_name.dart';
import '../../../viewModel/user_view_model.dart';

class ChangePasswordVM with ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  String _status = '';
  String get status => _status;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  final _myRepo = AuthRepositories();

  Future<void> changePasswordApi(
      dynamic data, dynamic header, BuildContext context) async {
    DialogBoxes.showLoadingNoTimer();
    _myRepo.changePassword(context, data, header).then((value) {
      DialogBoxes.cancelLoading();
      final st = value['error'].toString();
      _status = st;
      final msg = value['msg'].toString();
      final message = value['message'].toString();
      debugPrint(value.toString());

      if (value['success'].toString() == '1') {
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 600)).then((value) {
          (msg != 'null')
              ? Utils.showSnackBar(message)
              : Utils.showSnackBar(message);
        });
      }
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      Utils.errorSnackBar(error.toString(), context);
      debugPrint(error.toString());
    });
  }

  Future<void> delOTPApi(
      dynamic data, dynamic header, BuildContext context) async {
    DialogBoxes.showLoadingNoTimer();
    _myRepo.verifyDeleteOTP(context, data, header).then((value) {
      DialogBoxes.cancelLoading();
      final message = value['message'].toString();
      final msg = value['msg'].toString();
      if (value['status'] == 'success') {
        Navigator.pushReplacementNamed(context, RoutesName.login);
        final userPref = Provider.of<User_view_model>(context, listen: false);
        userPref.remove();
        (msg != 'null')
            ? Utils.snackBarMessage(msg, context)
            : Utils.snackBarMessage(message, context);
        debugPrint(value.toString());
      } else {
        (msg != 'null')
            ? Utils.snackBarMessage(msg, context)
            : Utils.snackBarMessage(message, context);
      }
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      Utils.errorSnackBar(error.toString(), context);
      debugPrint(error.toString());
    });
  }

  String? _statusCode;
  String? get statusCode => _statusCode;

  void setStatus(String status) {
    _statusCode = status;
    notifyListeners();
  }

  Future<void> deleteAccount(dynamic data, dynamic header, BuildContext context,
      String subString) async {
    DialogBoxes.showLoadingNoTimer();
    _myRepo.deleteOTPReq(context, data, header).then((value) {
      DialogBoxes.cancelLoading();
      final message = value['message'].toString();
      final msg = value['msg'].toString();
      if (value['status'] == 'success') {
        (msg != 'null')
            ? Utils.snackBarMessage(msg, context)
            : Utils.snackBarMessage(message, context);
        final key = value['verify_key'].toString();
        final status = value['code'].toString();
        setStatus(status);
        OnePref.setString('verify_key', key);
        if (OnePref.getString('billing').toString() == 'subscription') {
          Future.delayed(const Duration(milliseconds: 500), () {
            DialogBoxes.showCheckSubscription(context, subString);
          });
        }
        debugPrint(value.toString());
      } else {
        (msg != 'null')
            ? Utils.snackBarMessage(msg, context)
            : Utils.snackBarMessage(message, context);
      }
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      Utils.errorSnackBar(error.toString(), context);
      debugPrint('OTC Error: ${error.toString()}');
    });
  }
}
