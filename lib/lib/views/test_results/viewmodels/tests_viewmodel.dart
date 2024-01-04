import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/views/test_results/repositories/test_result_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowTestVM with ChangeNotifier {
  final TestResultRepository _testResultRepository;

  ShowTestVM(this._testResultRepository);

  List<dynamic> _tests = [];
  List<dynamic> get getTests => _tests;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setTests(List<dynamic> tests) {
    _tests = tests;
    _error = '';
    _isLoading = false;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  Future<dynamic> getTestsApi(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id');
    final String? userToken = prefs.getString('access_token');
    if (!context.mounted) return;
    Map<String, dynamic> body = {
      'patient_id': userId.toString(),
    };
    Map<String, dynamic> header = <String, String>{
      'Oauthtoken': 'Bearer $userToken',
    };
    _tests = [];
    setLoading(true);
    try {
      final value =
          await _testResultRepository.gettestsApi(context, body, header);
      final status = value['status'];
      if (!context.mounted) return;
      DialogBoxes.cancelLoading();
      if (status == 'success') {
        context.read<ShowTestVM>().getEmailsApi(context);
        if (kDebugMode) {
          print("-- response ${value.toString()} ${value['data']}");
        }
        final testsList = value['data'] as List<dynamic>;
        setTests(testsList);
      } else {
        setError(value['message']);
        // API call failed, handle error here
        debugPrint(value.toString());
      }
    } catch (e) {
      setError(e.toString());
      debugPrint(e.toString());
    }
  }

  Future<dynamic> getEmailsApi(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id');
    final String? userToken = prefs.getString('access_token');
    if (!context.mounted) return;
    Map<String, dynamic> body = {
      'patient_id': userId.toString(),
    };
    Map<String, dynamic> header = <String, String>{
      'Oauthtoken': 'Bearer $userToken',
    };
    try {
      final value =
          await _testResultRepository.getEmailsApi(context, body, header);
      final status = value['success'].toString();
      final message = value['message'].toString();
      DialogBoxes.cancelLoading();
      if (!context.mounted) return;
      if (kDebugMode) {
        print("-- response ${value.toString()}");
      }
      if (status == '1') {
        Utils.snackBarMessage(
            'Email has been ${message.toLowerCase()} successfully. '
            'We are loading your test results now.',
            context);
      } else {
        Utils.errorSnackBar(message, context);
      }
    } catch (e) {
      DialogBoxes.cancelLoading();
      if (!context.mounted) return;
      Utils.errorSnackBar(e.toString(), context);
    }
  }

  Future<void> removeTestResult(BuildContext context) async {
    DialogBoxes.showLoadingNoTimer();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id');
    final String? userToken = prefs.getString('access_token');
    final String? testID = prefs.getString('test_id');
    if (!context.mounted) return;
    Map<String, dynamic> body = {
      'id': testID.toString(),
      'patient_id': userId.toString(),
    };
    Map<String, dynamic> header = <String, String>{
      'Oauthtoken': 'Bearer $userToken',
    };
    _testResultRepository.removeTestApi(context, body, header).then((value) {
      final status = value['status'];
      DialogBoxes.cancelLoading();
      final msg = value['message'];
      if (status == 'success') {
        Utils.snackBarMessage('Successfully $msg', context);
        getTestsApi(context);
        if (kDebugMode) {
          print("-- response ${value.toString()} $testID");
        }
      } else {
        // API call failed, handle error here
        Utils.errorSnackBar('$msg', context);
        debugPrint(value.toString());
      }
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      if (!context.mounted) return;
      Utils.errorSnackBar(error.toString(), context);
    });
  }
}
