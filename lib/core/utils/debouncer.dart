import 'dart:async';

/// A utility class for debouncing function calls
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({
    this.delay = const Duration(milliseconds: 500),
  });

  /// Execute the callback after the specified delay
  /// If called again before the delay, the previous call is cancelled
  void call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Cancel any pending execution
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Check if there's a pending execution
  bool get isActive => _timer?.isActive ?? false;

  /// Dispose the debouncer
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// A debouncer specifically for text input (like search)
class TextDebouncer {
  final Duration delay;
  final Function(String) onChanged;
  Timer? _timer;
  String _lastValue = '';

  TextDebouncer({
    required this.onChanged,
    this.delay = const Duration(milliseconds: 500),
  });

  /// Process text input with debouncing
  void process(String value) {
    if (value == _lastValue) return;

    _lastValue = value;
    _timer?.cancel();

    if (value.isEmpty) {
      onChanged(value);
      return;
    }

    _timer = Timer(delay, () {
      onChanged(value);
    });
  }

  /// Cancel any pending execution
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Dispose the debouncer
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// A callback type for debounced functions
typedef VoidCallback = void Function();
