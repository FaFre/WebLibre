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
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/app_links/domain/entities/app_link_rule.dart';
import 'package:weblibre/features/app_links/domain/entities/context_app_link_policy.dart';
import 'package:weblibre/features/app_links/domain/services/effective_app_link_policy.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'app_links_coordinator.g.dart';

/// Receives the native availability signal for Flutter-owned prompts. The event
/// is optimisation-only (no buffering/replay); the store query is authoritative.
class _AppLinkEventsReceiver extends GeckoAppLinkEvents {
  _AppLinkEventsReceiver(this._onAvailable);

  final void Function(AppLinkPromptOwner owner) _onAvailable;

  @override
  void onAppLinkPromptAvailable(int sequence, AppLinkPromptOwner owner) {
    _onAvailable(owner);
  }
}

/// A pending prompt paired with the absolute instant it lapses.
///
/// [AppLinkPromptRequest.expiresInMs] is a *snapshot* taken when native answered
/// the query — it does not tick down. Comparing that raw field to zero on a later
/// build would treat a long-lapsed request as live (switch tabs for three minutes
/// and come back, and a 90 s banner still reports 90 s), so the remaining time is
/// anchored to a wall-clock deadline the moment the answer arrives.
@immutable
class PendingAppLinkPrompt {
  final AppLinkPromptRequest request;
  final DateTime expiresAt;

  const PendingAppLinkPrompt({required this.request, required this.expiresAt});

  int get requestId => request.requestId;
  String get tabId => request.tabId;
  bool get isModal => request.isModal;

  /// Whether native would still accept a resolution for this request.
  bool isLive(DateTime now) => expiresAt.isAfter(now);
}

/// Orchestrates Flutter-owned app-link prompts (§2.6): registers the availability
/// event handler, queries the native pending store on attach/resume/event, and
/// exposes resolution (including the remember-then-resolve flow). The presented
/// list is authoritative from the query and deduped by `requestId` — the event
/// is only a nudge to re-query.
@Riverpod(keepAlive: true)
class AppLinksCoordinator extends _$AppLinksCoordinator {
  final _service = GeckoAppLinksService();

  @override
  List<PendingAppLinkPrompt> build() {
    final receiver = _AppLinkEventsReceiver((owner) {
      if (owner == AppLinkPromptOwner.flutterBrowser) {
        // ignore: discarded_futures
        refresh();
      }
    });
    GeckoAppLinkEvents.setUp(receiver);
    ref.onDispose(() => GeckoAppLinkEvents.setUp(null));

    // Initial query; the returned future updates state when it completes.
    // ignore: discarded_futures
    refresh();

    return const [];
  }

  /// Re-query the native pending store (called on attach, lifecycle resume, and
  /// when the availability event fires).
  Future<void> refresh() async {
    try {
      final prompts = await _service.getPendingAppLinkPrompts(
        AppLinkPromptOwner.flutterBrowser,
      );
      // Anchor the reported TTL immediately: every millisecond spent between the
      // native read and here has already been consumed.
      final queriedAt = DateTime.now();
      logger.i(
        'app-link refresh -> ${prompts.length} prompt(s): '
        '${prompts.map((p) => '${p.requestId}@${p.tabId}(${p.isModal ? 'modal' : 'banner'})').toList()}',
      );
      state = [
        for (final prompt in prompts)
          PendingAppLinkPrompt(
            request: prompt,
            expiresAt: queriedAt.add(
              Duration(milliseconds: prompt.expiresInMs),
            ),
          ),
      ];
    } catch (error, stackTrace) {
      logger.w(
        'Failed to query pending app-link prompts',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Resolve a pending prompt and re-query.
  Future<AppLinkResolutionResult> resolve(
    int requestId,
    AppLinkDecision decision,
  ) async {
    final result = await _service.resolvePendingAppLink(requestId, decision);
    await refresh();
    return result;
  }

  /// Remember-then-resolve (§2.6): persist the rule to `GeneralSettings` first so
  /// it is replicated to native, then resolve the still-pending request.
  ///
  /// [contextId] is the source tab's live contextId (from the prompt request) —
  /// the container's base contextId for a regular tab, or the tab's
  /// `isolation_context_id` for an isolated tab. When it resolves to a container
  /// with "isolated app link settings" enabled, the rule is written to that
  /// container's own override bucket (`appLinkContextOverrides`, keyed by the
  /// container's base contextId) rather than the global [GeneralSettings.appLinkRules],
  /// keeping the two rule sets separate (replace semantics).
  Future<AppLinkResolutionResult> resolveWithRule(
    int requestId,
    AppLinkDecision decision,
    PersistedAppLinkRule rule, {
    String? contextId,
  }) async {
    final overrideKey = await _overrideKeyForContext(contextId);

    await ref.read(generalSettingsRepositoryProvider.notifier).updateSettings((
      current,
    ) {
      if (overrideKey != null) {
        final existing =
            current.appLinkContextOverrides[overrideKey] ??
            ContextAppLinkPolicy.blank();
        final updated = existing.copyWith.rules({
          ...existing.rules,
          rule.scope: rule,
        });
        return current.copyWith.appLinkContextOverrides({
          ...current.appLinkContextOverrides,
          overrideKey: updated,
        });
      }
      return current.copyWith.appLinkRules({
        ...current.appLinkRules,
        rule.scope: rule,
      });
    });
    return resolve(requestId, decision);
  }

  /// Resolve the source tab's live [contextId] to the override storage key — the
  /// base contextId of the owning isolated-app-link container — or null to write
  /// globally. Handles both a regular tab (contextId is already the container
  /// base) and an isolated tab (contextId is an `isolation_context_id` mapping to
  /// its container). Delegates to [resolveAppLinkOverrideKey] so writes land in
  /// the bucket that is published back to native.
  Future<String?> _overrideKeyForContext(String? contextId) async {
    if (contextId == null) return null;

    final containers = await ref.read(watchContainersWithCountProvider.future);
    final isolationMap = await ref.read(
      watchIsolatedContextContainerMapProvider.future,
    );

    return resolveAppLinkOverrideKey(
      liveContextId: contextId,
      containers: containers,
      isolationContextContainerMap: isolationMap,
    );
  }
}
