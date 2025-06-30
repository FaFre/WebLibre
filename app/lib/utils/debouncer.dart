import 'dart:async';

class Debouncer {
  final Duration debounce;

  Timer? _timer;

  Debouncer(this.debounce);

  bool get isDebouncing => _timer?.isActive ?? false;

  void eventOccured(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(debounce, callback);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
