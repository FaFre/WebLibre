import 'dart:async';

import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view_inputs.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/services/split_view_native_sync.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';

class _FakeTabList extends TabList {
  _FakeTabList(this.initial);

  final List<String> initial;

  @override
  EquatableValue<List<String>> build() => EquatableValue(initial);

  void set(List<String> ids) => state = EquatableValue(ids);
}

class _FakeTabStates extends TabStates {
  _FakeTabStates(this.initial);

  final Map<String, TabState> initial;

  @override
  Map<String, TabState> build() => initial;

  /// Closed tabs whose state is still retained.
  final closed = <String>{};

  /// Content state that arrives only once its gate completes.
  final gates = <String, Completer<void>>{};

  void add(TabState tab) => state = {...state, tab.id: tab};

  @override
  bool isClosed(String tabId) => closed.contains(tabId);

  @override
  Future<TabState?> awaitContentState(
    String tabId, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await gates[tabId]?.future;
    return state[tabId];
  }
}

class _FakeTabRepository extends TabRepository {
  final Set<String> notReady = {};

  // Only the split pair subscription of the real build: it once made this
  // repository depend on the controller, which reads it while pairing.
  @override
  void build() => followVisiblePair();

  @override
  Future<bool> ensureRoutingReady(String tabId) async =>
      !notReady.contains(tabId);
}

/// Native sync stand-in: [flush] waits for [gate] when one is set, as a push
/// that native has not applied yet would.
class _FakeSync extends SplitViewNativeSync {
  Completer<void>? gate;

  @override
  SplitViewState build() => SplitViewState(
    epoch: 'test',
    revision: 0,
    minPaneWidthDp: 280,
    minPaneHeightDp: 200,
    dragMinPaneWidthDp: 120,
    dragMinPaneHeightDp: 100,
    dividerColorArgb: 0,
    gripColorArgb: 0,
    dragPreviewColorArgb: 0,
    placeholderColorArgb: 0,
    onPlaceholderColorArgb: 0,
    labels: SplitViewLabels(
      dividerDescription: '',
      dividerOptionsAction: '',
      crashedTitle: '',
      crashedReload: '',
    ),
  );

  /// What [flush] reports: whether native took the state.
  bool delivers = true;

  @override
  Future<bool> flush() async {
    await gate?.future;
    return delivers;
  }
}

/// Records every state pushed to native.
class _RecordingService extends GeckoSplitViewService {
  final pushed = <SplitViewState>[];

  @override
  Future<void> setSplitState(SplitViewState state) async {
    pushed.add(state);
  }
}

class _EngineReady extends EngineReadyState {
  @override
  bool build() => true;
}

class _FakeSelectedTab extends SelectedTab {
  @override
  String? build() => null;

  // ignore: use_setters_to_change_properties
  void set(String? id) => state = id;
}

TabState _tab(String id, {TabMode mode = TabMode.regular}) =>
    TabState.$default(id).copyWith(tabMode: mode, hasContentState: true);

void main() {
  late ProviderContainer container;
  late _FakeTabList tabList;
  late _FakeTabStates tabStates;
  late _FakeTabRepository tabRepository;
  late _FakeSync sync;
  late _FakeSelectedTab selectedTab;
  // Stands in for the visibility switch of split view.
  late bool splitShown;

  SplitViewController controller() =>
      container.read(splitViewControllerProvider.notifier);
  SplitPair? pair() => container.read(splitViewControllerProvider);

  setUp(() {
    tabList = _FakeTabList(['a', 'b', 'c', 'p', 'q']);
    tabStates = _FakeTabStates({
      for (final id in ['a', 'b', 'c']) id: _tab(id),
      'p': _tab('p', mode: TabMode.private),
      'q': _tab('q', mode: TabMode.private),
    });
    tabRepository = _FakeTabRepository();
    sync = _FakeSync();
    selectedTab = _FakeSelectedTab();
    splitShown = true;

    container = ProviderContainer(
      overrides: [
        tabListProvider.overrideWith(() => tabList),
        tabStatesProvider.overrideWith(() => tabStates),
        tabRepositoryProvider.overrideWith(() => tabRepository),
        splitViewNativeSyncProvider.overrideWith(() => sync),
        selectedTabProvider.overrideWith(() => selectedTab),
        splitPairShownProvider.overrideWith(
          (ref) => splitShown ? ref.watch(splitViewControllerProvider) : null,
        ),
      ],
    );
    addTearDown(container.dispose);

    // Starts the controller and its tab-list listener, and the tab
    // repository, which the browser starts with the engine.
    container
      ..listen(splitViewControllerProvider, (_, _) {})
      ..listen(splitViewReconciliationProvider, (_, _) {})
      ..listen(tabRepositoryProvider, (_, _) {});
  });

  group('pair', () {
    test(
      'reading the tab repository is no dependency cycle while it follows '
      'the shown pair',
      () async {
        // Throws CircularDependencyError in debug builds (tests included)
        // when the repository subscribes to the pair through its own ref.
        await controller().pair('a', 'b');
        expect(pair(), isNotNull);
      },
    );

    test('forms a pair, and a new request replaces it', () async {
      await controller().pair('a', 'b');
      final first = pair()!;
      expect((first.firstTabId, first.secondTabId), ('a', 'b'));

      await controller().pair('c', 'b');
      final second = pair()!;
      // b is in the old pair but c is not: a new pair, with defaults.
      expect(second.pairId, isNot(first.pairId));
    });

    test('with the focused member only the partner changes', () async {
      await controller().pair('a', 'b');
      controller()
        ..setLayout(SplitLayoutPreference.stacked)
        ..setRatio(pair()!.pairId, SplitRatioAxis.stacked, 0.3);
      final before = pair()!;

      await controller().pair('a', 'c');
      final after = pair()!;
      expect((after.firstTabId, after.secondTabId), ('a', 'c'));
      expect(after.layout, SplitLayoutPreference.stacked);
      expect(after.stackedRatio, 0.3);
      expect(after.pairId, before.pairId);
    });

    test('a new partner is shown, not hidden by "only this page"', () async {
      await controller().pair('a', 'b');
      controller().setFocusedOnly(true);

      await controller().pair('a', 'c');

      expect(pair()!.secondTabId, 'c');
      expect(pair()!.focusedOnly, isFalse);
    });

    test('asking for the same two tabs shows both again', () async {
      await controller().pair('a', 'b');
      controller().setFocusedOnly(true);
      final before = pair()!;

      await controller().pair('b', 'a');

      expect(pair()!.focusedOnly, isFalse);
      expect(pair()!.pairId, before.pairId);
    });

    test('an invalid request does not cancel a valid one in flight', () async {
      final arrival = Completer<void>();
      tabStates.gates['b'] = arrival;

      final valid = controller().pair('a', 'b');
      await pumpEventQueue();
      await expectLater(
        controller().pair('c', 'c'),
        throwsA(isA<SplitViewError>()),
      );

      arrival.complete();
      await valid;
      expect((pair()!.firstTabId, pair()!.secondTabId), ('a', 'b'));
    });

    test('rejects the same tab twice', () async {
      await expectLater(
        controller().pair('a', 'a'),
        throwsA(
          isA<SplitViewError>().having(
            (e) => e.kind,
            'kind',
            SplitViewErrorKind.sameTab,
          ),
        ),
      );
    });

    test('rejects a missing tab', () async {
      await expectLater(
        controller().pair('a', 'gone'),
        throwsA(
          isA<SplitViewError>().having(
            (e) => e.kind,
            'kind',
            SplitViewErrorKind.missingTab,
          ),
        ),
      );
    });

    test('rejects private next to non-private, allows private pairs', () async {
      await expectLater(
        controller().pair('a', 'p'),
        throwsA(
          isA<SplitViewError>().having(
            (e) => e.kind,
            'kind',
            SplitViewErrorKind.mixedPrivacy,
          ),
        ),
      );
      await controller().pair('p', 'q');
      expect(pair(), isNotNull);
    });

    test('rejects a closed tab whose state is still retained', () async {
      // The source closed while the picker was open: its state still
      // answers, but its removal has already passed the reconciliation.
      tabStates.closed.add('a');
      await expectLater(
        controller().pair('a', 'b'),
        throwsA(
          isA<SplitViewError>().having(
            (e) => e.kind,
            'kind',
            SplitViewErrorKind.missingTab,
          ),
        ),
      );
      expect(pair(), isNull);
    });

    test('rejects a tab whose routing is not installed', () async {
      tabRepository.notReady.add('b');
      await expectLater(
        controller().pair('a', 'b'),
        throwsA(
          isA<SplitViewError>().having(
            (e) => e.kind,
            'kind',
            SplitViewErrorKind.routingNotReady,
          ),
        ),
      );
      expect(pair(), isNull);
    });

    test(
      'an older request that waited does not overwrite a newer one',
      () async {
        final arrival = Completer<void>();
        tabStates.gates['c'] = arrival;

        final older = controller().pair('a', 'c');
        await pumpEventQueue();
        await controller().pair('a', 'b');

        arrival.complete();
        await expectLater(
          older,
          throwsA(
            isA<SplitViewError>().having(
              (e) => e.kind,
              'kind',
              SplitViewErrorKind.superseded,
            ),
          ),
        );
        expect((pair()!.firstTabId, pair()!.secondTabId), ('a', 'b'));
      },
    );

    test('a request that waited does not bring back an ended split', () async {
      await controller().pair('a', 'b');
      final arrival = Completer<void>();
      tabStates.gates['c'] = arrival;

      final pending = controller().pair('a', 'c');
      await pumpEventQueue();
      controller().end();

      arrival.complete();
      await expectLater(pending, throwsA(isA<SplitViewError>()));
      expect(pair(), isNull);
    });

    test('returns only once native has the pair', () async {
      sync.gate = Completer<void>();
      var returned = false;
      final pairing = controller().pair('a', 'b').then((_) => returned = true);

      await pumpEventQueue();
      expect(pair(), isNotNull, reason: 'the state is set before the push');
      expect(returned, isFalse, reason: 'callers select only after this');

      sync.gate!.complete();
      await pairing;
      expect(returned, isTrue);
    });

    test(
      'an older request that fails after a newer one is superseded',
      () async {
        // 'c' never arrives in time: the older request would report a
        // missing tab, and its caller would then select 'c' on its own over
        // the newer pair.
        final arrival = Completer<void>();
        tabStates.gates['c'] = arrival;

        final older = controller().pair('a', 'c');
        await pumpEventQueue();
        await controller().pair('a', 'b');

        tabStates.closed.add('c');
        tabRepository.notReady.add('c');
        arrival.complete();
        await expectLater(
          older,
          throwsA(
            isA<SplitViewError>().having(
              (e) => e.kind,
              'kind',
              SplitViewErrorKind.superseded,
            ),
          ),
        );
        expect((pair()!.firstTabId, pair()!.secondTabId), ('a', 'b'));
      },
    );

    test('an end while native applies the pair supersedes it', () async {
      sync.gate = Completer<void>();
      final pending = controller().pair('a', 'b');
      await pumpEventQueue();

      controller().end();
      sync.gate!.complete();

      await expectLater(
        pending,
        throwsA(
          isA<SplitViewError>().having(
            (e) => e.kind,
            'kind',
            SplitViewErrorKind.superseded,
          ),
        ),
      );
      expect(pair(), isNull);
    });

    test('a pair native did not take is undone', () async {
      await controller().pair('a', 'b');
      final before = pair()!;
      sync.delivers = false;

      await expectLater(
        controller().pair('c', 'b'),
        throwsA(
          isA<SplitViewError>().having(
            (e) => e.kind,
            'kind',
            SplitViewErrorKind.notApplied,
          ),
        ),
      );
      expect(pair(), same(before));
    });
  });

  test(
    'pair() waits on the real native sync without a dependency cycle',
    () async {
      // The sync watches the controller, so the controller reading the sync
      // through its own ref threw CircularDependencyError on device (the
      // tests above use a sync that does not watch it).
      final service = _RecordingService();
      final real = ProviderContainer(
        overrides: [
          tabListProvider.overrideWith(() => _FakeTabList(['a', 'b'])),
          tabStatesProvider.overrideWith(
            () => _FakeTabStates({'a': _tab('a'), 'b': _tab('b')}),
          ),
          tabRepositoryProvider.overrideWith(_FakeTabRepository.new),
          selectedTabProvider.overrideWith(_FakeSelectedTab.new),
          splitViewServiceProvider.overrideWithValue(service),
          // Without the feature setting, which wants the settings database;
          // the sync still depends on the controller through it.
          splitPairShownProvider.overrideWith(
            (ref) => ref.watch(splitViewControllerProvider),
          ),
          engineReadyStateProvider.overrideWith(_EngineReady.new),
          splitKeyboardVisibleProvider.overrideWith(
            (ref) => Stream.value(false),
          ),
          splitTabIdentityProvider.overrideWith(
            (ref, tabId) => ModeSplitTabIdentity(null),
          ),
        ],
      );
      addTearDown(real.dispose);
      real.listen(splitViewNativeSyncProvider, (_, _) {});

      await real.read(splitViewControllerProvider.notifier).pair('a', 'b');

      // Returned once native had the pair.
      expect(service.pushed.last.pair?.firstTabId, 'a');
      expect(service.pushed.last.pair?.secondTabId, 'b');
    },
  );

  group('last pair per tab', () {
    test('is kept with its arrangement after the split ends', () async {
      await controller().pair('a', 'b');
      controller()
        ..setLayout(SplitLayoutPreference.stacked)
        ..setRatio(pair()!.pairId, SplitRatioAxis.stacked, 0.3)
        ..end();

      for (final tabId in ['a', 'b']) {
        final last = controller().lastPairOf(tabId);
        expect(last?.firstTabId, 'a');
        expect(last?.secondTabId, 'b');
        expect(last?.layout, SplitLayoutPreference.stacked);
        expect(last?.stackedRatio, 0.3);
      }
      expect(controller().lastPairOf('c'), isNull);
    });

    test(
      'follows the latest pair; the replaced partner keeps its own',
      () async {
        await controller().pair('a', 'b');
        await controller().pair('a', 'c');

        expect(controller().lastPairOf('a')?.secondTabId, 'c');
        expect(controller().lastPairOf('c')?.firstTabId, 'a');
        // 'b' was last shown beside 'a'.
        expect(controller().lastPairOf('b')?.partnerOf('b'), 'a');
      },
    );

    test('is dropped when the tab closes', () async {
      await controller().pair('a', 'b');
      controller().end();
      tabList.set(['b', 'c', 'p', 'q']);

      expect(controller().lastPairOf('a'), isNull);
      // Still there for the partner, which checks the tab is open on use.
      expect(controller().lastPairOf('b'), isNotNull);
    });

    test(
      'pairing with it restores the arrangement, both pages shown',
      () async {
        await controller().pair('a', 'b');
        controller()
          ..swap()
          ..setLayout(SplitLayoutPreference.sideBySide)
          ..setRatio(pair()!.pairId, SplitRatioAxis.sideBySide, 0.7)
          ..setFocusedOnly(true)
          ..end();
        final last = controller().lastPairOf('a')!;

        await controller().pair(
          last.firstTabId,
          last.secondTabId,
          arrangement: last,
        );

        final restored = pair()!;
        expect(restored.firstTabId, 'b');
        expect(restored.secondTabId, 'a');
        expect(restored.layout, SplitLayoutPreference.sideBySide);
        expect(restored.sideBySideRatio, 0.7);
        expect(restored.focusedOnly, isFalse);
        // A new pair: events for the old one stay stale.
        expect(restored.pairId, isNot(last.pairId));
      },
    );
  });

  test('ends when a member is closed', () async {
    await controller().pair('a', 'b');
    tabList.set(['a', 'c', 'p', 'q']);
    expect(pair(), isNull);
  });

  test('a ratio from a replaced pair is ignored', () async {
    await controller().pair('a', 'b');
    final stale = pair()!.pairId;
    await controller().pair('c', 'b');
    controller().setRatio(stale, SplitRatioAxis.sideBySide, 0.2);
    expect(pair()!.sideBySideRatio, 0.5);
  });

  group('a divider released at the edge', () {
    test('shows the kept page alone and keeps the ratios', () async {
      await controller().pair('a', 'b');
      controller().setRatio(pair()!.pairId, SplitRatioAxis.sideBySide, 0.3);

      expect(controller().collapseTo(pair()!.pairId, 'b'), isTrue);

      expect(pair()!.focusedOnly, isTrue);
      expect(pair()!.sideBySideRatio, 0.3);
    });

    test(
      'from a replaced pair, or naming another tab, changes nothing',
      () async {
        await controller().pair('a', 'b');
        final stale = pair()!.pairId;
        await controller().pair('c', 'b');

        expect(controller().collapseTo(stale, 'b'), isFalse);
        expect(controller().collapseTo(pair()!.pairId, 'a'), isFalse);

        expect(pair()!.focusedOnly, isFalse);
      },
    );

    test('showBothPages brings the other page back at its ratio', () async {
      await controller().pair('a', 'b');
      controller().setRatio(pair()!.pairId, SplitRatioAxis.sideBySide, 0.3);
      controller().collapseTo(pair()!.pairId, 'b');

      controller().showBothPages(pair()!.pairId);

      expect(pair()!.focusedOnly, isFalse);
      expect(pair()!.sideBySideRatio, 0.3);
    });

    test('showBothPages for a replaced pair changes nothing', () async {
      await controller().pair('a', 'b');
      final stale = pair()!.pairId;
      // Same tabs, new pair: replaced by forming it from scratch.
      controller().end();
      await controller().pair('a', 'b');
      controller().collapseTo(pair()!.pairId, 'a');

      controller().showBothPages(stale);

      expect(pair()!.focusedOnly, isTrue);
    });
  });

  test('swap exchanges slots and mirrors the ratios', () async {
    await controller().pair('a', 'b');
    controller().setRatio(pair()!.pairId, SplitRatioAxis.sideBySide, 0.3);
    controller().swap();
    expect((pair()!.firstTabId, pair()!.secondTabId), ('b', 'a'));
    expect(pair()!.sideBySideRatio, closeTo(0.7, 1e-9));
  });

  group('carryOver', () {
    // The old tab's removal reaches Dart some time after its close returns.
    for (final removal in ['at once', 'later in the replacement', 'after']) {
      test('remaps the slot when the removal arrives $removal', () async {
        await controller().pair('a', 'b');

        final newId = await controller().carryOver('a', () async {
          if (removal == 'at once') tabList.set(['b', 'c', 'p', 'q']);
          await pumpEventQueue();
          if (removal == 'later in the replacement') {
            tabList.set(['b', 'c', 'p', 'q']);
          }
          tabStates.add(_tab('a2'));
          return 'a2';
        });
        // The replacement reaches the list after the close's removal, which
        // in the last case only arrives now.
        if (removal == 'after') tabList.set(['b', 'c', 'p', 'q']);
        expect(pair(), isNotNull);
        tabList.set(['b', 'c', 'p', 'q', 'a2']);

        expect(newId, 'a2');
        expect(pair(), isNotNull);
        expect((pair()!.firstTabId, pair()!.secondTabId), ('a2', 'b'));
      });
    }

    test(
      'the removal arriving while the replacement settles is ignored',
      () async {
        await controller().pair('a', 'b');
        // The replacement's content state is late, so settling waits for it.
        final arrival = Completer<void>();
        tabStates.gates['a2'] = arrival;

        final carrying = controller().carryOver('a', () async => 'a2');
        await pumpEventQueue();
        tabList.set(['b', 'c', 'p', 'q']);
        expect(pair(), isNotNull);

        tabStates.add(_tab('a2'));
        arrival.complete();
        await carrying;

        expect((pair()!.firstTabId, pair()!.secondTabId), ('a2', 'b'));
      },
    );

    test(
      'a layout change while the replacement settles keeps the remap',
      () async {
        await controller().pair('a', 'b');
        final arrival = Completer<void>();
        tabStates.gates['a2'] = arrival;

        final carrying = controller().carryOver('a', () async => 'a2');
        await pumpEventQueue();
        tabList.set(['b', 'c', 'p', 'q']);
        controller().setLayout(SplitLayoutPreference.stacked);

        tabStates.add(_tab('a2'));
        arrival.complete();
        await carrying;

        expect((pair()!.firstTabId, pair()!.secondTabId), ('a2', 'b'));
        expect(pair()!.layout, SplitLayoutPreference.stacked);
      },
    );

    test('a replacement that closed while settling is not paired', () async {
      await controller().pair('a', 'b');
      final arrival = Completer<void>();
      tabStates.gates['a2'] = arrival;

      final carrying = controller().carryOver('a', () async => 'a2');
      await pumpEventQueue();
      // The old tab goes, then the replacement opens and closes again while
      // the privacy check waits; its state is retained.
      tabList.set(['b', 'c', 'p', 'q', 'a2']);
      tabList.set(['b', 'c', 'p', 'q']);
      tabStates
        ..add(_tab('a2'))
        ..closed.add('a2');
      arrival.complete();
      await carrying;

      expect(pair(), isNull);
    });

    test('a re-pair during the replacement wins', () async {
      await controller().pair('a', 'b');
      await controller().carryOver('a', () async {
        await controller().pair('c', 'b');
        tabStates.add(_tab('a2'));
        return 'a2';
      });
      expect((pair()!.firstTabId, pair()!.secondTabId), ('c', 'b'));
    });

    test('an end during the replacement wins', () async {
      await controller().pair('a', 'b');
      await controller().carryOver('a', () async {
        controller().end();
        tabStates.add(_tab('a2'));
        return 'a2';
      });
      expect(pair(), isNull);
    });

    test('a failed replacement ends the pair once the tab is gone', () async {
      await controller().pair('a', 'b');
      await expectLater(
        controller().carryOver('a', () {
          tabList.set(['b', 'c', 'p', 'q']);
          return Future.error(StateError('replace failed'));
        }),
        throwsStateError,
      );
      expect(pair(), isNull);
    });

    test('a tab outside the pair just runs the replacement', () async {
      await controller().pair('a', 'b');
      final id = await controller().carryOver('c', () async => 'c2');
      expect(id, 'c2');
      expect((pair()!.firstTabId, pair()!.secondTabId), ('a', 'b'));
    });
  });

  test('only the member that is not selected is unfocused', () async {
    await controller().pair('a', 'b');
    container.read(selectedTabProvider);
    selectedTab.set('a');

    expect(controller().isUnfocusedMember('b'), isTrue);
    expect(controller().isUnfocusedMember('a'), isFalse);
    expect(controller().isUnfocusedMember('c'), isFalse);
  });

  test(
    'a pair kept while split view is hidden has no unfocused member',
    () async {
      await controller().pair('a', 'b');
      container.read(selectedTabProvider);
      selectedTab.set('a');
      expect(controller().isUnfocusedMember('b'), isTrue);
      splitShown = false;
      container.invalidate(splitPairShownProvider);

      expect(controller().isUnfocusedMember('b'), isFalse);
    },
  );

  group('splitPartnerAfterClose', () {
    final pair = SplitPair(pairId: 'p', firstTabId: 'a', secondTabId: 'b');

    test('closing a member selects its partner', () {
      expect(
        splitPartnerAfterClose(
          pair: pair,
          closedTabId: 'a',
          excludedTabIds: const {'a'},
          openTabIds: const ['a', 'b', 'c'],
        ),
        'b',
      );
    });

    test('closing both members leaves the choice to the usual order', () {
      expect(
        splitPartnerAfterClose(
          pair: pair,
          closedTabId: 'a',
          excludedTabIds: const {'a', 'b'},
          openTabIds: const ['a', 'b', 'c'],
        ),
        isNull,
      );
    });

    test('a partner that is gone, or no pair, gives nothing', () {
      expect(
        splitPartnerAfterClose(
          pair: pair,
          closedTabId: 'a',
          excludedTabIds: const {'a'},
          openTabIds: const ['a', 'c'],
        ),
        isNull,
      );
      expect(
        splitPartnerAfterClose(
          pair: null,
          closedTabId: 'a',
          excludedTabIds: const {'a'},
          openTabIds: const ['a', 'b'],
        ),
        isNull,
      );
      expect(
        splitPartnerAfterClose(
          pair: pair,
          closedTabId: 'c',
          excludedTabIds: const {'c'},
          openTabIds: const ['a', 'b', 'c'],
        ),
        isNull,
      );
    });
  });
}
