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

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/app_links/domain/services/app_links_coordinator.dart';
import 'package:weblibre/features/app_links/presentation/widgets/app_link_open_banner.dart';
import 'package:weblibre/features/app_links/presentation/widgets/app_link_prompt_dialog.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';

/// Presents Flutter-owned app-link prompts (§2.6): renders at most one banner for
/// the active tab, and drives one modal at a time via [showDialog]. A request is
/// only shown while its originating tab is active. Rotation/teardown is not a
/// dismissal — the request stays pending and is re-presented on the next query.
///
/// Mount this as a layer of the browser Stack that is positioned *above* the bottom
/// app bar (see `browser.dart`, next to the find-in-page layer). It renders the
/// banner inline, bottom-anchored within that positioned region — Flutter composites
/// over the live GeckoView fine (the toolbars do the same); the only requirement is
/// that the host is not placed underneath the bottom app bar.
class AppLinkPromptHost extends HookConsumerWidget {
  const AppLinkPromptHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompts = ref.watch(appLinksCoordinatorProvider);
    final activeTabId = ref.watch(selectedTabProvider);

    // The Pigeon availability event has no replay: an event emitted while Flutter
    // was detached is lost, so re-query the native pending store on resume (§2.6).
    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.resumed) {
        unawaited(ref.read(appLinksCoordinatorProvider.notifier).refresh());
      }
    });

    // Native expiry is lazy — it only runs when the store is queried or consumed — and nothing
    // pushes an expiry event. A prompt that outlives its deadline would keep rendering live
    // buttons whose resolution is already a no-op, so drop anything already past due rather than
    // offering an action that cannot happen. The deadline is absolute
    // ([PendingAppLinkPrompt.expiresAt]); the raw `expiresInMs` is only valid at query time.
    final now = DateTime.now();
    final livePrompts = prompts.where((prompt) => prompt.isLive(now)).toList();
    final activeRequests = livePrompts
        .where((prompt) => prompt.tabId == activeTabId)
        .toList();

    // ...and re-query when the soonest deadline passes, so a prompt retires itself on time
    // instead of waiting for the next event or resume. Keyed on the absolute deadline so a
    // rebuild (tab switch, unrelated state change) never re-arms a full-length timer from a
    // stale TTL. The lower clamp matters: a deadline already reached would otherwise reschedule
    // instantly and spin.
    final soonestDeadline = livePrompts.isEmpty
        ? null
        : livePrompts
              .map((prompt) => prompt.expiresAt)
              .reduce((a, b) => a.isBefore(b) ? a : b);
    useEffect(() {
      if (soonestDeadline == null) return null;
      final delay = soonestDeadline.difference(DateTime.now());
      final timer = Timer(
        Duration(milliseconds: delay.inMilliseconds.clamp(250, 10 * 60 * 1000)),
        () =>
            unawaited(ref.read(appLinksCoordinatorProvider.notifier).refresh()),
      );
      return timer.cancel;
    }, [soonestDeadline]);

    final modalRequest = activeRequests
        .where((prompt) => prompt.isModal)
        .lastOrNull;
    // At most one banner per tab; a newer banner-class request simply becomes the
    // one the UI renders.
    final bannerRequest = activeRequests
        .where((prompt) => !prompt.isModal)
        .lastOrNull;

    // A modal is shown at most once per requestId. Rotation/teardown is not a
    // dismissal — the request stays pending and is re-presented on the next query
    // (a subsequent build re-runs this effect with the still-present id).
    final shownModalId = useRef<int?>(null);
    // The route the modal lives on, so it can be retired without popping whatever
    // else happens to sit on top of it.
    final shownModalRoute = useRef<ModalRoute<void>?>(null);
    // Ids we closed ourselves. Their pop must not be mistaken for a user
    // dismissal, which would consume a request that is merely off-screen.
    final retiredModalIds = useRef<Set<int>>(<int>{});

    // Take down a dialog nobody can act on any more: its request expired, was
    // invalidated (tab closed), or belongs to a tab the user has left. Without
    // this the route just stays on screen with buttons that resolve to `stale`.
    // Mirrors the native `NativeAppLinkPromptFeature.dismissStaleDialog`.
    void retireShownModal() {
      final shownId = shownModalId.value;
      final route = shownModalRoute.value;
      shownModalId.value = null;
      shownModalRoute.value = null;
      if (shownId == null || route == null || !route.isActive) return;
      retiredModalIds.value.add(shownId);
      route.navigator?.removeRoute(route);
    }

    useEffect(() {
      final request = modalRequest;
      final shownId = shownModalId.value;
      if (shownId != null && shownId != request?.requestId) {
        retireShownModal();
      }
      if (request == null || shownModalId.value == request.requestId) {
        return null;
      }
      shownModalId.value = request.requestId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        unawaited(
          showDialog<void>(
            context: context,
            builder: (dialogContext) {
              shownModalRoute.value = ModalRoute.of<void>(dialogContext);
              return AppLinkPromptDialog(request: request.request);
            },
          ).then((_) {
            if (retiredModalIds.value.remove(request.requestId)) {
              // We closed it, not the user. The request is either already gone or
              // still pending for a tab that is no longer in front — either way it
              // must not be consumed here.
              return;
            }
            // Catch-all for a passive dismissal (Android back / touch-outside):
            // the dialog buttons resolve the request themselves, but a barrier
            // dismiss closes it without resolving, leaving the native request
            // pending forever (and `shownModalId` blocks a re-show). Resolving as
            // dismiss here is idempotent — if a button already consumed it, the
            // native store returns stale and this is a no-op.
            unawaited(
              ref
                  .read(appLinksCoordinatorProvider.notifier)
                  .resolve(request.requestId, AppLinkDecision.dismiss),
            );
          }),
        );
      });
      return null;
    }, [modalRequest?.requestId]);

    if (bannerRequest == null) {
      return const SizedBox.shrink();
    }

    return AppLinkOpenBanner(
      key: ValueKey(bannerRequest.requestId),
      request: bannerRequest.request,
    );
  }
}
