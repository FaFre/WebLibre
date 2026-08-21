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
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/core/error_observer.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/startup/startup_bootstrap.dart';
import 'package:weblibre/features/web_feed/presentation/controllers/fetch_articles.dart';

@pragma('vm:entry-point')
Future<void> backgroundFetch(HeadlessEvent task) async {
  final taskId = task.taskId;

  final isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    logger.e("[BackgroundFetch] Headless task timed-out: $taskId");
    await BackgroundFetch.finish(taskId);
    return;
  }

  // A headless run is a second isolate, so it starts with nothing resolved: the
  // globals `filesystem` exposes live per isolate. It has to arbitrate for
  // itself, and it has to do so before the container below, because every
  // provider it would reach for opens a profile database.
  //
  // Asking is not the same as deciding. If the UI already committed, native
  // answers with that profile and activation is a no-op; if nothing has, this
  // isolate may commit the candidate. Either way one profile is agreed on before
  // a database file is touched.
  final phase = await resolveStartupPhase(
    ownerType: ProfileStartupOwnerType.headless,
    taskId: taskId,
  );
  if (phase is! StartupActivated) {
    logger.w('Skipping background fetch: $phase');

    // Every lease this isolate was granted has to go back before it ends. A halted
    // phase already returned the access lease; anything else still holds it, and a
    // maintenance phase holds a second lease on top — one this isolate can never
    // use, having no screen to ask for a password on. Left behind, the first makes
    // the next UI start halt with `profileAccessBusy` and the second expires into
    // the recovery-restart flag, wedging the process.
    if (phase is StartupMaintenanceRequired) {
      await releaseMaintenanceLease(leaseId: phase.leaseId);
    }
    if (phase is! StartupHalted) {
      await releaseProfileAccess(
        ownerType: ProfileStartupOwnerType.headless,
        taskId: taskId,
      );
    }

    await BackgroundFetch.finish(taskId);
    return;
  }

  final ref = ProviderContainer(observers: const [ErrorObserver()]);
  try {
    await ref.read(fetchArticlesControllerProvider.notifier).fetchAllArticles();

    logger.i('Fetched articles in background');
  } catch (e, s) {
    logger.e('Failed fetching articles', error: e, stackTrace: s);
  } finally {
    ref.dispose();

    // Give everything a bit of time to properly dispose
    await Future.delayed(const Duration(seconds: 1));

    // Released only after the container is gone: the lease means "this isolate
    // has profile state open", so handing it back while connections are still
    // closing would let the UI start against databases this isolate is still
    // holding.
    await releaseProfileAccess(
      ownerType: ProfileStartupOwnerType.headless,
      taskId: taskId,
    );

    await BackgroundFetch.finish(taskId);
  }
}
