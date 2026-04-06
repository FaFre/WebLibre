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
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';

Future<void> exitApp(ProviderContainer container) async {
  logger.i('Preparing exit');

  // 1. Close private/isolated tabs (clears browsing data for those contexts)
  try {
    await container
        .read(tabDataRepositoryProvider.notifier)
        .closeAllTabs(includeRegular: false);
    logger.i('Private tabs closed');
  } catch (e, st) {
    logger.e('Failed to close tabs', error: e, stackTrace: st);
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

  // 6. Signal the system to finish the activity and give fire-and-forget
  //    async onDispose callbacks time to settle.
  await SystemNavigator.pop();
  await Future.delayed(const Duration(seconds: 1));

  logger.i('Bye !!1');
  exit(0);
}
