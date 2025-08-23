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
import 'dart:developer';

import 'package:background_fetch/background_fetch.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show GeckoBrowserService, GeckoLoggingService, LogLevel;
import 'package:home_widget/home_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:weblibre/core/error_observer.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/defaults.dart';
import 'package:weblibre/domain/services/app_initialization.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/web_feed/presentation/controllers/fetch_articles.dart';
import 'package:weblibre/features/web_feed/utils/fetch_entrypoint.dart';
import 'package:weblibre/presentation/hooks/on_initialization.dart';
import 'package:weblibre/presentation/main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (e) {
    logger.e(e.toString(), error: e.exception, stackTrace: e.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logger.e('Unhandled Error', error: error, stackTrace: stack);
    return true;
  };

  await BackgroundFetch.registerHeadlessTask(backgroundFetch);

  if (kDebugMode) {
    final serviceProtocolInfo = await Service.getInfo();
    logger.d('VM: ${serviceProtocolInfo.serverUri}');
  }

  //Ensure everything is ready
  await Future.delayed(Duration.zero);

  GeckoLoggingService.setUp((level, message) {
    logger.log(switch (level) {
      LogLevel.debug => Level.debug,
      LogLevel.info => Level.info,
      LogLevel.warn => Level.warning,
      LogLevel.error => Level.error,
    }, message);
  });

  await HomeWidget.setAppGroupId('weblibre');

  runApp(
    ProviderScope(
      observers: const [ErrorObserver()],
      child: HookConsumer(
        builder: (context, ref, child) {
          final themeMode = ref.watch(
            generalSettingsWithDefaultsProvider.select(
              (value) => value.themeMode,
            ),
          );

          useOnInitialization(() async {
            final engineSettings = await ref
                .read(engineSettingsRepositoryProvider.notifier)
                .fetchSettings();

            await GeckoBrowserService().initialize(
              kDebugMode ? LogLevel.debug : LogLevel.warn,
              engineSettings.contentBlocking,
            );

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
