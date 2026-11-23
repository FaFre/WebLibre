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

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/proxy_settings_replication.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/startup_browsing_data_cleanup.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/isolation_context.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_membership_gate.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/storage_owners.dart';
import 'package:weblibre/features/proxy/domain/services/container_routing_snapshot.dart';
import 'package:weblibre/features/proxy/domain/services/tab_routing.dart';
import 'package:weblibre/features/web_push/domain/providers.dart';

part 'web_notification_click.g.dart';

const _routeEquality = ListEquality<String>();

/// Delivers a tap on a web notification to Gecko (E12).
///
/// A tap starts in native (`NotificationActivity`), which decides whether the
/// process serves the notification's profile, parks the tap and brings
/// WebLibre to the front. This picks it up once the engine is up and whenever
/// WebLibre comes back to the front (the process may have been running, so no
/// start announces it), and hands it to Gecko only when the routing is ready
/// for the storage it came from: the click wakes the site's service worker in
/// that storage, whose network traffic must take that container's route and
/// never a direct one. Gecko then runs the site's `notificationclick`
/// handler, whose `clients.openWindow()` opens a tab in the same storage
/// through native's service worker delegate.
///
/// A storage a freeze restricts is asked about first ("Resume {container} and
/// open?", [ContainerFreezeService.resumeStorageToOpen]). Like a tab the user
/// opens, a tap waits for the startup cleanup of browsing data
/// ([StartupBrowsingDataCleanup]). A tap that is not delivered is released to
/// native, which keeps its notification showing, except for one whose
/// storage's data is being deleted or whose container was deleted; the user
/// is told why it did not open ([ContainerFreezeNotices]), and a tap that
/// fails is released all the same.
///
/// keepAlive and started from main.dart: a tap has to be answered whatever
/// screen is up.
@Riverpod(keepAlive: true)
class WebNotificationClickService extends _$WebNotificationClickService {
  var _running = false;
  var _again = false;

  GeckoPushService get _push => ref.read(pushServiceProvider);

  ContainerFreezeNotices get _notices =>
      ref.read(containerFreezeNoticesProvider.notifier);

  @override
  void build() {
    ref.listen(engineReadyStateProvider, (previous, ready) {
      if (ready) unawaited(deliverWaitingClicks());
    }, fireImmediately: true);

    final appLifecycle = AppLifecycleListener(
      onResume: () {
        if (ref.read(engineReadyStateProvider)) {
          unawaited(deliverWaitingClicks());
        }
      },
    );
    ref.onDispose(appLifecycle.dispose);
  }

  /// Takes every waiting tap, oldest first, and delivers each. A call while one
  /// is running makes it look again once it is done, so a tap that lands after
  /// the last take is not left until the next time WebLibre resumes.
  Future<void> deliverWaitingClicks() async {
    if (_running) {
      _again = true;
      return;
    }
    _running = true;
    try {
      do {
        _again = false;
        await _deliverAll();
      } while (_again);
    } finally {
      _running = false;
    }
  }

  Future<void> _deliverAll() async {
    while (true) {
      final NotificationClickHandoff? click;
      try {
        click = await _push.takeNotificationClick();
      } catch (error, stackTrace) {
        // Tried again the next time a tap is looked for.
        logger.e(
          'Could not take a web notification tap',
          error: error,
          stackTrace: stackTrace,
        );
        return;
      }
      if (click == null) return;

      try {
        await _deliver(click);
      } catch (error, stackTrace) {
        // One tap that fails does not hold back the ones behind it, and is
        // not left held by native: released, its notification stays, to be
        // tapped again.
        logger.e(
          'Could not deliver a web notification tap',
          error: error,
          stackTrace: stackTrace,
        );
        await _releaseAfterFailure(click);
      }
    }
  }

  Future<void> _deliver(NotificationClickHandoff click) async {
    // The default storage is never restricted by a freeze.
    final contextId = click.contextId;
    if (contextId != null) {
      final opening = await ref
          .read(containerFreezeServiceProvider.notifier)
          .resumeStorageToOpen(contextId);
      switch (opening) {
        case StorageOpening.open:
          break;
        case StorageOpening.declined || StorageOpening.waitsForRecovery:
          await _release(click, dismissNotification: false);
          return;
        case StorageOpening.dataBeingDeleted:
          // Nothing is left for the notification to open.
          await _release(click, dismissNotification: true);
          return;
      }
    }

    final routingContext = tabRoutingContextId(
      contextId: contextId,
      isPrivate: click.private,
    );
    final tabs = ref.read(tabRepositoryProvider.notifier);
    if (!await tabs.ensureRoutingReadyForContexts([routingContext])) {
      // Never delivered without a route: the worker would reach the network
      // some other way. The notification stays showing.
      await _refuse(click, _Refusal.routingNotReady);
      return;
    }

    // As for a tab the user opens: the startup cleanup deletes the previous
    // session's cookies and site data, which the woken worker would otherwise
    // still use, or lose what it writes now. A cold start's tap can come
    // before the browser screen starts the cleanup, and the wait only waits
    // for one that began.
    final cleanup = ref.read(startupBrowsingDataCleanupProvider.notifier);
    unawaited(cleanup.start());
    await cleanup.waitUntilDone();

    // Last, after every wait: the route Gecko enforces for the storage right
    // now is the one it has to take, read from the snapshot it acknowledged.
    // The readiness check above only said that the route Gecko held then
    // could carry traffic, and a direct one can, also in a snapshot older
    // than the routing Dart computes. Native then checks that the route can
    // carry traffic, with its own verdict.
    final storageRoute = await _storageRoute(click, routingContext);
    if (storageRoute == null) {
      await _refuse(click, _Refusal.containerDeleted);
      return;
    }
    final routing = ref.read(containerRoutingSnapshotProvider);
    if (routing == null) {
      await _refuse(click, _Refusal.routingNotComputed);
      return;
    }
    if (storageRoute.routeIn(routing) == null) {
      await _refuse(click, _Refusal.groupWithoutRoute);
      return;
    }
    final replication = ref.read(proxySettingsReplicationProvider.notifier);
    if (!await replication.waitUntilInstalled(
      (installed) => _enforces(installed, storageRoute),
      timeout: _routeInstallWait,
    )) {
      await _refuse(click, _Refusal.routeNotEnforced);
      return;
    }

    // Who owns the storage, and whether its group has tabs, can change while
    // the tap waits: a container deleted with its site data kept leaves the
    // storage on the general route, which the wait above then accepts. Read
    // again, after the generation the route was found in: what changes after
    // this read changes the routing, and native refuses a click for a
    // generation it no longer holds.
    final generation = _enforcedGeneration(storageRoute);
    final current = await _storageRoute(click, routingContext);
    if (current == null) {
      await _refuse(click, _Refusal.containerDeleted);
      return;
    }
    if (generation == null || _enforcedGeneration(current) != generation) {
      await _refuse(click, _Refusal.routingMovedOn);
      return;
    }

    await _handOver(click, generation);
  }

  /// Hands [click] to Gecko, for the routing [generation] its route was
  /// checked in, and handles native's answer.
  Future<void> _handOver(NotificationClickHandoff click, int generation) async {
    switch (await _push.deliverNotificationClick(
      click.clickId,
      routingGeneration: generation,
    )) {
      case NotificationClickOutcome.delivered:
        break;
      case NotificationClickOutcome.contextRestricted:
        // The registry says what Dart's copy of it did not: read again, so
        // that the next tap asks to resume.
        await ref.read(containerMembershipGateProvider.notifier).refresh();
        await _refuse(click, _Refusal.storageRestricted);
      case NotificationClickOutcome.routeUnavailable:
        await _refuse(click, _Refusal.routeUnavailable);
      case NotificationClickOutcome.routingChanged:
        await _refuse(click, _Refusal.routingChanged);
      case NotificationClickOutcome.superseded:
        logger.i(
          'Web notification tap not delivered: its notification was replaced '
          'or closed',
        );
      case NotificationClickOutcome.notFound:
        logger.w('Web notification tap not delivered: native lost it');
      case NotificationClickOutcome.engineUnavailable:
        logger.w('Web notification tap not delivered: no engine yet');
        await _release(click, dismissNotification: false);
    }
  }

  /// How long a tap waits for Gecko to enforce the route its storage has to
  /// take: about one push of the routing.
  static const _routeInstallWait = Duration(seconds: 5);

  /// Whether [installed], a snapshot Gecko acknowledged, routes the storage
  /// the way [storage] says it has to be routed by the routing Dart
  /// computes now, not by the one it computed when the tap started waiting: a
  /// change meanwhile (the user switched from direct to a proxy, say) would
  /// otherwise be met by the acknowledgement of the push it replaced.
  bool _enforces(ContainerRoutingSnapshot installed, _StorageRoute storage) {
    final current = ref.read(containerRoutingSnapshotProvider);
    final route = current == null ? null : storage.routeIn(current);
    return route != null &&
        _routeEquality.equals(
          effectiveRelationFor(installed, storage.routingContext),
          route,
        );
  }

  /// The generation of the snapshot Gecko acknowledged, while it routes
  /// [storage] as it has to be routed ([_enforces]); null otherwise.
  int? _enforcedGeneration(_StorageRoute storage) => ref
      .read(proxySettingsReplicationProvider.notifier)
      .installedGenerationIf((installed) => _enforces(installed, storage));

  /// What decides the route the storage of [click] has to take, whose
  /// routing context is [routingContext]: read once, and applied to every
  /// routing snapshot ([_StorageRoute.routeIn]). Null for the storage of a
  /// deleted container whose site data was kept: routing has no route of its
  /// own for it any more and sends it the general way, which is not the one
  /// its pages took.
  ///
  /// Routing derives an isolation group's route from its tabs, so a group
  /// with none left (a web app window keeps it) takes the general route; the
  /// containers of its last tabs are what it has to be checked against
  /// ([StorageOwners.lastContainersOf]). A private tap takes the private
  /// route, whatever its storage.
  Future<_StorageRoute?> _storageRoute(
    NotificationClickHandoff click,
    String routingContext,
  ) async {
    final owners = ref.read(storageOwnersProvider.notifier);
    final contextId = click.contextId;
    if (contextId == null || click.private) {
      return _StorageRoute(routingContext);
    }
    if (!isIsolatedContextId(contextId)) {
      return await owners.containerOwning(contextId) == null
          ? null
          : _StorageRoute(routingContext);
    }
    if (await owners.hasTabs(contextId)) return _StorageRoute(routingContext);
    return _StorageRoute.tablessGroup(
      routingContext,
      await owners.lastContainersOf(contextId),
    );
  }

  /// Ends [click] without delivering it because of [refusal], and tells the
  /// user why.
  Future<void> _refuse(NotificationClickHandoff click, _Refusal refusal) async {
    logger.w('Web notification tap not delivered: ${refusal.reason}');
    _notices.add(refusal.notice);
    await _release(click, dismissNotification: refusal.dismissesNotification);
  }

  /// Ends [click] without delivering it. Native keeps its notification
  /// showing unless [dismissNotification]; a click it has already lost needs
  /// nothing.
  Future<void> _release(
    NotificationClickHandoff click, {
    required bool dismissNotification,
  }) => _push.releaseNotificationClick(
    click.clickId,
    dismissNotification: dismissNotification,
  );

  /// [_release] of a tap whose delivery failed somewhere, the notification
  /// kept. A tap native already let go of (delivered, or released before the
  /// failure) needs nothing, and native says so by doing nothing.
  Future<void> _releaseAfterFailure(NotificationClickHandoff click) async {
    try {
      await _release(click, dismissNotification: false);
    } catch (error, stackTrace) {
      logger.e(
        'Could not release a web notification tap',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Why a tap was not delivered: logged with [reason], told to the user with
/// [notice], and released to native, which keeps its notification showing
/// unless [dismissesNotification].
enum _Refusal {
  routingNotReady(
    'no route is ready for its storage',
    notice: NotificationWaitsForRouting(),
  ),
  routingNotComputed(
    'the routing is not computed yet',
    notice: NotificationWaitsForRouting(),
  ),
  groupWithoutRoute(
    "its isolation group has no tab left and would not take its "
    "container's route",
    notice: NotificationGroupWithoutRoute(),
  ),
  routeNotEnforced(
    'Gecko does not enforce the route it has to take',
    notice: NotificationWaitsForRouting(),
  ),
  routingMovedOn(
    'Gecko does not enforce the route it has to take now',
    notice: NotificationWaitsForRouting(),
  ),

  /// Its storage's container was deleted with its site data kept: no
  /// container is left to route it, and none will be.
  containerDeleted(
    'its container was deleted',
    notice: NotificationContainerDeleted(),
    dismissesNotification: true,
  ),

  // Native's answers to the hand-over.
  storageRestricted(
    'its storage is restricted',
    notice: NotificationContainerFrozen(),
  ),
  routeUnavailable(
    'the route Gecko enforces for it cannot carry traffic',
    notice: NotificationWaitsForRouting(),
  ),
  routingChanged(
    'the routing changed after it was checked',
    notice: NotificationWaitsForRouting(),
  );

  const _Refusal(
    this.reason, {
    required this.notice,
    this.dismissesNotification = false,
  });

  final String reason;
  final ContainerFreezeNotice notice;
  final bool dismissesNotification;
}

/// How the route a tap's storage has to take follows from a routing
/// snapshot ([WebNotificationClickService._storageRoute]).
final class _StorageRoute {
  _StorageRoute(this.routingContext)
    : _groupWithoutTabs = false,
      _lastContainers = null;

  /// An isolation group with no tab left, whose route routing no longer
  /// derives from its container. [lastContainers] are the containers of its
  /// last tabs, null for tabs in none; null when they are not known.
  _StorageRoute.tablessGroup(
    this.routingContext,
    List<ContainerData?>? lastContainers,
  ) : _groupWithoutTabs = true,
      _lastContainers = lastContainers;

  final String routingContext;
  final bool _groupWithoutTabs;
  final List<ContainerData?>? _lastContainers;

  /// The proxies the storage has to take as [routing] says; null when it
  /// would take another, so its worker must not be woken.
  ///
  /// Only an isolation group with no tab and no relation of its own can be
  /// refused: it goes through only when the route of every one of its last
  /// containers is the route it takes now. When they differ, the route the
  /// group had while it had tabs is not the one it takes now. A group whose
  /// last containers are not known is refused.
  List<String>? routeIn(ContainerRoutingSnapshot routing) {
    final route = effectiveRelationFor(routing, routingContext);
    if (!_groupWithoutTabs || routing.relations.containsKey(routingContext)) {
      return route;
    }
    final containers = _lastContainers;
    if (containers == null) return null;
    final sameRoute = containers.every(
      (container) => _routeEquality.equals(
        effectiveRelationFor(
          routing,
          container?.metadata.contextualIdentity ?? generalContextId,
        ),
        route,
      ),
    );
    return sameRoute ? route : null;
  }
}
