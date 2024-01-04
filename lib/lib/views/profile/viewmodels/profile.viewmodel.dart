import 'package:digihealthcardapp/repositories/auth_repositories.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileViewModel with ChangeNotifier {
  bool _loading = false;

  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  final _myRepo = AuthRepositories();

  Future<void> updateProfileApi(
      dynamic data, dynamic header, BuildContext context) async {
    DialogBoxes.showLoadingNoTimer();
    _myRepo.updateProfile(context, data, header).then((value) async {
      DialogBoxes.cancelLoading();
      final updateProfileMessage = value['msg'].toString();
      if (value['status'] == 'success') {
        final fname = value['user_info']['first_name'].toString();
        final lname = value['user_info']['last_name'].toString();
        final bdate = value['user_info']['birthdate'].toString();
        final gender = value['user_info']['gender'].toString();
        final phone = value['user_info']['phone'].toString();
        printWrapped('Profile: ${value.toString()}');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('first_name', fname);
        await prefs.setString('last_name', lname);
        await prefs.setString('birthdate', bdate);
        await prefs.setString('gender', gender);
        await prefs.setString('phone', phone);
        if (!context.mounted) return;
        Utils.snackBarMessage(updateProfileMessage, context);
        Future.delayed(const Duration(seconds: 1)).then((value) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          Navigator.pop(context);
        });
      } else {
        Utils.errorSnackBar(updateProfileMessage, context);
      }
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      Utils.errorSnackBar(error.toString(), context);
      debugPrint(error.toString());
    });
  }
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
}
