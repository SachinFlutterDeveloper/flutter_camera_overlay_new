import 'package:digihealthcardapp/models/subscription_package.dart';
import 'package:digihealthcardapp/repositories/subscription_repository.dart';
import 'package:digihealthcardapp/res/components/dialog_boxes.dart';
import 'package:digihealthcardapp/utils/utils.dart';
import 'package:digihealthcardapp/viewModel/check_expiry.dart';
import 'package:digihealthcardapp/views/subscription/models/invoice_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionViewModel with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PackageObject> _selfPlans = [];
  List<PackageObject> get getSelfPlans => _selfPlans;

  List<PackageObject> _familyPlans = [];
  List<PackageObject> get getFamilyPlans => _familyPlans;

  List<Invoice> _invoices = [];
  List<Invoice> get invoices => _invoices;

  void setInvoices(List<Invoice> addInvoices) {
    _isLoading = false;
    _invoices = addInvoices;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setPlans(
      List<PackageObject> selfPlans, List<PackageObject> familyPlans) {
    _familyPlans = familyPlans;
    _selfPlans = selfPlans;
    _isLoading = false;
    notifyListeners();
  }

  String _error = '';
  String get error => _error;

  void setError(String error) {
    _isLoading = false;
    _error = error;
    notifyListeners();
  }

  final subscriptionRepo = SubscriptionRepository();

  Future<void> fetchPlans(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id');
    final String? userToken = prefs.getString('access_token');
    setLoading(true);
    try {
      if (!context.mounted) return;
      Map<String, String> data = {
        "patient_id": userId.toString(),
      };
      Map<String, String> header = {
        'Oauthtoken': 'Bearer $userToken',
      };
      if (_selfPlans.isEmpty) {
        final response =
            await subscriptionRepo.fetchPlans(context, data, header);

        // API call was successful, handle response data here
        final status = response['status'];
        List<PackageObject>? parseSelfPlans =
            SubscriptionPackage.fromJson(response).data;
        parseSelfPlans?.add(PackageObject(
            id: '',
            packageName: 'Subscription Code',
            durationMonth: '',
            amount: '  -',
            isDeleted: '',
            pkgType: 'Code',
            pkgMode: 'Self',
            appstorePkgId: '',
            androidPkgId: ''));

        List<PackageObject>? parseFamilyPlans =
            SubscriptionPackage.fromJson(response).familyPackages;

        parseFamilyPlans?.add(PackageObject(
            id: '',
            packageName: 'Subscription Code',
            durationMonth: '',
            amount: '  -',
            isDeleted: '',
            pkgType: 'Code',
            pkgMode: 'Family',
            appstorePkgId: '',
            androidPkgId: ''));

        setPlans(parseSelfPlans!, parseFamilyPlans!);

        if (kDebugMode) {
          print('Token API Hit $status $parseSelfPlans ');
        }
      }
    } catch (e) {
      setError(e.toString());
      throw e.toString();
    }
  }

  Future<void> fetchInvoices(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id');
    final String? userToken = prefs.getString('access_token');
    setLoading(true);
    try {
      if (!context.mounted) return;
      Map<String, String> data = {
        "patient_id": userId.toString(),
      };
      Map<String, String> header = {
        'Oauthtoken': 'Bearer $userToken',
      };
      final response =
          await subscriptionRepo.fetchInvoices(context, data, header);

      // API call was successful, handle response data here
      final status = response['status'];
      List<Invoice>? parseInvoices = InvoiceListModel.fromJson(response).data;
      setInvoices(parseInvoices!);

      if (kDebugMode) {
        print('Invoices API Hit $status $parseInvoices ');
      }
    } catch (e) {
      setError(e.toString());
      throw e.toString();
    }
  }

  Future<dynamic> verifySubscription(
      BuildContext context, dynamic header, dynamic data, String name) async {
    DialogBoxes.showLoadingNoTimer();
    final prefs = await SharedPreferences.getInstance();
    CheckExpiry check = CheckExpiry();
    final String? userTOKEN = prefs.getString('access_token');
    Map<String, String> header = {'Oauthtoken': 'Bearer $userTOKEN'};
    if (!context.mounted) return;
    subscriptionRepo.verifySubscription(context, data, header).then((value) {
      DialogBoxes.cancelLoading();
      if (!context.mounted) return;
      if (value['status'] == 'success') {
        check.checkExpiry(context, false);
        final msg = value['message'].toString();
        Utils.snackBarMessage(msg, context);
        DialogBoxes.subSuccessDialog(context, name, null);
      } else {
        if (!context.mounted) return;
        final errorDesc = value['error_description'];
        debugPrint('errorDesc: $errorDesc');
        Utils.snackBarMessage('$errorDesc', context);
      }
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      debugPrint('error: $error $stackTrace');
      Utils.snackBarMessage('$error', context);
    });
  }

  Future<dynamic> cancelSubscription(
    BuildContext context,
  ) async {
    DialogBoxes.showLoadingNoTimer();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('id');
    CheckExpiry check = CheckExpiry();
    final String? userToken = prefs.getString('access_token');

    Map<String, String> header = {'Oauthtoken': 'Bearer $userToken'};
    Map<String, String> data = {
      "patient_id": userId.toString(),
    };
    if (!context.mounted) return;
    subscriptionRepo.cancelSubscription(context, data, header).then((value) {
      DialogBoxes.cancelLoading();
      debugPrint(value.toString());
      if (value['status'] == 'success') {
        final msg = value['message'].toString();
        DialogBoxes.subCancelDialog(context, msg.toString());
        Utils.snackBarMessage(msg, context);
        check.checkExpiry(context, false);
      } else {
        final errorDesc = value['error_description'];
        debugPrint('errorDesc: $errorDesc');
        Utils.snackBarMessage('$errorDesc', context);
      }
    }).onError((error, stackTrace) {
      DialogBoxes.cancelLoading();
      debugPrint('error: $error');
      Utils.snackBarMessage('$error', context);
    });
  }
}
