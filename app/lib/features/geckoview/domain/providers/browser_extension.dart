import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'browser_extension.g.dart';

@Riverpod(keepAlive: true)
GeckoBrowserExtensionService browserExtensionService(Ref ref) {
  final service = GeckoBrowserExtensionService.setUp();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

@Riverpod()
Stream<String> feedRequested(Ref ref) {
  final service = ref.watch(browserExtensionServiceProvider);
  return service.feedRequested;
}
