import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'readerable.g.dart';

@Riverpod(keepAlive: true)
GeckoReaderableService readerableService(Ref ref) {
  final service = GeckoReaderableService.setUp();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

@Riverpod()
Stream<bool> appearanceButtonVisibility(Ref ref) {
  final service = ref.watch(readerableServiceProvider);
  return service.appearanceVisibility;
}
