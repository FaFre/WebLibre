import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

AsyncSnapshot<T> useCachedFuture<T>(
  Future<T> Function() valueBuilder, [
  List<Object?> keys = const <Object>[],
]) {
  // ignore: discarded_futures is used
  final cachedFuture = useMemoized(valueBuilder, keys);
  return useFuture(cachedFuture);
}
