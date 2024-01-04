import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeModel with ChangeNotifier {
  static const Permission_Status = "Permissions";

  Future<void> setPermValue(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Permission_Status, value);
  }

  bool _hasCameraPermission = false;
  bool get hasCameraPermission => _hasCameraPermission;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setPermission(bool value) {
    _hasCameraPermission = value;
    setPermValue(value);
    notifyListeners();
  }

  Future<bool> getPermissionValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(Permission_Status) ?? false;
  }

  Future<void> loadPermission() async {
    bool permissionValue = await getPermissionValue();
    _hasCameraPermission = permissionValue;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
