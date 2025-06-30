import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:tor/tor.dart';

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  Timer? timeout;

  await Tor.init();

  final portSub = Tor.instance.events.stream.listen((port) {
    service.invoke('portUpdate', {'port': port});
  });

  Future<void> stopService() async {
    timeout?.cancel();
    timeout = null;

    Tor.instance.stop();
    service.invoke('portUpdate', {'port': -1});

    await portSub.cancel();

    await service.stopSelf();
  }

  void addHeartbeat() {
    timeout?.cancel();
    timeout = Timer(const Duration(minutes: 15), () async {
      // logger.i('Terminating tor due to timeout');
      await stopService();
    });
  }

  await Tor.instance.start();

  service.on("heartbeat").listen((event) {
    // logger.d('Received tor heartbeat');
    addHeartbeat();
  });

  service.on("sync").listen((event) {
    service.invoke('portUpdate', {'port': Tor.instance.port});
  });

  service.on("stop").listen((event) async {
    await stopService();
  });
}
