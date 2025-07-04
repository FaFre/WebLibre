import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers/lifecycle.dart';
import 'package:weblibre/features/tor/utils/tor_entrypoint.dart';

part 'tor_proxy.g.dart';

class _TorService {
  final service = FlutterBackgroundService();

  final _portSubject = BehaviorSubject<int?>.seeded(null);

  ValueStream<int?> get portStream => _portSubject.stream;

  Future<void> start() async {
    await service.startService();
  }

  Future<void> requestSync() async {
    service.invoke("sync");
  }

  Future<void> sendHeartbeat() async {
    service.invoke("heartbeat");
  }

  Future<void> stop() async {
    service.invoke("stop");
  }

  Future<void> initializeService() async {
    await service.configure(
      iosConfiguration: IosConfiguration(autoStart: false),
      androidConfiguration: AndroidConfiguration(
        autoStart: false,
        onStart: onStart,
        isForegroundMode: true,
        autoStartOnBoot: false,
        initialNotificationTitle: 'Tor Service',
        initialNotificationContent: 'Running in background',
      ),
    );

    service.on('portUpdate').listen((data) {
      final port = data!['port'] as int;
      _portSubject.add((port > -1) ? port : null);
    });
  }

  Future<void> dispose() async {
    await stop();
    await _portSubject.close();
  }
}

@Riverpod(keepAlive: true)
class TorProxyService extends _$TorProxyService {
  final _tor = _TorService();

  Timer? _heartbeatUpdate;
  //This is managed by widget state changes to resume a timer
  bool _timerPaused = false;

  void _enableHeartbeatTimer() {
    _heartbeatUpdate?.cancel();
    _timerPaused = false;
    _heartbeatUpdate = Timer.periodic(const Duration(seconds: 30), (
      timer,
    ) async {
      await _tor.sendHeartbeat();
    });
  }

  Future<void> connect({bool forceReconnect = false}) async {
    final currentPort = await requestSync();

    if (currentPort == null || forceReconnect) {
      state = const AsyncLoading();
      await _tor.start();
      _enableHeartbeatTimer();
    }
  }

  Future<int?> requestSync() async {
    final nextPortUpdate = _tor.portStream.first;

    await _tor.requestSync();
    return nextPortUpdate;
  }

  Future<void> disconnect() async {
    state = const AsyncLoading();

    _heartbeatUpdate?.cancel();
    _heartbeatUpdate = null;
    _timerPaused = false;

    await _tor.stop();
  }

  @override
  Future<int?> build() async {
    final portSub = _tor.portStream.distinct().listen((port) {
      state = AsyncData(port);
    });

    await _tor.initializeService();

    ref.listen(
      fireImmediately: true,
      browserViewLifecycleProvider,
      (previous, next) {
        switch (next) {
          case AppLifecycleState.resumed:
            if (_timerPaused) {
              _enableHeartbeatTimer();
            }
          case AppLifecycleState.detached:
          case AppLifecycleState.inactive:
          case AppLifecycleState.hidden:
          case AppLifecycleState.paused:
          case null:
            if (_heartbeatUpdate?.isActive == true) {
              _heartbeatUpdate?.cancel();
              _timerPaused = true;
            }
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to browserViewLifecycleProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.onDispose(() async {
      _heartbeatUpdate?.cancel();
      _heartbeatUpdate = null;
      _timerPaused = false;

      await portSub.cancel();
      await _tor.dispose();
    });

    return _tor.portStream.valueOrNull;
  }
}
