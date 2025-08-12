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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/browser_extension.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/web_extensions_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers/lifecycle.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/engine_settings_replication.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/proxy_settings_replication.dart';
import 'package:weblibre/features/user/domain/repositories/cache.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/services/local_authentication.dart';
import 'package:weblibre/features/web_feed/domain/providers/add_dialog_blocking.dart';
import 'package:weblibre/features/web_feed/domain/services/article_content_processor.dart';
import 'package:weblibre/presentation/hooks/on_initialization.dart';
import 'package:weblibre/utils/ui_helper.dart';

class BrowserView extends StatefulHookConsumerWidget {
  final Duration screenshotPeriod;
  final Duration suggestionTimeout;
  final Future<void> Function()? postInitializationStep;

  const BrowserView({
    this.screenshotPeriod = const Duration(seconds: 10),
    this.suggestionTimeout = const Duration(seconds: 30),
    this.postInitializationStep,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BrowserViewState();
}

class _BrowserViewState extends ConsumerState<BrowserView>
    with WidgetsBindingObserver {
  Timer? _periodicScreenshotUpdate;

  //This is managed by widget state changes to resume a timer
  bool _timerPaused = false;

  DateTime? _suggestionCountTime;

  Future<void> _timerTick(Timer timer) async {
    await ref
        .read(selectedTabSessionNotifierProvider)
        .requestScreenshot(requireImageResult: false)
        .onError((error, stackTrace) {
          logger.e(error, stackTrace: stackTrace);
          timer.cancel();

          return null;
        });
  }

  @override
  Widget build(BuildContext context) {
    useOnInitialization(() async {
      await ref.read(generalSettingsRepositoryProvider.notifier).fetch().then((
        settings,
      ) async {
        await ref
            .read(browserDataServiceProvider.notifier)
            .deleteDataOnEngineStart(settings.deleteBrowsingDataOnQuit);
      });
    });

    final hasTab = ref.watch(
      selectedTabProvider.select((value) => value != null),
    );

    ref.listen(
      selectedTabStateProvider.select(
        (state) => (tabId: state?.id, isLoading: state?.isLoading),
      ),
      (previous, next) {
        if (previous?.tabId != next.tabId || next.isLoading == true) {
          _periodicScreenshotUpdate?.cancel();
          _periodicScreenshotUpdate = null;
          _timerPaused = false;

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }

        if (next.isLoading == false &&
            (_periodicScreenshotUpdate?.isActive ?? false) == false) {
          _timerPaused = false;
          _periodicScreenshotUpdate = Timer.periodic(
            widget.screenshotPeriod,
            _timerTick,
          );
        }
      },
    );

    ref.listen(feedRequestedProvider, (previous, next) async {
      if (next.valueOrNull.mapNotNull(Uri.tryParse) case final Uri url) {
        if (GoRouterState.of(context).topRoute?.name != FeedAddRoute.name) {
          if (ref.read(addFeedDialogBlockingProvider.notifier).canPush(url)) {
            await FeedAddRoute($extra: url).push(context);
          }
        }
      }
    });

    return Visibility(
      visible: hasTab,
      replacement: SizedBox.expand(child: Container(color: Colors.grey[800])),
      child: GeckoView(
        preInitializationStep: () async {
          await ref
              .read(eventServiceProvider)
              .viewReadyStateEvents
              .firstWhere((state) => state == true)
              .timeout(
                const Duration(seconds: 3),
                onTimeout: () {
                  logger.e(
                    'Browser fragement not reported ready, trying to intitialize anyways',
                  );
                  return true;
                },
              );
        },
        postInitializationStep: () async {
          await widget.postInitializationStep?.call();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(browserViewLifecycleProvider.notifier)
          .update(SchedulerBinding.instance.lifecycleState);
    });

    WidgetsBinding.instance.addObserver(this);

    //Initialize and register dependencies
    ref.listenManual(
      fireImmediately: true,
      tabRepositoryProvider,
      (previous, next) {},
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to tabRepositoryProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listenManual(
      fireImmediately: true,
      selectionActionServiceProvider,
      (previous, next) {},
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to selectionActionServiceProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listenManual(
      fireImmediately: true,
      webExtensionsStateProvider(WebExtensionActionType.browser),
      (previous, next) {},
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to webExtensionsStateProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listenManual(
      fireImmediately: true,
      webExtensionsStateProvider(WebExtensionActionType.page),
      (previous, next) {},
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to webExtensionsStateProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listenManual(
      fireImmediately: true,
      cacheRepositoryProvider,
      (previous, next) {},
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to cacheRepositoryProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listenManual(
      fireImmediately: true,
      engineSettingsReplicationServiceProvider,
      (previous, next) {},
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to engineSettingsReplicationServiceProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listenManual(
      fireImmediately: true,
      proxySettingsReplicationProvider,
      (previous, next) {},
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to proxySettingsReplicationProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listenManual(
      fireImmediately: true,
      articleContentProcessorServiceProvider,
      (previous, next) {},
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to articleContentProcessorServiceProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    ref.read(browserViewLifecycleProvider.notifier).update(state);

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (_periodicScreenshotUpdate?.isActive == true) {
          _periodicScreenshotUpdate?.cancel();
          _timerPaused = true;
        }

        ref
            .read(localAuthenticationServiceProvider.notifier)
            .evictCacheOnBackground();

        if (state == AppLifecycleState.paused) {
          _suggestionCountTime = DateTime.now();
        }
      case AppLifecycleState.resumed:
        if (_timerPaused) {
          _periodicScreenshotUpdate = Timer.periodic(
            widget.screenshotPeriod,
            _timerTick,
          );
          _timerPaused = false;
        }

        if (_suggestionCountTime != null &&
            DateTime.now().difference(_suggestionCountTime!) >
                widget.suggestionTimeout) {
          //Don't do anything if a child route is active
          if (GoRouterState.of(context).topRoute?.name == BrowserRoute.name) {
            final settings = ref.read(generalSettingsRepositoryProvider);

            unawaited(
              showSuggestNewTabMessage(
                context,
                onAdd: (searchText) async {
                  await SearchRoute(
                    tabType:
                        ref.read(selectedTabTypeProvider) ??
                        settings.defaultCreateTabType,
                    searchText: searchText ?? SearchRoute.emptySearchText,
                  ).push(context);
                },
              ),
            );
          }
        }

        _suggestionCountTime = null;
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);

    _periodicScreenshotUpdate?.cancel();

    super.dispose();
  }
}
