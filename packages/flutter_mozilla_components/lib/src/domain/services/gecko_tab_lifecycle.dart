/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoTabLifecycleApi();

/// Tab sleep and container freeze as native enforces them. See
/// [GeckoTabLifecycleApi] for what each call promises.
class GeckoTabLifecycleService {
  final GeckoTabLifecycleApi _api;

  GeckoTabLifecycleService({GeckoTabLifecycleApi? api})
    : _api = api ?? _apiInstance;

  /// Puts [tabIds] to sleep. Playing media and a POST result refuse unless
  /// confirmed with [stopMedia] and [discardPostResult]; form input unless
  /// its tab is in [discardFormDataTabIds].
  Future<List<TabSleepResult>> sleepTabs(
    List<String> tabIds, {
    bool stopMedia = false,
    bool discardPostResult = false,
    List<String> discardFormDataTabIds = const [],
  }) {
    if (tabIds.isEmpty) return Future.value(const []);
    return _api.sleepTabs(
      tabIds,
      stopMedia,
      discardPostResult,
      discardFormDataTabIds,
    );
  }

  /// Clears [tabId]'s sleep hold while the installed routing covers its
  /// context (D34). Returns whether it was woken. Wait for routing to be
  /// installed first.
  Future<bool> wakeTab(String tabId) => _api.wakeTab(tabId);

  /// [tabId]'s lifecycle as native has it now, ahead of the event that
  /// reports it; null for a tab that is not open.
  Future<TabLifecycleState?> tabLifecycleState(String tabId) =>
      _api.getTabLifecycleState(tabId);

  /// Replaces the automatic sleep policy (process-wide in native).
  Future<void> setSleepPolicy(TabSleepPolicy policy) =>
      _api.setSleepPolicy(policy);

  /// Freezes container [ownerId]'s [contextIds]. Only the gated preflight
  /// calls this (D21).
  Future<FreezeOperationResult> freezeContexts({
    required String ownerId,
    required List<String> contextIds,
    required List<String> memberTabIds,
    bool stopMedia = false,
    bool discardPostResult = false,
    List<String> discardFormDataTabIds = const [],
    bool automatic = false,
  }) => _api.freezeContexts(
    ownerId,
    contextIds,
    memberTabIds,
    stopMedia,
    discardPostResult,
    discardFormDataTabIds,
    automatic,
  );

  /// Resumes [ownerId]'s contexts and wakes [wakeTabId]. Check routing for
  /// every context first (D34).
  Future<FreezeOperationResult> resumeContexts(
    String ownerId, {
    String? wakeTabId,
  }) => _api.resumeContexts(ownerId, wakeTabId);

  /// Before [ownerId]'s row is deleted (D28).
  Future<FreezeOperationResult> beginContextDeletion(
    String ownerId, {
    List<String> deleteDataOf = const [],
  }) => _api.beginContextDeletion(ownerId, deleteDataOf);

  /// The row of [ownerId] was not deleted after all.
  Future<FreezeOperationResult> cancelContextDeletion(String ownerId) =>
      _api.cancelContextDeletion(ownerId);

  /// After [ownerId]'s row went: the release procedure for its contexts.
  Future<FreezeOperationResult> completeContextDeletion(String ownerId) =>
      _api.completeContextDeletion(ownerId);

  /// Matches the records against the containers that exist (FULL start).
  Future<LifecycleSnapshot> reconcileOwners(List<String> existingOwnerIds) =>
      _api.reconcileOwners(existingOwnerIds);

  /// The release procedure for [contextIds] (D32).
  Future<List<ContextReleaseResult>> releaseContexts(List<String> contextIds) {
    if (contextIds.isEmpty) return Future.value(const []);
    return _api.releaseContexts(contextIds);
  }

  /// Ends recovery mode (D23); refused in normal mode.
  Future<LifecycleSnapshot> reconstructFrozenContexts({
    required List<ContainerContexts> owners,
    required List<String> unfreezableContextIds,
  }) => _api.reconstructFrozenContexts(owners, unfreezableContextIds);

  /// The registry now; works before the browser components exist.
  Future<LifecycleSnapshot> lifecycleSnapshot() => _api.getLifecycleSnapshot();

  /// What "Open WebLibre to resume" in a frozen context's web app or custom
  /// tab window left for the browser (D18), taken once; null when nothing
  /// is waiting.
  Future<FrozenWindowHandoff?> takeFrozenWindowHandoff() =>
      _api.takeFrozenWindowHandoff();
}
