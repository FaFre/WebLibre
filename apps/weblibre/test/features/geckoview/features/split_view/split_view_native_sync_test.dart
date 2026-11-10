import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view_inputs.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/services/split_view_native_sync.dart';

/// Records every state pushed to native.
class _FakeService extends GeckoSplitViewService {
  final pushed = <SplitViewState>[];

  /// How many of the next pushes fail, as a channel error would.
  int failures = 0;

  @override
  Future<void> setSplitState(SplitViewState state) async {
    if (failures > 0) {
      failures--;
      throw PlatformException(code: 'channel-error');
    }
    pushed.add(state);
  }
}

class _Ready extends EngineReadyState {
  @override
  bool build() => true;
}

class _PairHolder extends Notifier<SplitPair?> {
  @override
  SplitPair? build() => null;

  // ignore: use_setters_to_change_properties
  void set(SplitPair? pair) => state = pair;
}

final _pairHolder = NotifierProvider<_PairHolder, SplitPair?>(_PairHolder.new);

SplitPair _pair({
  String id = 'p1',
  SplitLayoutPreference layout = SplitLayoutPreference.automatic,
}) => SplitPair(
  pairId: id,
  firstTabId: 'a',
  secondTabId: 'b',
  layout: layout,
  sideBySideRatio: 0.5,
  stackedRatio: 0.5,
  focusedOnly: false,
);

void main() {
  late _FakeService service;
  late ProviderContainer container;

  ProviderContainer newContainer() {
    final created = ProviderContainer(
      overrides: [
        splitViewServiceProvider.overrideWithValue(service),
        engineReadyStateProvider.overrideWith(_Ready.new),
        splitPairShownProvider.overrideWith((ref) => ref.watch(_pairHolder)),
        splitKeyboardVisibleProvider.overrideWith((ref) => Stream.value(false)),
        splitTabIdentityProvider.overrideWith(
          (ref, tabId) => ModeSplitTabIdentity(null),
        ),
      ],
    );
    addTearDown(created.dispose);
    return created;
  }

  setUp(() {
    service = _FakeService();
    container = newContainer();
  });

  Future<List<SplitViewState>> settle() async {
    container.read(splitViewNativeSyncProvider);
    await container.read(splitViewNativeSyncProvider.notifier).flush();
    return service.pushed;
  }

  test('first push is revision 1 of the instance epoch', () async {
    final pushed = await settle();

    expect(pushed, hasLength(1));
    expect(pushed.single.revision, 1);
    expect(
      pushed.single.epoch,
      container.read(splitViewNativeSyncProvider).epoch,
    );
    expect(pushed.single.pair, isNull);
  });

  test(
    'a failed push is reported, and the next flush pushes it again',
    () async {
      await settle();
      final sync = container.read(splitViewNativeSyncProvider.notifier);

      service.failures = 1;
      container.read(_pairHolder.notifier).set(_pair());
      container.read(splitViewNativeSyncProvider);
      expect(await sync.flush(), isFalse);
      expect(service.pushed.last.pair, isNull);

      // Nothing changed since, yet native gets the pair now.
      expect(await sync.flush(), isTrue);
      expect(service.pushed.last.pair?.pairId, 'p1');
    },
  );

  test('revisions grow and an unchanged state is not pushed again', () async {
    await settle();

    container.read(_pairHolder.notifier).set(_pair());
    await settle();
    // Same value again (a new instance equal by value).
    container.read(_pairHolder.notifier).set(_pair());
    await settle();

    expect(service.pushed.map((s) => s.revision), [1, 2]);
    expect(service.pushed.last.pair?.pairId, 'p1');
  });

  test('a restarted Dart half starts a new epoch at revision 1', () async {
    container.read(_pairHolder.notifier).set(_pair());
    await settle();
    await settle();
    final firstEpoch = service.pushed.last.epoch;

    container = newContainer();
    service.pushed.clear();
    await settle();

    expect(service.pushed.single.revision, 1);
    expect(service.pushed.single.epoch, isNot(firstEpoch));
  });

  test('a hinge across the content decides the arrangement', () async {
    container.read(_pairHolder.notifier).set(_pair());
    container
        .read(browserContentGeometryProvider.notifier)
        .report(const Size(900, 600));
    await settle();
    expect(service.pushed.last.pair?.draggable, isTrue);

    // A horizontal hinge: stacked around it, even though the content is wide.
    container
        .read(browserContentHingeProvider.notifier)
        .report(const Rect.fromLTWH(0, 290, 900, 20));
    await settle();

    final pair = service.pushed.last.pair!;
    expect(pair.mode, SplitPaneMode.stacked);
    expect(pair.draggable, isFalse);
    expect(pair.dividerDp, 20);
  });

  test(
    'native re-checks with the floor the preference was shown with',
    () async {
      container
          .read(browserContentGeometryProvider.notifier)
          .report(const Size(360, 640));

      container.read(_pairHolder.notifier).set(_pair());
      await settle();
      expect(service.pushed.last.pair?.mode, SplitPaneMode.stacked);
      expect(service.pushed.last.minPaneWidthDp, 280);
      expect(service.pushed.last.minPaneHeightDp, 200);

      // An explicit Side by side is shown on a phone in portrait, and native
      // must not drop it again with Automatic's 280dp floor.
      container
          .read(_pairHolder.notifier)
          .set(_pair(layout: SplitLayoutPreference.sideBySide));
      await settle();
      expect(service.pushed.last.pair?.mode, SplitPaneMode.sideBySide);
      expect(service.pushed.last.minPaneWidthDp, 120);
      expect(service.pushed.last.minPaneHeightDp, 100);
    },
  );
}
