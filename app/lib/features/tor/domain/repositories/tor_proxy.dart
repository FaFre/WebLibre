import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';

part 'tor_proxy.g.dart';

@Riverpod(keepAlive: true)
class TorProxyRepository extends _$TorProxyRepository {
  final _service = GeckoContainerProxyService();
  final _serviceLock = Lock();

  Future<void> setProxyPort(int port) {
    return _serviceLock.synchronized(() async {
      await _waitHealthcheck().timeout(const Duration(seconds: 10));

      return _service.setProxyPort(port);
    });
  }

  Future<void> addContainerProxy(String contextId) {
    return _serviceLock.synchronized(() async {
      await _waitHealthcheck().timeout(const Duration(seconds: 10));

      return _service.addContainerProxy(contextId);
    });
  }

  Future<void> removeContainerProxy(String contextId) {
    return _serviceLock.synchronized(() async {
      await _waitHealthcheck().timeout(const Duration(seconds: 10));

      return _service.removeContainerProxy(contextId);
    });
  }

  Future<void> _waitHealthcheck({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final startTime = DateTime.now();

    var healthy = await _service.healthcheck();
    while (!healthy) {
      if (DateTime.now().difference(startTime) > timeout) {
        throw TimeoutException('Timed out waiting for proxy service');
      }

      await Future.delayed(const Duration(milliseconds: 25));
      healthy = await _service.healthcheck();
    }
  }

  @override
  void build() {
    return;
  }
}
