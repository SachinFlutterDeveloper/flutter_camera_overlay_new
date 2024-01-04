import 'package:digihealthcardapp/data/network/base_api_services.dart';
import 'package:digihealthcardapp/data/network/network_api_services.dart';
import 'package:digihealthcardapp/res/app_url.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TestResultRepository {
  final BaseApiService _apiService = NetworkApiServices();

  Future<dynamic> gettestsApi(
    BuildContext context,
    dynamic data,
    dynamic header,
  ) async {
    try {
      if (kDebugMode) {
        print(AppUrl.showTestResults);
      }
      dynamic response = await _apiService.getPostApiResponse(
          context, AppUrl.showTestResults, data, header);
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<dynamic> removeTestApi(
    BuildContext context,
    dynamic data,
    dynamic header,
  ) async {
    try {
      if (kDebugMode) {
        print(AppUrl.removetestresults);
      }
      dynamic response = await _apiService.getPostApiResponse(
          context, AppUrl.removetestresults, data, header);
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<dynamic> getEmailsApi(
    BuildContext context,
    dynamic data,
    dynamic header,
  ) async {
    try {
      if (kDebugMode) {
        print(AppUrl.fetchEmails);
      }
      dynamic response = await _apiService.getPostApiResponse(
          context, AppUrl.fetchEmails, data, header);
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
