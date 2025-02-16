import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:lensai/features/tor/utils/tor_entrypoint.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'tor_proxy.g.dart';

class _TorService {
  final service = FlutterBackgroundService();

  final _portSubject = BehaviorSubject<int?>.seeded(null);

  ValueStream<int?> get portStream => _portSubject.stream;

  Future<void> start() async {
    await service.startService();
  }

  Future<void> stop() async {
    service.invoke("stop");
  }

  Future<void> initializeService() async {
    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: false,
        onStart: onStart,
        isForegroundMode: true,
        autoStartOnBoot: false,
      ),
    );

    service.on('portUpdate').listen((data) {
      final port = data!['port'] as int;
      _portSubject.add((port > -1) ? port : null);
    });
  }

  void dispose() {
    unawaited(stop());
    unawaited(_portSubject.close());
  }
}

@Riverpod(keepAlive: true)
class TorProxyService extends _$TorProxyService {
  final _tor = _TorService();

  Future<void> connect({bool forceReconnect = false}) async {
    final currentPort = _tor.portStream.valueOrNull;

    if (currentPort == null || forceReconnect) {
      state = const AsyncLoading();
      await _tor.start();
    }
  }

  Future<void> disconnect() async {
    state = const AsyncLoading();
    await _tor.stop();
  }

  @override
  Future<int?> build() async {
    final portSub = _tor.portStream.distinct().listen(
      (port) {
        state = AsyncData(port);
      },
    );

    await _tor.initializeService();

    ref.onDispose(() {
      unawaited(portSub.cancel());
      _tor.dispose();
    });

    return _tor.portStream.valueOrNull;
  }
}
