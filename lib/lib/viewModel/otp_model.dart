import 'dart:async';

import 'package:flutter/foundation.dart';

class OTP_Model with ChangeNotifier {
  int _start = 60;
  int get start => _start;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  late Timer _timer;

  void startTimer(int seconds) {
    _start = seconds;
    _isRunning = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _start--;
      if (_start <= 0) {
        stopTimer();
        return;
      }
      notifyListeners();
    });
  }

  void stopTimer() {
    _isRunning = false;
    _timer.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}
