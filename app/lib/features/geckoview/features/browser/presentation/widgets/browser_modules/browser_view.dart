import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/logger.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:lensai/features/geckoview/domain/providers/browser_extension.dart';
import 'package:lensai/features/geckoview/domain/providers/selected_tab.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_session.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/domain/providers/web_extensions_state.dart';
import 'package:lensai/features/geckoview/domain/repositories/tab.dart';
import 'package:lensai/features/geckoview/features/browser/domain/providers/lifecycle.dart';
import 'package:lensai/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:lensai/features/geckoview/features/browser/domain/services/engine_settings_replication.dart';
import 'package:lensai/features/geckoview/features/browser/domain/services/proxy_settings_replication.dart';
import 'package:lensai/features/geckoview/features/tabs/features/vector_store/domain/repositories/document.dart';
import 'package:lensai/features/user/domain/repositories/cache.dart';
import 'package:lensai/features/user/domain/repositories/general_settings.dart';
import 'package:lensai/features/user/domain/services/local_authentication.dart';
import 'package:lensai/features/web_feed/domain/providers/add_dialog_blocking.dart';
import 'package:lensai/features/web_feed/domain/services/article_content_processor.dart';
import 'package:lensai/presentation/hooks/on_initialization.dart';
import 'package:lensai/utils/ui_helper.dart';

class BrowserView extends StatefulHookConsumerWidget {
  final Duration screenshotPeriod;
  final Duration suggestionTimeout;
  final Future<void> Function()? postInitializationStep;

  const BrowserView({
    this.screenshotPeriod = const Duration(seconds: 10),
    this.suggestionTimeout = const Duration(seconds: 10),
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
      ) {
        ref
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
    ref.listenManual(tabRepositoryProvider, (previous, next) {});
    ref.listenManual(documentRepositoryProvider, (previous, next) {});

    ref.listenManual(selectionActionServiceProvider, (previous, next) {});

    ref.listenManual(
      webExtensionsStateProvider(WebExtensionActionType.browser),
      (previous, next) {},
    );

    ref.listenManual(
      webExtensionsStateProvider(WebExtensionActionType.page),
      (previous, next) {},
    );

    ref.listenManual(cacheRepositoryProvider, (previous, next) {});

    ref.listenManual(
      engineSettingsReplicationServiceProvider,
      (previous, next) {},
    );

    ref.listenManual(proxySettingsReplicationProvider, (previous, next) {});

    ref.listenManual(
      articleContentProcessorServiceProvider,
      (previous, next) {},
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

        if (_suggestionCountTime == null ||
            DateTime.now().difference(_suggestionCountTime!) >
                widget.suggestionTimeout) {
          showSuggestNewTabMessage(
            context,
            onAdd: () async {
              await const SearchRoute(tabType: TabType.regular).push(context);
            },
          );

          _suggestionCountTime = DateTime.now();
        }
    }
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);

    _periodicScreenshotUpdate?.cancel();

    super.dispose();
  }
}
