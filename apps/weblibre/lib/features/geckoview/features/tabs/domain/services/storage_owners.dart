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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/isolation_context.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_membership_gate.dart';

part 'storage_owners.g.dart';

/// Which container a storage (session context) belongs to, for a page that
/// opens in it with nothing else to say: the page a notification's service
/// worker opens, or the page of a frozen web app window.
@Riverpod(keepAlive: true)
class StorageOwners extends _$StorageOwners {
  /// The containers of each isolation group's last tabs, remembered when they
  /// went ([rememberDeletedTabs], [rememberLifted]); null for tabs in none.
  /// In memory: it is only needed while a web app window keeps a group with
  /// no tab, which a restart ends, and a group goes once its data is deleted
  /// ([forget]).
  final _lastContainers = <String, Set<String?>>{};

  @override
  void build() {}

  /// Remembers the containers of the tab rows just deleted for each isolation
  /// group in [groupContainers] (null for rows in none). Read only once the
  /// group has no tab left: routing then knows its containers no more, and a
  /// page its worker opens (a notification's) would be filed under none.
  void rememberDeletedTabs(Map<String, Set<String?>> groupContainers) {
    _lastContainers.addAll(groupContainers);
  }

  /// Remembers [containerId] as the owner of isolation groups [contextIds],
  /// which its Resume lifts while no tab uses them (a web app window kept
  /// them), unless the containers of their last tabs are known: their
  /// records named it until the lift, and nothing else does after it, also
  /// after a restart since their tabs closed.
  void rememberLifted(Iterable<String> contextIds, String containerId) {
    for (final contextId in contextIds) {
      _lastContainers.putIfAbsent(contextId, () => {containerId});
    }
  }

  /// Drops what is remembered of isolation group [contextId], whose data was
  /// deleted or is being deleted: no page opens in it any more.
  void forget(String contextId) {
    _lastContainers.remove(contextId);
  }

  /// The container that owns storage [contextId]: the one whose freeze holds
  /// it (the owner of its record in native's registry), else the one it
  /// belongs to, which is the container with that cookie store, or for an
  /// isolation group a container of its tabs, or with none left of its last
  /// tabs ([rememberDeletedTabs], [rememberLifted]).
  ///
  /// The registry comes first: it still names the container of an isolation
  /// group whose last tab closed while the container was frozen. Null when
  /// none does: the default storage, a context no container uses, a storage
  /// whose container was deleted and that only waits for its data to be
  /// deleted, and an isolation group whose tabs are in no container or whose
  /// containers are not known (its last tabs closed before this process
  /// started).
  ///
  /// A group with tabs goes by them alone, as its routing does: when none of
  /// them is in a container, what its last closed tab was in is not where it
  /// is now, and a page filed there would change the route of the whole
  /// group.
  Future<ContainerData?> containerOwning(String contextId) async {
    if (await _registryOwner(contextId) case final ownerId?) {
      return await _container(ownerId);
    }
    final db = ref.read(tabDatabaseProvider);
    if (!isIsolatedContextId(contextId)) {
      return await db.containerDao
          .getContainerByContextualIdentity(contextId)
          .getSingleOrNull();
    }
    final tabContainers = await db.tabDao.containerIdsInIsolationGroup(
      contextId,
    );
    final containerId = tabContainers.isNotEmpty
        ? tabContainers.nonNulls.firstOrNull
        : _lastContainers[contextId]?.nonNulls.firstOrNull;
    return containerId == null ? null : await _container(containerId);
  }

  /// Whether isolation group [contextId] has tabs, from which routing derives
  /// its route.
  Future<bool> hasTabs(String contextId) async =>
      await ref
          .read(tabDatabaseProvider)
          .tabDao
          .tabsInIsolationGroup(contextId)
          .getSingle() >
      0;

  /// The containers of the last tabs of isolation group [contextId], which
  /// has none left: remembered when they went, null for tabs in no container;
  /// else the container whose freeze holds it. Null when they are not known,
  /// also when one of them was deleted since.
  Future<List<ContainerData?>?> lastContainersOf(String contextId) async {
    var containerIds = _lastContainers[contextId];
    if (containerIds == null) {
      final ownerId = await _registryOwner(contextId);
      if (ownerId == null) return null;
      containerIds = {ownerId};
    }
    final containers = <ContainerData?>[];
    for (final containerId in containerIds) {
      if (containerId == null) {
        containers.add(null);
        continue;
      }
      final container = await _container(containerId);
      if (container == null) return null;
      containers.add(container);
    }
    return containers;
  }

  /// The container whose freeze holds storage [contextId]: the owner of its
  /// record in native's registry.
  Future<String?> _registryOwner(String contextId) async {
    final gate = ref.read(containerMembershipGateProvider.notifier);
    await gate.seed();
    return gate.contextRecord(contextId)?.ownerId;
  }

  Future<ContainerData?> _container(String containerId) => ref
      .read(tabDatabaseProvider)
      .containerDao
      .getContainerData(containerId)
      .getSingleOrNull();
}
