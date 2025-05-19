import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:weblibre/utils/sampled_value_notifier.dart';

/// A custom hook that creates a sampled ValueNotifier from another ValueNotifier
ValueNotifier<T> useSampledValueNotifier<T>({
  required ValueNotifier<T> source,
  required Duration sampleDuration,
}) {
  return use(
    _SampledValueNotifierHook<T>(
      source: source,
      sampleDuration: sampleDuration,
    ),
  );
}

/// Hook implementation for sampled ValueNotifier
class _SampledValueNotifierHook<T> extends Hook<ValueNotifier<T>> {
  final ValueNotifier<T> source;
  final Duration sampleDuration;

  const _SampledValueNotifierHook({
    required this.source,
    required this.sampleDuration,
  });

  @override
  _SampledValueNotifierHookState<T> createState() =>
      _SampledValueNotifierHookState<T>();
}

class _SampledValueNotifierHookState<T>
    extends HookState<ValueNotifier<T>, _SampledValueNotifierHook<T>> {
  late SampledValueNotifier<T> _sampledNotifier;

  @override
  void initHook() {
    super.initHook();
    _sampledNotifier = SampledValueNotifier<T>(
      source: hook.source,
      sampleDuration: hook.sampleDuration,
    );
  }

  @override
  ValueNotifier<T> build(BuildContext context) {
    return _sampledNotifier;
  }

  @override
  void dispose() {
    _sampledNotifier.dispose();
    super.dispose();
  }

  @override
  String get debugLabel => 'useSampledValueNotifier<$T>';
}
