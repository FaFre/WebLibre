import 'dart:developer';

import 'package:background_fetch/background_fetch.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show GeckoBrowserService;
import 'package:home_widget/home_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/error_observer.dart';
import 'package:lensai/core/logger.dart';
import 'package:lensai/core/providers/defaults.dart';
import 'package:lensai/domain/services/app_initialization.dart';
import 'package:lensai/features/user/domain/repositories/general_settings.dart';
import 'package:lensai/features/web_feed/presentation/controllers/fetch_articles.dart';
import 'package:lensai/features/web_feed/utils/fetch_entrypoint.dart';
import 'package:lensai/presentation/hooks/on_initialization.dart';
import 'package:lensai/presentation/main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    final serviceProtocolInfo = await Service.getInfo();
    logger.d('VM: ${serviceProtocolInfo.serverUri}');
  }

  await GeckoBrowserService().initialize();

  await BackgroundFetch.registerHeadlessTask(backgroundFetch);

  await HomeWidget.setAppGroupId('bang_navigator');

  runApp(
    ProviderScope(
      observers: const [ErrorObserver()],
      child: HookConsumer(
        builder: (context, ref, child) {
          final themeMode = ref.watch(
            generalSettingsRepositoryProvider.select(
              (value) => value.themeMode,
            ),
          );

          useOnInitialization(() async {
            await ref
                .read(appInitializationServiceProvider.notifier)
                .initialize();

            await BackgroundFetch.configure(
              BackgroundFetchConfig(
                minimumFetchInterval: 15,
                enableHeadless: true,
                stopOnTerminate: false,
                requiredNetworkType: NetworkType.ANY,
                startOnBoot: true,
              ),
              (String taskId) async {
                try {
                  await ref
                      .read(fetchArticlesControllerProvider.notifier)
                      .fetchAllArticles();

                  logger.i('Fetched articles in foreground');
                } catch (e, s) {
                  logger.e('Failed fetching articles', error: e, stackTrace: s);
                } finally {
                  await BackgroundFetch.finish(taskId);
                }
              },
            );
          });

          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              ColorScheme lightColorScheme;
              ColorScheme darkColorScheme;

              if (lightDynamic != null && darkDynamic != null) {
                // On Android S+ devices, use the provided dynamic color scheme.
                // (Recommended) Harmonize the dynamic color scheme' built-in semantic colors.
                lightColorScheme = lightDynamic.harmonized();

                // Repeat for the dark color scheme.
                darkColorScheme = darkDynamic.harmonized();
              } else {
                // Otherwise, use fallback schemes.
                lightColorScheme = ColorScheme.fromSeed(
                  seedColor: ref.read(lightSeedColorFallbackProvider),
                );
                darkColorScheme = ColorScheme.fromSeed(
                  seedColor: ref.read(darkSeedColorFallbackProvider),
                  brightness: Brightness.dark,
                );
              }

              return MainApp(
                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: lightColorScheme,
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  colorScheme: darkColorScheme,
                ),
                themeMode: themeMode,
              );
            },
          );
        },
      ),
    ),
  );
}
