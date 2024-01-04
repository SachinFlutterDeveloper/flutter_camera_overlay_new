import 'package:digihealthcardapp/data/network/base_api_services.dart';
import 'package:digihealthcardapp/data/network/network_api_services.dart';
import 'package:digihealthcardapp/res/app_url.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ImmunizationRepository {
  final BaseApiService _apiService = NetworkApiServices();

  Future<dynamic> addChild(BuildContext context,dynamic data, dynamic header) async {
    try {
      dynamic response =
          _apiService.getPostApiResponse(context,AppUrl.addChild, data, header);
      if (kDebugMode) {
        print('url: ${AppUrl.addChild} response: $response');
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getChildren(BuildContext context,dynamic header) async {
    try {
      dynamic response =
          _apiService.getGetApiResponse(context,AppUrl.getChildren, header);
      if (kDebugMode) {
        print('url: ${AppUrl.getChildren} response: $response');
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> childVaccines(BuildContext context,dynamic header) async {
    try {
      dynamic response =
          _apiService.getGetApiResponse(context,AppUrl.childVaccines, header);
      if (kDebugMode) {
        print('url: ${AppUrl.childVaccines} response: $response');
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> applyVaccines(BuildContext context,dynamic data, dynamic header) async {
    try {
      dynamic response =
          _apiService.getPostApiResponse(context,AppUrl.applyVaccines, data, header);
      if (kDebugMode) {
        print('url: ${AppUrl.applyVaccines} response: $response');
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> appliedVaccines(BuildContext context,String childId, dynamic header) async {
    try {
      dynamic response =
          _apiService.getGetApiResponse(context,'${AppUrl.vaccinesApplied}$childId', header);
      if (kDebugMode) {
        print('url: ${AppUrl.vaccinesApplied} response: $response');
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteChild(BuildContext context,String childId, dynamic header) async {
    try {
      dynamic response =
          _apiService.getGetApiResponse(context,'${AppUrl.removeChildProfile}$childId', header);
      if (kDebugMode) {
        print('url: ${AppUrl.removeChildProfile} response: $response');
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
