import 'dart:async';
import 'dart:math';

import 'package:core/core.dart';

class ReactiveLeaseLimiter {
  var _available = 0;
  var _timeToLive = 0;
  var _timestamp = DateTime.now().millisecondsSinceEpoch;
  var _enabled = false;

  bool get enabled => _enabled;

  @inline
  bool restricted(int count) {
    if (_available < count) return true;
    if (DateTime.now().millisecondsSinceEpoch - _timestamp > _timeToLive) {
      _available = 0;
      return true;
    }
    return false;
  }

  @inline
  void reconfigure(int timeToLive, int requests) {
    _enabled = true;
    _available = requests;
    _timeToLive = timeToLive;
    _timestamp = DateTime.now().millisecondsSinceEpoch;
  }

  @inline
  void notify(int count) {
    _available = max(_available - count, 0);
    if (DateTime.now().millisecondsSinceEpoch - _timestamp > _timeToLive) {
      _available = 0;
    }
  }
}

class ReactiveLeaseScheduler {
  var _active = false;

  late Timer _timer;

  void start(int timeToLive, void Function() action) {
    if (_active) return;
    _active = true;
    _timer = Timer.periodic(Duration(milliseconds: timeToLive), (Timer timer) {
      if (timer.isActive == true) action();
    });
  }

  void stop() {
    if (_active) {
      _active = false;
      _timer.cancel();
    }
  }
}
