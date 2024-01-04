import 'package:digihealthcardapp/res/app_url.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class themeChanger with ChangeNotifier {
  static const THEME_STATUS = "THEMESTATUS";
  var _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeValue(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(THEME_STATUS, value);
  }

  Future<dynamic> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(THEME_STATUS) ?? 0;
  }

  Future<void> loadTheme() async {
    int themeValue = await getTheme();
    _themeMode = _getThemeMode(themeValue);
    notifyListeners();
  }

  void setTheme(themeMode, int value) async {
    _themeMode = themeMode;
    await setThemeValue(value);
    notifyListeners();
  }

  ThemeMode _getThemeMode(int value) {
    switch (value) {
      case 0:
        return ThemeMode.system;
      case 1:
        return ThemeMode.dark;
      case 2:
        return ThemeMode.light;
      default:
        return ThemeMode.light;
    }
  }

  int _number = 0;
  int get number => _number;

  static const URl_STATUS = "URL";

  Future<void> setURLValue(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(URl_STATUS, value);
  }

  void setURL(int number) {
    _number = number;
    setURLValue(number);
    notifyListeners();
  }

  Future<dynamic> getURLValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(URl_STATUS) ?? 0;
  }

  Future<void> loadURL() async {
    int num = await getURLValue();
    AppUrl.updateBaseUrl(num);
    _number = num;
    notifyListeners();
  }
}
