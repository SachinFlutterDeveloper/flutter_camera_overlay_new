import 'dart:convert';
import 'dart:io';

import 'package:digihealthcardapp/data/app_exceptions.dart';
import 'package:digihealthcardapp/viewModel/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import 'base_api_services.dart';

class NetworkApiServices extends BaseApiService {
  @override
  Future getGetApiResponse(
      BuildContext context, String url, dynamic header) async {
    dynamic responseJson;
    try {
      final response = await http
          .get(Uri.parse(url), headers: header)
          .timeout(const Duration(seconds: 10));
      printWrapped(
          'response: ${jsonDecode(response.body)} ${response.statusCode.toString()}');
      if (response.statusCode == 401) {
        if (!context.mounted) return;
        context.read<AuthViewModel>().logout(context, true);
      }
      responseJson = returnResponse(response);
    } on SocketException {
      if (!context.mounted) return;
      throw NoInternetException('No Internet Connection');
    } on FormatException {
      throw InternalServerException('Internal server Error',
          'Database format error occurred while fetching data from server');
    }
    return responseJson;
  }

  @override
  Future getPostApiResponse(
      BuildContext context, String url, dynamic data, dynamic header) async {
    dynamic responseJson;
    try {
      Response response;

      if (header != null) {
        response = await http
            .post(
              Uri.parse(url),
              body: data,
              headers: header,
            )
            .timeout(const Duration(seconds: 15));
        printWrapped(
            'response: ${jsonDecode(response.body)} ${response.statusCode.toString()}');
      } else {
        response = await http
            .post(
              Uri.parse(url),
              body: data,
            )
            .timeout(const Duration(seconds: 15));
        printWrapped(
            'response: ${jsonDecode(response.body)} ${response.statusCode.toString()}');
      }
      if (response.statusCode == 401) {
        if (!context.mounted) return;
        context.read<AuthViewModel>().logout(context, true);
      }
      responseJson = returnResponse(response);
      debugPrint(response.statusCode.toString());
    } on SocketException {
      throw NoInternetException('No Internet Connection');
    } on FormatException {
      throw InternalServerException('Internal server Error',
          'Database format error occurred while fetching data from server');
    }
    return responseJson;
  }
}

dynamic returnResponse(http.Response response) {
  dynamic responseJson = jsonDecode(response.body);
  switch (response.statusCode) {
    case 200 || 201:
      dynamic responseJson = jsonDecode(response.body);
      return responseJson;
    case 400:
      throw BadRequestException(
          'Invalid Request', responseJson['message'].toString());
    case 401:
      throw UnauthorisedException(
          'Unauthorized Request', responseJson['message']);
    case 500 || 501 || 503:
      throw InternalServerException('Internal server Error',
          'Database format error occurred while fetching data from server');
    case 404:
      throw NotFoundException(response.body.toString());
    default:
      throw FetchDataException(
          'Error occured while communicating with the server \n with status code${response.statusCode}');
  }
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
}
