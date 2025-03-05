import 'package:background_fetch/background_fetch.dart';
import 'package:lensai/core/error_observer.dart';
import 'package:lensai/core/logger.dart';
import 'package:lensai/features/web_feed/presentation/controllers/fetch_articles.dart';
import 'package:riverpod/riverpod.dart';

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
