/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/core/error_observer.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/web_feed/presentation/controllers/fetch_articles.dart';

@pragma('vm:entry-point')
Future<void> backgroundFetch(HeadlessTask task) async {
  final taskId = task.taskId;

  final isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    logger.e("[BackgroundFetch] Headless task timed-out: $taskId");
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

    await BackgroundFetch.finish(taskId);
  }
}
