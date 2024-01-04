import 'package:digihealthcardapp/data/network/base_api_services.dart';
import 'package:digihealthcardapp/data/network/network_api_services.dart';
import 'package:digihealthcardapp/res/app_url.dart';
import 'package:flutter/cupertino.dart';

class CheckCredentialsRepository {
  final BaseApiService _apiService = NetworkApiServices();

  Future<dynamic> saveToken(
      BuildContext context, dynamic data, dynamic header) async {
    try {
      debugPrint('${AppUrl.baseUrl}saveToken');
      dynamic response = await _apiService.getPostApiResponse(
          context, '${AppUrl.baseUrl}saveToken', data, header);
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<dynamic> checkExpiry(
      BuildContext context, dynamic data, dynamic header) async {
    try {
      debugPrint('${AppUrl.subExpiry} expiration');
      dynamic response = await _apiService.getPostApiResponse(
          context, AppUrl.subExpiry, data, header);
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<dynamic> getBaseUrl(
    BuildContext context,
  ) async {
    try {
      String url = 'https://digihealthcard.com/url987.json';
      debugPrint('$url getBaseUrl');
      dynamic response =
          await _apiService.getGetApiResponse(context, url, null);
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
