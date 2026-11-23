/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:async';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab/isolation_context_cleanup.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/isolation_context.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_membership_gate.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'container_freeze.g.dart';

/// Container freeze on Dart's side (5.3, 5.5, 5.7 of
/// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): the only way a freeze
/// starts (D21), Resume with its routing check (D34), and the start-time
/// reconciliation that seeds the membership gate (5.5, 5.6).
///
/// Every freeze and Resume runs under the gate's operation reservation
/// ([ContainerMembershipGate.whileOperating]), so no membership change of the
/// container gets in while it runs, and the gate re-reads native's registry
/// afterwards.
///
/// keepAlive and started from main.dart: the placeholders' Resume buttons and
/// the reconciliation must work whatever screen is up.
@Riverpod(keepAlive: true)
class ContainerFreezeService extends _$ContainerFreezeService {
  var _startupReconciled = false;

  /// The screens that answer "Resume and open?", newest last, each with the
  /// requests it was handed and has not answered yet.
  final _answerers = <_ResumeAnswerer>[];

  GeckoTabLifecycleService get _lifecycle =>
      ref.read(geckoTabLifecycleServiceProvider);

  ContainerMembershipGate get _gate =>
      ref.read(containerMembershipGateProvider.notifier);

  /// Containers whose automatic freeze native refused, and until when their
  /// due events are let go (C2).
  final _automaticBackoff = <String, ({DateTime until, Duration delay})>{};

  /// Containers an automatic freeze is running for.
  final _freezingAutomatically = <String>{};

  @override
  void build() {
    final eventService = ref.watch(eventServiceProvider);
    final resumeRequests = eventService.resumeRequestEvents.listen((tabId) {
      unawaited(_resumeForPlaceholder(tabId));
    });
    ref.onDispose(resumeRequests.cancel);
    final dueContainers = eventService.containerFreezeDueEvents.listen((
      containerId,
    ) {
      unawaited(_freezeWhenDue(containerId));
    });
    ref.onDispose(dueContainers.cancel);

    ref.listen(engineReadyStateProvider, (previous, ready) {
      if (!ready) return;
      unawaited(reconcileAtStartup());
      unawaited(openFrozenWindowHandoff());
    }, fireImmediately: true);
    // Brought to the front by "Open WebLibre to resume" while it ran. Back
    // from a web app window, too, which may have closed meanwhile: nothing
    // reports that, and an isolation group it kept from being cleaned up is
    // cleaned up now.
    final appLifecycle = AppLifecycleListener(
      onResume: () {
        if (ref.read(engineReadyStateProvider)) {
          unawaited(openFrozenWindowHandoff());
          _retryIsolationCleanup();
        }
      },
    );
    ref.onDispose(appLifecycle.dispose);
  }

  /// "Open WebLibre to resume" in a web app or custom tab window whose
  /// storage is frozen (D18): the page the window held opens as the selected
  /// tab in that same storage, a container's or an isolation group's, under
  /// the container that owns its freeze. The freeze holds the new tab, so
  /// nothing loads: it shows the frozen placeholder, whose Resume goes to
  /// that container and checks routing for every context it lifts first
  /// (D34). Not a generic link launch, which follows the link-opening
  /// setting and knows only containers' storage, so the page could load
  /// unfrozen with other cookies and another route.
  ///
  /// A private window's page opens in a private tab, so it stays out of the
  /// restored session and the history. Private wins over an isolation group,
  /// which a tab cannot have as well (no window is opened as both).
  Future<void> openFrozenWindowHandoff() async {
    try {
      final handoff = await _lifecycle.takeFrozenWindowHandoff();
      if (handoff == null) return;
      final url = switch (handoff.url) {
        final url? => Uri.tryParse(url),
        null => null,
      };
      if (url == null) {
        logger.w('A frozen web app window handed over no page to open');
        return;
      }
      final contextId = handoff.contextId;
      final isolated = isIsolatedContextId(contextId);
      final container = await _containerOfStorage(
        contextId,
        isolated: isolated,
      );
      await ref
          .read(tabRepositoryProvider.notifier)
          .addTab(
            url: url,
            tabMode: switch ((handoff.private, isolated)) {
              (true, _) => TabMode.private,
              (false, true) => TabMode.isolated(contextId),
              (false, false) => TabMode.regular,
            },
            containerSelection: container == null
                ? const TabContainerSelection.unassigned()
                : TabContainerSelection.specific(container),
            selectTab: true,
          );
    } on ContainerRefusedTabException catch (refusal) {
      logger.w('Page of a frozen web app window not opened: $refusal');
      _notices.add(PageNotOpened(refusal));
    } catch (error, stackTrace) {
      logger.e(
        'Could not open the page of a frozen web app window',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// The container a page of storage [contextId] opens under: the one whose
  /// freeze holds that storage, else the container it belongs to (its own,
  /// or for an [isolated] group the one of its tabs). Null when none does.
  Future<ContainerData?> _containerOfStorage(
    String contextId, {
    required bool isolated,
  }) async {
    await _gate.seed();
    if (_gate.contextRecord(contextId)?.ownerId case final ownerId?) {
      return await _containerData(ownerId);
    }
    final db = ref.read(tabDatabaseProvider);
    if (!isolated) {
      return await db.containerDao
          .getContainerByContextualIdentity(contextId)
          .getSingleOrNull();
    }
    final pairs = await db.tabDao.isolatedContextContainerPairs().get();
    final containerId = pairs
        .firstWhereOrNull((pair) => pair.isolationContextId == contextId)
        ?.containerId;
    return containerId == null ? null : await _containerData(containerId);
  }

  /// Once per process, when the engine is up: in normal mode, matches native's
  /// records against the containers in tab.db (owner reconciliation, 5.5); in
  /// recovery mode, reconstructs a frozen record for every container with its
  /// own context (5.6). The gate adopts the snapshot native returns. What the
  /// user should hear about goes to [ContainerFreezeNotices].
  Future<void> reconcileAtStartup() async {
    if (_startupReconciled) return;
    _startupReconciled = true;
    var recovering = false;
    try {
      await _gate.seed();
      // Which of the two is owed is native's mode, and without a read it is
      // not known: native answers a reconciliation it skips in recovery with
      // a snapshot that looks settled.
      if (!_gate.hasRegistrySnapshot()) {
        throw StateError('The container freeze registry could not be read');
      }
      recovering = _gate.isInRecovery();
      final db = ref.read(tabDatabaseProvider);
      final containers = await db.containerDao.allContainers().get();
      if (recovering) {
        _recovery.set(FreezeRecoveryStatus.restoring);
        final owners = <ContainerContexts>[];
        final claimed = <String>{};
        for (final container in containers) {
          final identity = container.metadata.contextualIdentity;
          if (identity == null) continue;
          // Native keeps one owner per context. An isolation group shared
          // with another container goes to the first that claims it; Resume
          // of that one waits for the other ([ResumeSharedWithFrozen]).
          final contexts = [
            for (final contextId in [
              identity,
              ...await db.tabDao.isolationContextIdsInContainer(container.id),
            ])
              if (claimed.add(contextId)) contextId,
          ];
          owners.add(
            ContainerContexts(ownerId: container.id, contextIds: contexts),
          );
        }
        final allIsolation =
            (await db.tabDao.allIsolationContextIds().get()).nonNulls;
        final unfreezable = [
          for (final contextId in allIsolation)
            if (!claimed.contains(contextId)) contextId,
        ];
        _gate.adoptStartupSnapshot(
          await _lifecycle.reconstructFrozenContexts(
            owners: owners,
            unfreezableContextIds: unfreezable,
          ),
        );
        if (_gate.isInRecovery()) {
          // Native kept the wildcard: an engine call was not acknowledged.
          _startupReconciled = false;
          _failRecovery();
          return;
        }
        _recovery.set(FreezeRecoveryStatus.none);
        _retryIsolationCleanup();
        if (owners.isNotEmpty) {
          _notices.add(ContainersFrozenToBeSafe(owners.length));
        }
      } else {
        // A deletion whose row is still there was interrupted before it
        // removed anything; the reconciliation puts its phase back (5.5).
        // Not one running right now (deleted while this starts up), which
        // native leaves to itself.
        final existing = {for (final container in containers) container.id};
        final interrupted = _gate
            .ownersInPhase(ContextFreezePhase.deletionPending)
            .where((id) => existing.contains(id) && !_gate.isBeingDeleted(id))
            .toList();
        _gate.adoptStartupSnapshot(
          await _lifecycle.reconcileOwners(existing.toList()),
        );
        if (interrupted.isNotEmpty) {
          _notices.add(ContainerDeletionNotFinished(interrupted));
        }
      }
    } catch (error, stackTrace) {
      // Retried at the next engine start; until then native keeps every
      // record enforced, which is safe.
      _startupReconciled = false;
      if (recovering) {
        _failRecovery();
      } else if (!_gate.hasRegistrySnapshot()) {
        // Native may be in recovery. Once a read shows it, the recovery
        // section offers Retry rather than "Restoring…" for good.
        _recovery.set(FreezeRecoveryStatus.failed);
      }
      logger.e(
        'Could not reconcile frozen containers at startup',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// "Try again" after restoring the frozen containers did not finish: runs
  /// the reconstruction again now rather than at the next start.
  Future<void> retryRecovery() async {
    if (_startupReconciled) return;
    await reconcileAtStartup();
  }

  void _failRecovery() {
    _recovery.set(FreezeRecoveryStatus.failed);
    _notices.add(const FreezeRecoveryFailed());
  }

  ContainerFreezeNotices get _notices =>
      ref.read(containerFreezeNoticesProvider.notifier);

  FreezeRecoveryProgress get _recovery =>
      ref.read(freezeRecoveryProgressProvider.notifier);

  /// Freezes [containerId] (5.3). Media and a POST result refuse unless
  /// confirmed with [stopMedia] and [discardPostResult], form input unless its
  /// tab is in [discardFormDataTabIds]; a refusal for them alone is the
  /// caller's cue to ask and try again.
  Future<ContainerFreezeOutcome> freeze(
    String containerId, {
    bool stopMedia = false,
    bool discardPostResult = false,
    List<String> discardFormDataTabIds = const [],
  }) => _freeze(
    containerId,
    stopMedia: stopMedia,
    discardPostResult: discardPostResult,
    discardFormDataTabIds: discardFormDataTabIds,
    automatic: false,
  );

  /// Freezes [containerId] because native found it due (phase C2, 5.9): the
  /// same gated preflight as [freeze], with `automatic`, so nothing is asked
  /// and native defers on any blocker, on any use of the container, and on a
  /// container that is already restricted.
  Future<ContainerFreezeOutcome> freezeAutomatically(String containerId) =>
      _freeze(
        containerId,
        stopMedia: false,
        discardPostResult: false,
        discardFormDataTabIds: const [],
        automatic: true,
      );

  /// A due event (C2): one automatic freeze per container at a time, none
  /// while its backoff runs. Nothing is shown to the user: the container's
  /// frozen glyph is the result, and a refusal waits for the next due event.
  Future<void> _freezeWhenDue(String containerId) async {
    final backoff = _automaticBackoff[containerId];
    if (backoff != null && clock.now().isBefore(backoff.until)) return;
    if (!_freezingAutomatically.add(containerId)) return;
    try {
      final outcome = await freezeAutomatically(containerId);
      switch (outcome) {
        case FreezeAttempted(frozen: true):
          _automaticBackoff.remove(containerId);
        case FreezeAttempted(:final result):
          switch (result.failure) {
            // Used again, or taken over: native finds it due again only
            // after a full period unused.
            case LifecycleFailure.noLongerEligible ||
                LifecycleFailure.superseded ||
                null:
              _automaticBackoff.remove(containerId);
            case final failure:
              _deferAutomatic(containerId, backoff, failure);
          }
        // Native cannot see why (shared storage, say) and reports it due
        // again every minute until it is used.
        case FreezeUnavailable(:final reason):
          _deferAutomatic(containerId, backoff, reason);
        case FreezeBusy():
          break;
      }
    } catch (error, stackTrace) {
      logger.w(
        'Automatic freeze of $containerId failed',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _freezingAutomatically.remove(containerId);
    }
  }

  void _deferAutomatic(
    String containerId,
    ({DateTime until, Duration delay})? backoff,
    Object why,
  ) {
    final delay = backoff == null
        ? _firstAutomaticBackoff
        : _doubled(backoff.delay);
    _automaticBackoff[containerId] = (
      until: clock.now().add(delay),
      delay: delay,
    );
    logger.i(
      'Automatic freeze of $containerId deferred ($why); '
      'next try in ${delay.inMinutes} min',
    );
  }

  static const _firstAutomaticBackoff = Duration(minutes: 5);
  static const _maxAutomaticBackoff = Duration(minutes: 60);

  static Duration _doubled(Duration delay) {
    final doubled = delay * 2;
    return doubled > _maxAutomaticBackoff ? _maxAutomaticBackoff : doubled;
  }

  Future<ContainerData?> _containerData(String containerId) => ref
      .read(tabDatabaseProvider)
      .containerDao
      .getContainerData(containerId)
      .getSingleOrNull();

  /// Why [container] cannot be frozen now, before anything is asked of the
  /// gate or native; null when nothing stands in the way. [container] null:
  /// deleted.
  ContainerFreezeOutcome? _unfreezable(
    ContainerData? container, {
    required bool automatic,
  }) {
    if (container == null) {
      return FreezeUnavailable(FreezeUnavailability.missing);
    }
    if (automatic) {
      final shown = ref
          .read(generalSettingsWithDefaultsProvider)
          .isFeatureShown(FeatureId.containerFreeze);
      if (!shown || container.metadata.autoFreezeAfterMinutes == null) {
        return FreezeUnavailable(FreezeUnavailability.notScheduled);
      }
    }
    if (container.metadata.contextualIdentity == null) {
      return FreezeUnavailable(FreezeUnavailability.needsOwnStorage);
    }
    return null;
  }

  Future<ContainerFreezeOutcome> _freeze(
    String containerId, {
    required bool stopMedia,
    required bool discardPostResult,
    required List<String> discardFormDataTabIds,
    required bool automatic,
  }) async {
    if (_unfreezable(await _containerData(containerId), automatic: automatic)
        case final unavailable?) {
      return unavailable;
    }
    await _gate.seed();
    if (_gate.isInRecovery()) {
      return FreezeUnavailable(FreezeUnavailability.recoveryPending);
    }

    final outcome = await _gate.whileOperating<ContainerFreezeOutcome>(
      containerId,
      () async {
        // Read again under the reservation, which no deletion gets past: one
        // that finished before it would have left nothing to refuse, and a
        // freeze of the row it took would restrict storage of an owner that
        // no longer exists, which no Resume could reach.
        final container = await _containerData(containerId);
        if (_unfreezable(container, automatic: automatic)
            case final unavailable?) {
          return unavailable;
        }
        final identity = container!.metadata.contextualIdentity!;
        final current = await contextsOf(containerId, identity);
        if (current == null) {
          return FreezeUnavailable(FreezeUnavailability.sharedStorage);
        }
        // An isolation group whose last tab closed after an incomplete
        // freeze stays restricted for the container until Resume (D32). A
        // retry covers it too: its phase would otherwise keep the container
        // from ever reading frozen.
        final contexts = {
          ...current,
          ..._gate.contextsHolding(containerId),
        }.toList();
        final members = await _membersOf(containerId, contexts);
        return FreezeAttempted(
          await _lifecycle.freezeContexts(
            ownerId: containerId,
            contextIds: contexts,
            memberTabIds: members,
            stopMedia: stopMedia,
            discardPostResult: discardPostResult,
            discardFormDataTabIds: discardFormDataTabIds,
            automatic: automatic,
          ),
        );
      },
    );
    if (outcome == null) return const FreezeBusy();
    _retryIsolationCleanup();
    return outcome;
  }

  /// The contexts a freeze of [containerId] restricts: its own ([identity])
  /// and those of its isolated tabs. Null when an isolated tab of it shares
  /// its storage with a tab outside it (step 2 of 5.3).
  Future<List<String>?> contextsOf(String containerId, String identity) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;
    final (isolation, onlyHere) = await (
      tabDao.isolationContextIdsInContainer(containerId),
      tabDao.isolationContextIdsOnlyInContainer(containerId),
    ).wait;
    if (isolation.any((contextId) => !onlyHere.contains(contextId))) {
      return null;
    }
    return [identity, ...isolation];
  }

  /// The tabs Dart counts in [containerId]: its rows, and the open tabs that
  /// run in its [contexts] before their rows are written (a window one of its
  /// pages opened a moment ago, filed into it once its event arrives). Native
  /// refuses the freeze for any other tab in the contexts (barrier 1).
  Future<List<String>> _membersOf(
    String containerId,
    List<String> contexts,
  ) async {
    final rows = await ref
        .read(tabDatabaseProvider)
        .containerDao
        .getContainerTabIds(containerId)
        .get();
    final states = ref.read(tabStatesProvider);
    return {
      ...rows,
      for (final entry in states.entries)
        if (contexts.contains(entry.value.contextId)) entry.key,
    }.toList();
  }

  /// Resumes [containerId] (5.5), and wakes [wakeTabId] with it. Every
  /// context's routing is checked first, and nothing reaches native while
  /// one is not ready (D34). Runs beside a freeze of the same container,
  /// which it stops ("Stop freezing and resume").
  Future<ContainerResumeOutcome> resume(
    String containerId, {
    String? wakeTabId,
  }) async {
    await _gate.seed();
    if (_gate.isInRecovery()) return const ResumeRecoveryPending();

    final outcome = await _gate.whileOperating(containerId, () async {
      // Without native's registry, what the lift lets run is not known: an
      // isolation group without a tab that native holds for the container
      // (a web app window still uses it) would be lifted unchecked.
      if (!_gate.hasRegistrySnapshot()) return const ResumeFreezeStateUnknown();
      final db = ref.read(tabDatabaseProvider);
      final container = await db.containerDao
          .getContainerData(containerId)
          .getSingleOrNull();
      final identity = container?.metadata.contextualIdentity;
      final held = _gate.contextsHolding(containerId).toSet();
      // Lifting storage a tab of another frozen container runs in would run
      // that tab too.
      final pairs = await db.tabDao.isolatedContextContainerPairs().get();
      if (pairs.any(
        (pair) =>
            held.contains(pair.isolationContextId) &&
            pair.containerId != containerId &&
            _gate.isRestricted(pair.containerId),
      )) {
        return const ResumeSharedWithFrozen();
      }
      final isolation = await db.tabDao.isolationContextIdsInContainer(
        containerId,
      );
      // Its isolation contexts as native records them include groups whose
      // last tab closed while it was frozen, kept restricted until now. They
      // are released first, while their records still restrict them (D32);
      // a group with a tab is left alone by the release. Not one a running
      // freeze or Resume is still writing.
      final settled = [
        for (final contextId in held)
          if (contextId != identity &&
              settledFreezePhases.contains(
                _gate.contextRecord(contextId)?.phase,
              ))
            contextId,
      ];
      // Every context the lift lets run (D34): the ones native holds for it,
      // routed as the installed routing resolves each. A group about to be
      // released runs nothing and is checked only if it is kept (below). One
      // an earlier Resume lifted already runs: waited for, a proxy it no
      // longer needs would keep the rest frozen. While a freeze of it runs
      // (this Resume stops it), its own and its tabs' groups count too: the
      // snapshot may not show that freeze's records yet.
      final freezing = _gate.operationsOn(containerId) > 1;
      final routingChecked = {
        if (freezing) ...{?identity, ...isolation},
        ...held.where((contextId) => !settled.contains(contextId)),
      };
      final tabs = ref.read(tabRepositoryProvider.notifier);
      if (!await tabs.ensureRoutingReadyForContexts(routingChecked)) {
        return const ResumeRoutingNotReady();
      }
      if (settled.isNotEmpty) {
        // Not beside an undo close, which could bring a group's last tab
        // back while its data is deleted ([ContainerMembershipGate.whileReleasing]).
        // One whose release could not even start keeps its frozen phase,
        // which the lift would take with the container: stopped here
        // instead.
        final released = await _gate.whileReleasing(
          () => ref
              .read(isolationContextCleanupProvider.notifier)
              .releaseEmpty(settled),
        );
        if (released == null) return const ResumeBusy();
        if (!released) return const ResumeIsolationCleanupFailed();
        // One a web app window still uses was kept, and is lifted with the
        // container: its route is checked before that, though the empty
        // groups beside it are released already, which runs nothing.
        await _gate.refresh();
        final kept = [
          for (final contextId in _gate.contextsHolding(containerId))
            if (!routingChecked.contains(contextId)) contextId,
        ];
        if (kept.isNotEmpty &&
            !await tabs.ensureRoutingReadyForContexts(kept)) {
          return const ResumeRoutingNotReady();
        }
      }
      final result = await _lifecycle.resumeContexts(
        containerId,
        wakeTabId: wakeTabId,
      );
      final attempted = ResumeAttempted(result);
      if (attempted.resumed) return attempted;
      return ResumeAttempted(
        result,
        enforcement: await _enforcementOf(containerId),
      );
    }, concurrentWithOthers: true);
    if (outcome == null) return const ResumeBusy();
    _retryIsolationCleanup();
    return outcome;
  }

  /// Isolation groups whose last tab closed while a freeze or Resume ran, or
  /// before the frozen containers were restored, are cleaned up now that
  /// it is over.
  void _retryIsolationCleanup() => unawaited(
    ref
        .read(isolationContextCleanupProvider.notifier)
        .drain()
        .catchError(
          (Object error, StackTrace stackTrace) => logger.e(
            'Could not clean up isolation contexts',
            error: error,
            stackTrace: stackTrace,
          ),
        ),
  );

  /// What the engine last acknowledged for [containerId], for a message only.
  Future<EngineEnforcement?> _enforcementOf(String containerId) async {
    try {
      final snapshot = await _lifecycle.lifecycleSnapshot();
      return ContainerFreezeView.fromSnapshot(
        snapshot,
      )[containerId]?.enforcement;
    } catch (error, stackTrace) {
      logger.w(
        'Could not read the registry after resuming $containerId',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// The containers to resume for [tabId] to run, in the order they can be
  /// resumed. The last is the one whose freeze holds the tab's storage, as
  /// its placeholder names it: the owner of its context's record, or else
  /// its own container. They differ after a damaged registry, which
  /// restores an isolation group two containers share under one of them
  /// only (5.6). Its own container then comes first while it is restricted
  /// too: until then the owner's Resume is refused ([ResumeSharedWithFrozen]).
  /// Empty when neither is known.
  Future<List<String>> _containersHolding(String tabId) async {
    final containerId = await ref
        .read(tabDatabaseProvider)
        .tabDao
        .getTabContainerId(tabId)
        .getSingleOrNull();
    final contextId = ref.read(tabStatesProvider)[tabId]?.contextId;
    await _gate.seed();
    final owner = contextId == null
        ? null
        : _gate.contextRecord(contextId)?.ownerId;
    if (owner == null || owner == containerId) return [?containerId];
    return [
      if (containerId != null && _gate.isRestricted(containerId)) containerId,
      owner,
    ];
  }

  /// Resumes what holds [tabId] ([_containersHolding]) in turn, and wakes it
  /// with the last. Stops at the first that did not resume, and returns it
  /// with its outcome; null when there was nothing to resume.
  Future<(String, ContainerResumeOutcome)?> _resumeHolding(String tabId) async {
    final containers = await _containersHolding(tabId);
    (String, ContainerResumeOutcome)? last;
    for (final (index, containerId) in containers.indexed) {
      final outcome = await resume(
        containerId,
        wakeTabId: index == containers.length - 1 ? tabId : null,
      );
      last = (containerId, outcome);
      if (outcome is! ResumeAttempted || !outcome.resumed) break;
    }
    return last;
  }

  /// "Resume and open" answered with Resume for [request]: for a tab, what
  /// holds it is resumed, as its placeholder's Resume does, and the tab
  /// woken; for a page that opens in a new tab, its container. The outcome
  /// of the first container that did not resume, or of the last.
  Future<ContainerResumeOutcome> resumeRequested(
    ResumeAndOpenRequest request,
  ) async {
    final tabId = request.tabId;
    if (tabId != null) {
      if (await _resumeHolding(tabId) case (_, final outcome)?) {
        return outcome;
      }
    }
    return await resume(request.containerId, wakeTabId: tabId);
  }

  /// Before a navigation the user asked for in [tabId] while its storage is
  /// frozen (5.2.1): the engine would drop it, so the user is asked whether
  /// to resume the container that holds it first, through the screen that
  /// answers ([answerResumeAndOpenWith]), which resumes it on yes
  /// ([resumeRequested]). True when it was resumed and the navigation may run
  /// once; false when it stays frozen (cancelled, no screen to ask on, the
  /// screen went away, or the Resume did not finish).
  ///
  /// A tab that no container holds has none to resume: its storage is
  /// restricted because every storage is until the frozen containers are
  /// restored (5.6), which the user is told, or because its record only
  /// waits for the storage's data to be deleted.
  Future<bool> resumeForNavigation(String tabId) async {
    final containerId = (await _containersHolding(tabId)).lastOrNull;
    if (containerId == null) {
      logger.w(
        'Navigation in $tabId not run: its storage is restricted, with no '
        'container to resume',
      );
      await _gate.seed();
      if (_gate.isInRecovery()) {
        _notices.add(const NavigationWaitsForRecovery());
      }
      return false;
    }
    return await _askToResume(
      ResumeAndOpenRequest(containerId: containerId, tabId: tabId),
    );
  }

  /// Before opening a page in [containerId] that its freeze would refuse (a
  /// site assigned to it, reached from an isolated tab or a tab that moves):
  /// asks "Resume {container} and open?" as [resumeForNavigation] does. True
  /// when it was resumed, and the page may open.
  Future<bool> resumeToOpen(String containerId) =>
      _askToResume(ResumeAndOpenRequest(containerId: containerId));

  /// Makes [answer] the one that answers "Resume and open?" requests, until
  /// the returned function is called: the newest of the screens that called
  /// this, so a request is asked once. Requests it was handed and has not
  /// answered by then are dropped, as if cancelled.
  void Function() answerResumeAndOpenWith(
    void Function(ResumeAndOpenRequest request) answer,
  ) {
    final answerer = _ResumeAnswerer(answer);
    _answerers.add(answerer);
    return () {
      _answerers.remove(answerer);
      for (final request in [...answerer.pending]) {
        request.complete(resumed: false);
      }
    };
  }

  Future<bool> _askToResume(ResumeAndOpenRequest request) async {
    final answerer = _answerers.lastOrNull;
    if (answerer == null) {
      logger.w(
        'Page for frozen container ${request.containerId} dropped: no screen '
        'to ask on',
      );
      return false;
    }
    answerer.pending.add(request);
    try {
      answerer.answer(request);
      return await request.answered;
    } finally {
      answerer.pending.remove(request);
    }
  }

  /// "Delete data" in the list of site data waiting to be deleted: runs the
  /// release procedure (D32) for [contextIds] now. Returns whether every one
  /// was released; those that were not stay listed and are retried at the
  /// next start.
  Future<bool> releasePendingSiteData(List<String> contextIds) async {
    try {
      final results = await _lifecycle.releaseContexts(contextIds);
      return results.length == contextIds.length &&
          results.every((result) => result.released);
    } catch (error, stackTrace) {
      logger.e(
        'Could not release site data waiting to be deleted',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Resume pressed on a frozen tab's placeholder: what holds the tab is
  /// resumed ([_containersHolding]), and the tab woken with it.
  Future<void> _resumeForPlaceholder(String tabId) async {
    try {
      final resumed = await _resumeHolding(tabId);
      if (resumed == null) {
        logger.w('Resume requested for tab $tabId, which nothing holds');
        return;
      }
      final (containerId, outcome) = resumed;
      if (outcome is! ResumeAttempted || !outcome.resumed) {
        logger.w('Resume of container $containerId from tab $tabId: $outcome');
        _notices.add(ResumeNotFinished(containerId, outcome));
      }
    } catch (error, stackTrace) {
      logger.e(
        'Could not resume what holds tab $tabId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

/// A screen that answers "Resume and open?" requests, with the ones it was
/// handed and has not answered.
final class _ResumeAnswerer {
  final void Function(ResumeAndOpenRequest request) answer;
  final pending = <ResumeAndOpenRequest>{};

  _ResumeAnswerer(this.answer);
}
