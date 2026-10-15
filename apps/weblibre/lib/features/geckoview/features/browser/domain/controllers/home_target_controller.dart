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

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/restore_complete.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/home_target.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers/intent.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

part 'home_target_controller.g.dart';

/// A custom-URL target reopened within this window of the last one is treated
/// as a loop and suppressed.
const _customUrlLoopWindow = Duration(seconds: 2);

/// What [HomeTargetController] should actually do, given the configuration and
/// the current state.
///
/// Pure so the fallbacks and the loop guards can be tested without a browser.
HomeTarget resolveHomeTarget({
  required HomeTarget target,
  required String? customUrl,
  DateTime? lastCustomUrlOpenedAt,
  DateTime? now,
  Uri? closingTabUrl,
}) {
  switch (target) {
    case HomeTarget.home:
      return HomeTarget.home;

    case HomeTarget.resumeLastTab:
      // Whether there is anything to resume is only known once the repository
      // has looked; the caller falls back to home when it reports none.
      return HomeTarget.resumeLastTab;

    case HomeTarget.customUrl:
      final parsed = uri_parser.tryParseUrl(customUrl ?? '');
      if (parsed == null) {
        return HomeTarget.home;
      }

      // Closing the custom-URL tab must not immediately reopen it. Two guards,
      // because either alone is escapable: the URL check misses redirects away
      // from the configured address, and the time check misses a slow user.
      if (closingTabUrl != null && _sameTarget(closingTabUrl, parsed)) {
        return HomeTarget.home;
      }

      if (lastCustomUrlOpenedAt != null) {
        final elapsed = (now ?? DateTime.now()).difference(
          lastCustomUrlOpenedAt,
        );
        if (elapsed < _customUrlLoopWindow) {
          return HomeTarget.home;
        }
      }

      return HomeTarget.customUrl;
  }
}

/// Which container a home target opens its tab in.
///
/// Pure because this is exactly where the scope distinction is easy to get
/// wrong: under [scopeToContainer] a null [scopedContainer] means the
/// *unassigned* container and must stay unassigned, rather than silently
/// falling back to whichever container happens to be selected.
TabContainerSelection resolveHomeTargetContainer({
  required bool scopeToContainer,
  required ContainerData? scopedContainer,
  required ContainerData? selectedContainer,
}) {
  final container = scopeToContainer ? scopedContainer : selectedContainer;

  return container == null
      ? const TabContainerSelection.unassigned()
      : TabContainerSelection.specific(container);
}

bool _sameTarget(Uri a, Uri b) =>
    a.host.toLowerCase() == b.host.toLowerCase() && a.path == b.path;

/// Applies the configured [HomeTarget] when the browser has nothing to show.
@Riverpod(keepAlive: true)
class HomeTargetController extends _$HomeTargetController {
  DateTime? _lastCustomUrlOpenedAt;
  var _startupHandled = false;

  /// Runs the configured target.
  ///
  /// With [scopeToContainer] the target is confined to [containerId], so
  /// closing the last tab in a container keeps the user there. A null
  /// [containerId] under that flag means the *unassigned* container, which is a
  /// real scope — not the absence of one. Without the flag (cold start) the
  /// target is unscoped and follows the selected container.
  ///
  /// [closingTabUrl] is the tab that triggered this, used to break the
  /// custom-URL reopen loop. [excludedTabIds] are tabs that are being closed
  /// but not yet deleted, which a resume must not select.
  Future<void> applyTarget({
    bool scopeToContainer = false,
    String? containerId,
    Uri? closingTabUrl,
    Set<String> excludedTabIds = const {},
  }) async {
    final settings = ref.read(generalSettingsWithDefaultsProvider);
    final tabs = ref.read(tabRepositoryProvider.notifier);

    final resolved = resolveHomeTarget(
      target: settings.homeTarget,
      customUrl: settings.homeTargetUrl,
      lastCustomUrlOpenedAt: _lastCustomUrlOpenedAt,
      closingTabUrl: closingTabUrl,
    );

    switch (resolved) {
      case HomeTarget.home:
        ref.read(forceBrowserHomeProvider.notifier).request();

      case HomeTarget.resumeLastTab:
        // Scoped resume goes through the container query even for a null
        // container: that selects the newest *unassigned* tab, where the
        // unscoped call would happily jump into some other container.
        final resumed = scopeToContainer
            ? await tabs.resumeLatestContainerTab(
                containerId,
                excludedTabIds: excludedTabIds,
              )
            : await tabs.resumeLatestTab(excludedTabIds: excludedTabIds);

        // Nothing to resume: home beats leaving a blank viewport.
        if (!resumed && ref.mounted) {
          ref.read(forceBrowserHomeProvider.notifier).request();
        }

      case HomeTarget.customUrl:
        final url = uri_parser.tryParseUrl(settings.homeTargetUrl ?? '');
        if (url == null) {
          ref.read(forceBrowserHomeProvider.notifier).request();
          return;
        }

        _lastCustomUrlOpenedAt = DateTime.now();

        final scopedContainer = (scopeToContainer && containerId != null)
            ? await ref
                  .read(containerRepositoryProvider.notifier)
                  .getContainerData(containerId)
            : null;

        if (!ref.mounted) return;

        await tabs.addTab(
          url: url,
          tabMode: TabMode.regular,
          selectTab: true,
          containerSelection: resolveHomeTargetContainer(
            scopeToContainer: scopeToContainer,
            scopedContainer: scopedContainer,
            // A one-shot read takes no subscription, so this keep-alive
            // controller does not pin the auto-disposed stream.
            // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
            selectedContainer: ref.read(selectedContainerDataProvider).value,
          ),
        );
    }
  }

  /// Runs the configured target at cold start, unless the engine restored a
  /// selection of its own — the user is then already looking at a page.
  ///
  /// "Cold start" is this controller's: a fresh isolate. That is also what
  /// returning to an activity Android destroyed in the background gets, since
  /// the engine is discarded with it while the native store — and the tab it
  /// has selected — lives on.
  ///
  /// An external launch counts as a selection the session is about to have, and
  /// it loses this race on its own: opening it waits for the engine, while the
  /// check below answers at once. The target then latched the home surface
  /// over the page the launch opened, or resumed a different tab entirely
  /// (#623), so a claimed launch is waited for instead — twice, since one that
  /// arrives while the check below is out has the same claim on the startup
  /// surface as one that was already in flight.
  Future<void> _applyStartupTarget() async {
    final launchClaim = ref.read(intentLaunchClaimProvider.notifier);

    do {
      await launchClaim.waitUntilSettled();
      if (!ref.mounted) return;

      if (await _hasRestoredSelection()) return;
      if (!ref.mounted) return;
    } while (ref.read(intentLaunchClaimProvider));

    await applyTarget();
  }

  /// Whether the session already has a selected tab — restored, or opened by
  /// the launch the app was started for.
  ///
  /// The answer cannot be read off [selectedTabProvider] the moment restore
  /// completes: the two facts travel over independent native flows, and only
  /// the selected-tab one is debounced (~50ms, so that it lands after the
  /// tab-added and tab-list events). Restore-complete therefore reliably
  /// *overtakes* the selection it implies, and reading at that instant reports
  /// no tab for a session that has one. Acting on that latches the home surface
  /// over the tab.
  ///
  /// So the store is asked directly. Waiting a bounded window for the event
  /// was the earlier shape, and it lost whenever the platform thread was busy
  /// past the window — on a loaded start, the event and the timer both queue
  /// up and the timer can win (#667). The store's answer has no such race: it
  /// is read on the thread every selection is dispatched on, after each one
  /// that preceded this call — the restore's (dispatched before restore
  /// completes) and a claimed launch's (dispatched before its claim is
  /// released). The event still catches [selectedTabProvider] up on its own.
  Future<bool> _hasRestoredSelection() async {
    if (ref.read(selectedTabProvider) != null) return true;

    try {
      return await GeckoTabService().getSelectedTabId() != null;
    } catch (error, stackTrace) {
      // Treated as no selection: home is what shows while nothing is
      // selected anyway, and a tab it ends up covering is one tap away in the
      // tab bar.
      logger.w(
        'Failed to read the selected tab for the startup home target',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  void build() {
    ref.listen(
      // This controller is created lazily by the browser view. Restore can
      // already be complete by then, and a plain listen would sit waiting for
      // an edge that has been and gone, silently skipping the startup target.
      fireImmediately: true,
      browserRestoreCompleteProvider,
      (previous, next) {
        if (!next || _startupHandled) return;
        _startupHandled = true;

        unawaited(_applyStartupTarget());
      },
    );
  }
}
