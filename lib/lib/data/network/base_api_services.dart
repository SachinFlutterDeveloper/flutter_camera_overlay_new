import 'package:flutter/cupertino.dart';

abstract class BaseApiService {
  Future<dynamic> getGetApiResponse(BuildContext context,String url, dynamic header);
  Future<dynamic> getPostApiResponse(BuildContext context,String url, dynamic data, dynamic header);
}
