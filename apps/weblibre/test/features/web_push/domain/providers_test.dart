import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/web_push/domain/providers.dart';

void main() {
  test('discards stale initial status after a native event', () async {
    final service = _FakePushService();
    final container = _container(service);
    addTearDown(container.dispose);
    addTearDown(service.close);
    final values = <AsyncValue<PushStatus>>[];
    final subscription = container.listen(
      pushStatusProvider,
      (_, next) => values.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await pumpEventQueue();

    service.emit(_status(PushDistributorStatus.ready));
    service.initialStatus.complete(_status(PushDistributorStatus.pending));
    await pumpEventQueue();

    expect(values.where((value) => value.hasError), isEmpty);
    expect(values.last.value?.status, PushDistributorStatus.ready);
  });

  test('discards stale initial error after a native event', () async {
    final service = _FakePushService();
    final container = _container(service);
    addTearDown(container.dispose);
    addTearDown(service.close);
    final values = <AsyncValue<PushStatus>>[];
    final subscription = container.listen(
      pushStatusProvider,
      (_, next) => values.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await pumpEventQueue();

    service.emit(_status(PushDistributorStatus.ready));
    service.initialStatus.completeError(StateError('stale snapshot failure'));
    await pumpEventQueue();

    expect(values.where((value) => value.hasError), isEmpty);
    expect(values.last.value?.status, PushDistributorStatus.ready);
  });

  test('mutation shares duplicate work and exposes failure', () async {
    final service = _FakePushService();
    final setCompleter = Completer<void>();
    service.setDistributorResult = setCompleter.future;
    final container = _container(service);
    addTearDown(container.dispose);
    addTearDown(service.close);
    final subscription = container.listen(
      pushDistributorMutationProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await container.read(pushDistributorMutationProvider.future);

    final notifier = container.read(pushDistributorMutationProvider.notifier);
    final first = notifier.setDistributor('org.example.distributor');
    final duplicate = notifier.setDistributor('org.example.distributor');

    expect(service.setDistributorCalls, 1);
    expect(container.read(pushDistributorMutationProvider).isLoading, isTrue);

    setCompleter.completeError(StateError('registration failed'));
    await expectLater(first, throwsA(isA<StateError>()));
    await expectLater(duplicate, throwsA(isA<StateError>()));

    expect(container.read(pushDistributorMutationProvider).hasError, isTrue);
  });

  test('remove failure is exposed by the mutation controller', () async {
    final service = _FakePushService()
      ..removeDistributorError = StateError('remove failed');
    final container = _container(service);
    addTearDown(container.dispose);
    addTearDown(service.close);
    final subscription = container.listen(
      pushDistributorMutationProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await container.read(pushDistributorMutationProvider.future);

    await expectLater(
      container
          .read(pushDistributorMutationProvider.notifier)
          .removeDistributor(),
      throwsA(isA<StateError>()),
    );

    expect(service.removeDistributorCalls, 1);
    expect(container.read(pushDistributorMutationProvider).hasError, isTrue);
  });

  test('serializes distinct mutations instead of dropping them', () async {
    final service = _FakePushService();
    final setCompleter = Completer<void>();
    service.setDistributorResult = setCompleter.future;
    final container = _container(service);
    addTearDown(container.dispose);
    addTearDown(service.close);
    final subscription = container.listen(
      pushDistributorMutationProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await container.read(pushDistributorMutationProvider.future);

    final notifier = container.read(pushDistributorMutationProvider.notifier);
    final set = notifier.setDistributor('org.example.distributor');
    final remove = notifier.removeDistributor();

    // The distinct remove must not be coalesced into the in-flight set; it is
    // queued behind it and only runs once the set settles.
    expect(service.setDistributorCalls, 1);
    expect(service.removeDistributorCalls, 0);

    setCompleter.complete();
    await set;
    await remove;

    // Both distinct operations actually ran.
    expect(service.setDistributorCalls, 1);
    expect(service.removeDistributorCalls, 1);
  });
}

ProviderContainer _container(_FakePushService service) {
  return ProviderContainer(
    overrides: [pushServiceProvider.overrideWithValue(service)],
  );
}

PushStatus _status(PushDistributorStatus status) {
  return PushStatus(status: status, available: const []);
}

class _FakePushService extends GeckoPushService {
  final statusController = StreamController<PushStatus>.broadcast(sync: true);
  final initialStatus = Completer<PushStatus>();
  Future<void> setDistributorResult = Future.value();
  Object? removeDistributorError;
  int setDistributorCalls = 0;
  int removeDistributorCalls = 0;

  @override
  Stream<PushStatus> get statusChanges => statusController.stream;

  @override
  Future<PushStatus> getPushStatus() => initialStatus.future;

  @override
  Future<void> setDistributor(String packageName) {
    setDistributorCalls++;
    return setDistributorResult;
  }

  @override
  Future<void> removeDistributor() async {
    removeDistributorCalls++;
    if (removeDistributorError case final error?) {
      throw error;
    }
  }

  void emit(PushStatus status) => statusController.add(status);

  Future<void> close() => statusController.close();
}
