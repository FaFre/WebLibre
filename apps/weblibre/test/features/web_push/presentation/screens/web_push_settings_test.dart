import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weblibre/features/web_push/domain/providers.dart';
import 'package:weblibre/features/web_push/presentation/screens/web_push_settings.dart';

void main() {
  testWidgets('refreshes notification permission when the app resumes', (
    tester,
  ) async {
    final permissionService = _FakePermissionService();
    await _pumpSettings(tester, permissionService: permissionService);

    expect(permissionService.checkCalls, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(permissionService.checkCalls, 2);
  });

  testWidgets('permission request prevents duplicates and reports errors', (
    tester,
  ) async {
    final request = Completer<PermissionStatus>();
    final permissionService = _FakePermissionService(
      requestResult: request.future,
    );
    await _pumpSettings(tester, permissionService: permissionService);

    await tester.tap(find.text('Grant'));
    await tester.pump();
    await tester.tap(find.byType(TextButton).last);
    await tester.pump();

    expect(permissionService.requestCalls, 1);

    request.completeError(StateError('permission plugin failed'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Could not update notification permission'),
      findsOneWidget,
    );
  });

  testWidgets('distributor mutation reports errors without showing success', (
    tester,
  ) async {
    final pushService = _FakePushService(
      setDistributorError: StateError('registration failed'),
    );
    await _pumpSettings(tester, pushService: pushService);

    await tester.tap(find.text('UnifiedPush Distributor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test Distributor'));
    await tester.pumpAndSettle();

    expect(pushService.setDistributorCalls, 1);
    expect(
      find.textContaining('Could not configure distributor'),
      findsOneWidget,
    );
    expect(find.text('UnifiedPush distributor configured.'), findsNothing);
  });
}

Future<void> _pumpSettings(
  WidgetTester tester, {
  _FakePushService? pushService,
  _FakePermissionService? permissionService,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pushServiceProvider.overrideWithValue(
          pushService ?? _FakePushService(),
        ),
        notificationPermissionServiceProvider.overrideWithValue(
          permissionService ?? _FakePermissionService(),
        ),
      ],
      child: const MaterialApp(home: WebPushSettingsScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakePushService extends GeckoPushService {
  final Object? setDistributorError;
  int setDistributorCalls = 0;

  _FakePushService({this.setDistributorError});

  @override
  Stream<PushStatus> get statusChanges => const Stream.empty();

  @override
  Future<PushStatus> getPushStatus() async {
    return PushStatus(
      status: PushDistributorStatus.notSelected,
      available: [
        PushDistributor(
          packageName: 'org.example.distributor',
          label: 'Test Distributor',
        ),
      ],
    );
  }

  @override
  Future<List<PushSubscription>> getSubscriptions() async => const [];

  @override
  Future<void> setDistributor(String packageName) async {
    setDistributorCalls++;
    if (setDistributorError case final error?) {
      throw error;
    }
  }
}

class _FakePermissionService extends NotificationPermissionService {
  final Future<PermissionStatus>? requestResult;
  int checkCalls = 0;
  int requestCalls = 0;

  _FakePermissionService({this.requestResult});

  @override
  Future<bool> isGranted() async {
    checkCalls++;
    return false;
  }

  @override
  Future<PermissionStatus> request() {
    requestCalls++;
    return requestResult ?? Future.value(PermissionStatus.denied);
  }
}
