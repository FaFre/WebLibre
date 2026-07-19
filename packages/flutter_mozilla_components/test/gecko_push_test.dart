import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart'
    show GeckoPushEvents;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('accepts sequence zero and ignores duplicate or older events', () async {
    final service = GeckoPushService();
    addTearDown(service.dispose);
    final statuses = <PushStatus>[];
    final subscription = service.statusChanges.listen(statuses.add);
    addTearDown(subscription.cancel);

    service.onPushStatusChanged(0, _status(PushDistributorStatus.pending));
    service.onPushStatusChanged(0, _status(PushDistributorStatus.ready));
    service.onPushStatusChanged(-1, _status(PushDistributorStatus.unavailable));
    service.onPushStatusChanged(2, _status(PushDistributorStatus.ready));
    await pumpEventQueue();

    expect(statuses.map((status) => status.status), [
      PushDistributorStatus.pending,
      PushDistributorStatus.ready,
    ]);
  });

  test(
    'setup and disposal are idempotent and unregister the exact channel',
    () async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final service = GeckoPushService(
        binaryMessenger: messenger,
        messageChannelSuffix: 'push-test',
      );
      final statuses = <PushStatus>[];
      final subscription = service.statusChanges.listen(statuses.add);
      addTearDown(subscription.cancel);

      service.setUp();
      service.setUp();

      final responseBeforeDispose = await _dispatchStatus(
        messenger,
        suffix: 'push-test',
        sequence: 1,
        status: _status(PushDistributorStatus.ready),
      );
      await pumpEventQueue();

      expect(responseBeforeDispose, isNotNull);
      expect(statuses, hasLength(1));

      await service.dispose();
      await service.dispose();

      final responseAfterDispose = await _dispatchStatus(
        messenger,
        suffix: 'push-test',
        sequence: 2,
        status: _status(PushDistributorStatus.unavailable),
      );
      service.onPushStatusChanged(3, _status(PushDistributorStatus.pending));
      service.setUp();
      await pumpEventQueue();

      expect(responseAfterDispose, isNull);
      expect(statuses, hasLength(1));
    },
  );
}

PushStatus _status(PushDistributorStatus status) {
  return PushStatus(status: status, available: const []);
}

Future<ByteData?> _dispatchStatus(
  TestDefaultBinaryMessenger messenger, {
  required String suffix,
  required int sequence,
  required PushStatus status,
}) async {
  final reply = Completer<ByteData?>();
  final channelSuffix = suffix.isEmpty ? '' : '.$suffix';
  await messenger.handlePlatformMessage(
    'dev.flutter.pigeon.flutter_mozilla_components.GeckoPushEvents.onPushStatusChanged$channelSuffix',
    GeckoPushEvents.pigeonChannelCodec.encodeMessage([sequence, status]),
    reply.complete,
  );
  return reply.future;
}
