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
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/router.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/services/app_initialization.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers/intent.dart';
import 'package:weblibre/features/share_intent/domain/entities/shared_content.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

class MainApp extends HookConsumerWidget {
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;

  const MainApp({
    required this.theme,
    required this.darkTheme,
    required this.themeMode,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initializationResult = ref.watch(appInitializationServiceProvider);
    final router = ref.watch(routerProvider);

    ref.listen(
      engineBoundIntentStreamProvider,
      (previous, next) {
        next.whenData((sharedContent) async {
          final router = await ref.read(routerProvider.future);
          final settings = ref.read(generalSettingsWithDefaultsProvider);

          switch (settings.tabIntentOpenSetting) {
            case TabIntentOpenSetting.regular:
            case TabIntentOpenSetting.private:
              switch (sharedContent) {
                case SharedUrl():
                  await ref
                      .read(tabRepositoryProvider.notifier)
                      .addTab(
                        url: sharedContent.url,
                        private:
                            settings.tabIntentOpenSetting ==
                            TabIntentOpenSetting.private,
                        launchedFromIntent: true,
                      );
                case SharedText():
                  final defaultSearchBang =
                      ref.read(selectedBangDataProvider()) ??
                      await ref.read(defaultSearchBangDataProvider.future);

                  await ref
                      .read(tabRepositoryProvider.notifier)
                      .addTab(
                        url: defaultSearchBang?.getTemplateUrl(
                          sharedContent.text,
                        ),
                        private:
                            settings.tabIntentOpenSetting ==
                            TabIntentOpenSetting.private,
                        launchedFromIntent: true,
                      );
              }
            case TabIntentOpenSetting.ask:
              switch (sharedContent) {
                case SharedUrl():
                  final route = OpenSharedContentRoute(sharedContent.url);
                  await router.push(route.location, extra: route.$extra);
                case SharedText():
                  final route = SearchRoute(
                    tabType:
                        ref.read(selectedTabTypeProvider) ??
                        settings.defaultCreateTabType,
                    searchText: sharedContent.text,
                    $extra: true, //launched from intent
                  );
                  await router.push(route.location);
              }
          }
        });
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to engineBoundIntentStreamProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    return initializationResult.fold(
      (initializationState) {
        if (!initializationState.initialized) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    if (initializationState.stage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(initializationState.stage!),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          routerConfig: router.valueOrNull,
        );
      },
      onFailure: (errorMessage) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: Scaffold(
            appBar: AppBar(title: const Text('Initiallization Error')),
            body: Center(
              child: FailureWidget(
                title: 'Could not initialize App',
                exception: errorMessage.toString(),
                onRetry: () async {
                  await ref
                      .read(appInitializationServiceProvider.notifier)
                      .reinitialize();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
