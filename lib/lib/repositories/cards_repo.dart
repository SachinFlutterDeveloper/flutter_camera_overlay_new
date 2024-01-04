import 'package:digihealthcardapp/data/network/base_api_services.dart';
import 'package:digihealthcardapp/data/network/network_api_services.dart';
import 'package:digihealthcardapp/res/app_url.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CardsRepo {
  final BaseApiService _apiService = NetworkApiServices();

  Future<dynamic> removeCardsApi(
      BuildContext context, dynamic data, dynamic header, bool isHealth) async {
    String url = '';
    if (isHealth) {
      url = AppUrl.removeCards;
    } else {
      url = AppUrl.removeidCards;
    }
    try {
      if (kDebugMode) {
        print(url);
      }
      dynamic response =
          await _apiService.getPostApiResponse(context, url, data, header);
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<dynamic> getCardsApi(
      BuildContext context, dynamic data, dynamic header, bool isHealth) async {
    String url = '';
    if (isHealth) {
      url = AppUrl.showCards;
    } else {
      url = AppUrl.showidCards;
    }
    try {
      if (kDebugMode) {
        print(url);
      }
      dynamic response =
          await _apiService.getPostApiResponse(context, url, data, header);
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
