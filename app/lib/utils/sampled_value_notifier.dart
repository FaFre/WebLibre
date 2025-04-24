import 'dart:async';
import 'package:flutter/foundation.dart';

/// A ValueNotifier that acts as a proxy for another ValueNotifier,
/// sampling its values based on a given duration.
class SampledValueNotifier<T> extends ValueNotifier<T> {
  /// The source ValueNotifier to sample from
  final ValueNotifier<T> _source;

  /// The duration to sample at
  final Duration _sampleDuration;

  /// Timer for sampling
  Timer? _timer;

  /// Whether a value has changed since the last sample
  bool _hasNewValue = false;

  /// Subscription to the source ValueNotifier
  late final VoidCallback _sourceListener;

  /// Creates a SampledValueNotifier that samples values from [source]
  /// at the specified [sampleDuration].
  SampledValueNotifier({
    required ValueNotifier<T> source,
    required Duration sampleDuration,
  }) : _source = source,
       _sampleDuration = sampleDuration,
       super(source.value) {
    // Set up listener for source changes
    _sourceListener = () {
      _hasNewValue = true;

      // Start timer if not already running
      if (_timer == null || !_timer!.isActive) {
        _startTimer();
      }
    };

    _source.addListener(_sourceListener);
    _startTimer();
  }

  /// Starts the sampling timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_sampleDuration, _onSampleTime);
  }

  /// Called when it's time to sample
  void _onSampleTime(Timer timer) {
    if (_hasNewValue) {
      value = _source.value;
      _hasNewValue = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _source.removeListener(_sourceListener);

    super.dispose();
  }
}

extension ValueNotifierSampleExtension<T> on ValueNotifier<T> {
  /// Creates a new ValueNotifier that samples this ValueNotifier's values
  /// at the specified [duration].
  ///
  /// The returned ValueNotifier must be disposed when no longer needed.
  ValueNotifier<T> sampleTime(Duration duration) {
    return SampledValueNotifier<T>(source: this, sampleDuration: duration);
  }
}
