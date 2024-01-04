import 'package:digihealthcardapp/models/child_model.dart';
import 'package:digihealthcardapp/repositories/immunization_repository.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildVM with ChangeNotifier {
  List<Child> _children = [];
  List<Child> get children => _children;

  final ImmunizationRepository _immunizationRepo = ImmunizationRepository();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    _error = '';
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addChildApi(
      dynamic data, dynamic header, BuildContext context) async {
    setLoading(true);
    DialogBoxes.showLoadingNoTimer();
    if (kDebugMode) {
      print('childData: $data Header:$header');
    }
    _immunizationRepo.addChild(context, data, header).then((value) async {
      setLoading(false);
      DialogBoxes.cancelLoading();
      if (value['status'] == 'success') {
        final msg = value['msg'].toString();
        Utils.snackBarMessage('Successfully $msg!', context);
        Navigator.pop(context, 1122);
      } else if (value['status'] == 'error') {
        final msg = value['msg'];
        final message = (msg != null) ? msg : value['message'].toString();
        Utils.snackBarMessage(message, context);
      }
      if (kDebugMode) {
        print(value.toString());
      }
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      debugPrint('error: $error');
      setLoading(false);
      Utils.snackBarMessage(error.toString(), context);
    });
  }

  Future<dynamic> getChildren(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userTOKEN = prefs.getString('access_token');
    if (!context.mounted) return;
    Map<String, String> header = {'Oauthtoken': 'Bearer $userTOKEN'};
    debugPrint(header.toString());
    setLoading(true);
    await _immunizationRepo.getChildren(context, header).then((value) {
      if (value['status'] == 'success') {
        final childList = value['data'] as List;
        debugPrint('childList: $childList');

        _children = List.generate(
          childList.length,
          (index) => Child(
              id: childList[index]['id'].toString(),
              name: childList[index]['first_name'].toString(),
              lname: childList[index]['last_name'].toString(),
              dob: childList[index]['dob'].toString(),
              gender: childList[index]['gender'].toString(),
              state: childList[index]['state'].toString(),
              country: childList[index]['country'].toString(),
              weight: childList[index]['weight'].toString(),
              height: childList[index]['height'].toString(),
              weightUnit: childList[index]['weight_unit'].toString(),
              heightUnit: childList[index]['height_unit'].toString(),
              image: childList[index]['picture'].toString()),
        );
        setLoading(false);
      } else {
        if (!context.mounted) return;
        final errorDesc = value['error_description'];
        setError(errorDesc);
      }
    }).onError((error, stackTrace) {
      setError(error.toString());
      debugPrint('stackTrace: $stackTrace');
      debugPrint('error: $error');
    });
  }

  Future<dynamic> deleteChild(String childId, BuildContext context) async {
    DialogBoxes.showLoadingNoTimer();
    final prefs = await SharedPreferences.getInstance();
    final String? userTOKEN = prefs.getString('access_token');
    if (!context.mounted) return;
    Map<String, String> header = {'Oauthtoken': 'Bearer $userTOKEN'};
    _immunizationRepo.deleteChild(context, childId, header).then((value) {
      DialogBoxes.cancelLoading();
      if (value['status'] == 'success') {
        debugPrint('message: ${value['message']}');
        final msgDesc = value['message'].toString();

        Utils.snackBarMessage('Successfully $msgDesc!', context);
        Navigator.pop(context, '1122');
      } else {
        if (!context.mounted) return;
        final error = value['error'];
        final errorDesc = value['error_description'];
        Utils.snackBarMessage('$errorDesc', context);
      }
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      debugPrint('stackTrace: $stackTrace');
      debugPrint('error: $error');
      Utils.snackBarMessage(error.toString(), context);
    });
  }
}
