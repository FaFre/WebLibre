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
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/core/database_registry.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';

/// Tears down the app and ends the process.
///
/// With [restart] the process is ended natively instead of by `exit(0)`, so the
/// armed relaunch runs: the trampoline has to be started from a process that is
/// still alive, and `exit(0)` from Dart skips that.
Future<void> exitApp(
  ProviderContainer container, {
  bool restart = false,
}) async {
  logger.i(restart ? 'Preparing restart' : 'Preparing exit');

  // 1. Close private tabs (clears browsing data for private contexts).
  //    Isolated tabs are persistent and should survive app exit.
  try {
    await container
        .read(tabDataRepositoryProvider.notifier)
        .closeAllTabs(includeRegular: false, includeIsolated: false);
    logger.i('Private tabs closed');
  } catch (e, st) {
    logger.e('Failed to close tabs', error: e, stackTrace: st);
  }

  // 1b. Explicit-Quit cleanup for containers with "Clear Data on Exit" enabled.
  //     Done here — while the databases and Gecko engine are still alive — so the
  //     clear gets a chance to run on a deliberate Quit rather than only on the
  //     next launch.
  //
  //     Caveat: GeckoView's session-context clear is fire-and-forget (see
  //     GeckoDeleteBrowsingDataControllerImpl.clearDataForSessionContext) — it
  //     has no completion signal, so awaiting it does NOT mean the clear
  //     finished, only that it was dispatched. Since step 3 tears down the
  //     GeckoRuntime, we give the dispatched clear a short best-effort window to
  //     reach Gecko first. The startup fallback in browser_view.dart is retained
  //     as the actual guarantee — it covers force-stop/process death and this
  //     window elapsing before the clear lands.
  try {
    final containersToClear = await container
        .read(containerRepositoryProvider.notifier)
        .getContainersToClearOnExit();

    if (containersToClear.isNotEmpty) {
      await container
          .read(browserDataServiceProvider.notifier)
          .clearContainerData(containersToClear);
      // Best-effort settle: yield before the engine shutdown in step 3 so the
      // fire-and-forget native clear has a chance to be processed by Gecko.
      await Future<void>.delayed(const Duration(milliseconds: 500));
      logger.i(
        'Dispatched data clear for ${containersToClear.length} '
        'on-exit container(s)',
      );
    }
  } catch (e, st) {
    logger.e(
      'Failed to clear container data on exit',
      error: e,
      stackTrace: st,
    );
  }

  // 2. Stop Tor proxy (only if it was initialized)
  if (container.exists(torProxyServiceProvider)) {
    try {
      await container.read(torProxyServiceProvider.notifier).disconnect();
      logger.i('Tor proxy stopped');
    } catch (e, st) {
      logger.e('Failed to stop Tor proxy', error: e, stackTrace: st);
    }
  }

  // 3. Shutdown GeckoView engine. Must happen while the activity is still
  //    attached so shutdown() can access the FragmentManager. Internally it:
  //    a) removes the BrowserFragment via commitNow() (view teardown with
  //       the runtime still alive),
  //    b) stops component-level services (FxA, account manager),
  //    c) shuts down GeckoRuntime (safe — no views reference it anymore).
  try {
    await GeckoBrowserService().shutdown();
    logger.i('GeckoView engine shut down');
  } catch (e, st) {
    logger.e('Failed to shut down GeckoView', error: e, stackTrace: st);
  }

  // 4. Close all registered databases
  try {
    await DatabaseRegistry.instance.closeAll();
  } catch (e, st) {
    logger.e('Failed to close databases', error: e, stackTrace: st);
  }

  // 5. Dispose the Riverpod container (remaining sync cleanup).
  //    This fires async onDispose callbacks (e.g. stream cancellations in
  //    GeckoView services, viewport service) as fire-and-forget futures.
  container.dispose();
  logger.i('Provider container disposed');

  // 6. Give fire-and-forget async onDispose callbacks time to settle.
  //
  //    Finishing the Activity is skipped when restarting. There is nothing to
  //    return to — the process is about to die and the trampoline is already
  //    waiting for it — and popping first leaves a detached engine in the cache
  //    that the relaunch would attach to if the exit below ever failed to run.
  if (!restart) {
    await SystemNavigator.pop();
  }
  await Future.delayed(const Duration(seconds: 1));

  logger.i('Bye !!1');

  if (restart) {
    // Best effort, and deliberately not allowed to throw past this point. The
    // channel runs through an engine this teardown has been dismantling, so it
    // can fail — and an exception here used to skip `exit(0)` entirely, leaving a
    // live process for the trampoline to relaunch into once it gave up waiting.
    // Exiting is what actually matters; the native call only saves a moment.
    try {
      await GeckoProfileService().completeProfileRestart();
    } catch (error, stackTrace) {
      logger.w(
        'Native restart exit was unreachable; exiting from Dart',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  exit(0);
}
