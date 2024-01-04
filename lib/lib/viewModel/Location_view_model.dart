import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationViewModel with ChangeNotifier {
  Position? _position;
  Position? get position => _position;

  Future<void> getLocationData() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Handle case where user denies permission or selects "only while using the app"
        return;
      }
    }
    try {
      Position newPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          forceAndroidLocationManager: true);
      _position = newPosition;
      notifyListeners();
      if (kDebugMode) {
        print('Latitude: ${_position?.latitude}');
        print('Longitude: ${_position?.longitude}');
      }
    } catch (e) {
      debugPrint('e: $e');
    }
  }
}

class LocationProvider with ChangeNotifier {
  late Position? _position;

  Future<void> getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }
    _position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    // print('Latitude: ${_position?.latitude}');
    // print('Longitude: ${_position?.longitude}');
    notifyListeners();
  }

  Position? get position => _position;
}
