import 'package:digihealthcardapp/data/network/base_api_services.dart';
import 'package:digihealthcardapp/data/network/network_api_services.dart';
import 'package:digihealthcardapp/res/app_url.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class SubscriptionRepository {
  final BaseApiService _apiService = NetworkApiServices();

  Future<dynamic> fetchPlans(
      BuildContext context, dynamic data, dynamic header) async {
    try {
      debugPrint('Fetch Subscription: $data $header');
      dynamic response = _apiService.getPostApiResponse(
          context, AppUrl.subPlans, data, header);
      if (kDebugMode) {
        print('url: ${AppUrl.subPlans} response: $response');
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> fetchInvoices(
      BuildContext context, dynamic data, dynamic header) async {
    try {
      debugPrint('Fetch invoices: $data $header');
      dynamic response = _apiService.getPostApiResponse(
          context, AppUrl.getInvoices, data, header);
      if (kDebugMode) {
        print('url: ${AppUrl.getInvoices} response: $response');
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> verifySubscription(
      BuildContext context, dynamic data, dynamic header) async {
    try {
      debugPrint('Verify Subscription: $data $header');
      dynamic response = _apiService.getPostApiResponse(
          context, AppUrl.verifySub, data, header);
      if (kDebugMode) {
        print('url: ${AppUrl.verifySub} response: $response');
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> cancelSubscription(
      BuildContext context, dynamic data, dynamic header) async {
    try {
      debugPrint('Cancel Subscription: $data $header');
      dynamic response = _apiService.getPostApiResponse(
          context, AppUrl.cancelSub, data, header);
      if (kDebugMode) {
        print('url: ${AppUrl.cancelSub} response: ${response.toString()}');
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
