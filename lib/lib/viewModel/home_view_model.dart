import 'dart:convert';

import 'package:digihealthcardapp/res/app_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeViewModel with ChangeNotifier {
  Future<List<String>> fetchCardTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCardTypes = prefs.getStringList('cardTypes');

    if (savedCardTypes != null && savedCardTypes.isNotEmpty) {
      // If the list exists in SharedPreferences, return it
      return savedCardTypes;
    } else {
      // If the list does not exist in SharedPreferences, fetch it from the server
      final response = await http.get(Uri.parse(AppUrl.cardtypes));

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        final cardTypes = List<String>.from(jsonBody['data']);

        // Save the card types to SharedPreferences
        await prefs.setStringList('cardTypes', cardTypes);

        return cardTypes;
      } else {
        throw Exception('Failed to fetch card types');
      }
    }
  }

  Future<List<String>> fetchIdCardTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final idCardTypes = prefs.getStringList('id_cards');

    if (idCardTypes != null && idCardTypes.isNotEmpty) {
      // If the list exists in SharedPreferences, return it
      return idCardTypes;
    } else {
      // If the list does not exist in SharedPreferences, fetch it from the server
      final response = await http.get(Uri.parse(AppUrl.idcardtypes));

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        final idcardTypes = List<String>.from(jsonBody['data']);

        // Save the card types to SharedPreferences
        await prefs.setStringList('id_cards', idcardTypes);

        return idcardTypes;
      } else {
        throw Exception('Failed to fetch card types');
      }
    }
  }

  Future<List<String>> fetchlabels() async {
    final prefs = await SharedPreferences.getInstance();
    final deletePageLabels = prefs.getStringList('delete_page_labels');

    if (deletePageLabels != null && deletePageLabels.isNotEmpty) {
      // If the list exists in SharedPreferences, return it
      return deletePageLabels;
    } else {
      // If the list does not exist in SharedPreferences, fetch it from the server
      final response = await http.post(
        Uri.parse(
          AppUrl.labels,
        ),
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        final deletePagelabels =
            List<String>.from(jsonBody['data']['delete_page_labels']);
        // Save the card types to SharedPreferences
        await prefs.setStringList('delete_page_labels', deletePagelabels);

        return deletePagelabels;
      } else {
        throw Exception('Failed to fetch labels');
      }
    }
  }

  Future<String> fetchLocURl() async {
    final prefs = await SharedPreferences.getInstance();
    final locationUrl = prefs.getString('location_url');

    if (locationUrl != null && locationUrl.isNotEmpty) {
      // If the list exists in SharedPreferences, return it
      debugPrint(locationUrl);
      return locationUrl;
    } else {
      // If the list does not exist in SharedPreferences, fetch it from the server
      final url = AppUrl.labels;
      debugPrint(url);
      final response = await http.post(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        String testLocationUrl =
            jsonBody['data']['test_locations']['url'].toString();
        debugPrint(testLocationUrl);
        String testresultemail =
            jsonBody['data']['testresults']['email'].toString();
        String footerline1 = jsonBody['data']['footer']['line1'].toString();
        String footerline2 = jsonBody['data']['footer']['line2'].toString();
        String privacyPolicy =
            jsonBody['data']['patient_registeration'][0]['url'];
        String termsnConditions =
            jsonBody['data']['patient_registeration'][1]['url'];
        String subscriptionPolicy =
            jsonBody['data']['patient_registeration'][2]['url'];
        String subscriptionTrial =
            jsonBody['data']['patient_registeration'][2]['subheader'];
        String appSecurity =
            jsonBody['data']['patient_registeration'][3]['url'];
        String shareText = jsonBody['data']['share_text']['text'].toString();

        // Save the labels to SharedPreferences
        await prefs.setString('location_url', testLocationUrl);
        await prefs.setString('fetch_email', testresultemail);
        await prefs.setString('shareText', shareText);
        await prefs.setString('footer_l1', footerline1);
        await prefs.setString('footer_l2', footerline2);
        await prefs.setString('privacy_policy', privacyPolicy);
        await prefs.setString('terms', termsnConditions);
        await prefs.setString('security', appSecurity);
        await prefs.setString('sub_policy', subscriptionPolicy);
        await prefs.setString('subscription_timeline', subscriptionTrial);
        return testLocationUrl;
      } else {
        throw Exception('Failed to fetch URl');
      }
    }
  }

  Future<String> fetchsearchURl() async {
    final prefs = await SharedPreferences.getInstance();
    final searchLocUrl = prefs.getString('search_url');

    if (searchLocUrl != null && searchLocUrl.isNotEmpty) {
      // If the list exists in SharedPreferences, return it
      debugPrint(searchLocUrl);
      return searchLocUrl;
    } else {
      // If the list does not exist in SharedPreferences, fetch it from the server
      final response = await http.post(
        Uri.parse(
          AppUrl.labels,
        ),
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        String searchLocationURl =
            jsonBody['data']['test_locations']['city_search'].toString();
        debugPrint(searchLocationURl);
        // Save the location url to SharedPreferences
        await prefs.setString('search_url', searchLocationURl);

        return searchLocationURl;
      } else {
        throw Exception('Failed to fetch URl');
      }
    }
  }
}
