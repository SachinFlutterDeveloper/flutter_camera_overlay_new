import 'dart:convert';
import 'dart:io';

import 'package:digihealthcardapp/env/env.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ChatAIRepository {
  static var client = http.Client();
  static const endpoint = "https://api.openai.com/v1/chat/";
  static const aiToken = Env.apiKey;

  static Future<Map<String, dynamic>> chatAI({required prompt}) async {
    try {
      var headers = {
        'Authorization': 'Bearer $aiToken',
        'Content-Type': 'application/json'
      };
      var request = http.Request('POST', Uri.parse('${endpoint}completions'));
      request.body = json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a health assistant. you will only talk about health issues!'
          },
          {
            'role': 'user',
            'content': prompt.toString(),
          }
        ],
        "temperature": 0,
        "max_tokens": 600,
        "stream": false
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // Read and print the chunks from the response stream
        // await for (var chunk in response.stream.transform(utf8.decoder)) {
        //   // Process each chunk as it is received
        //   debugPrint('chunk: $chunk');
        // }
        final data = await response.stream.bytesToString();
        final responseData = json.decode(data);
        debugPrint("AI reponse: ${responseData.toString()}");
        return jsonDecode(data);
      } else {
        final data = await response.stream.bytesToString();
        if (kDebugMode) {
          print(
              'error response: ${response.statusCode} ${json.decode(data).toString()}');
        }
        return {
          "status": false,
          "message": "Oops, try asking again. There was an error",
        };
      }
    } on SocketException catch (e) {
      return {
        'status': false,
        'error': e.toString(),
        "message": "Oops, please check your internet connection",
      };
    } catch (e) {
      if (kDebugMode) {
        print('error $e');
      }
      return {
        'status': false,
        'error': e.toString(),
        "message": "Oops, try asking again. There was an error",
      };
    }
  }
}

void addToAIMsg(String data) {
  if (data.contains("content")) {
    final dataContent = jsonDecode(data);
    if (dataContent['choices'] != null &&
        dataContent['choices'][0]['delta'] != null &&
        dataContent['choices'][0]['delta']['content'] != null) {
      final content = dataContent['choices'][0]['delta']['content'];
      debugPrint(content);
    }
  }
}
