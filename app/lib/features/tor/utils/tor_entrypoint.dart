import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:tor/tor.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  await Tor.init();

  final portSub = Tor.instance.events.stream.listen((port) {
    service.invoke('portUpdate', {'port': port});
  });

  await Tor.instance.start();

  service.on("stop").listen((event) async {
    Tor.instance.stop();
    service.invoke('portUpdate', {'port': -1});

    await portSub.cancel();

    await service.stopSelf();
  });
}
