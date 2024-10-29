import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/logger.dart';
import 'package:lensai/features/geckoview/domain/providers.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/domain/providers/web_extensions_state.dart';

class BrowserView extends StatefulHookConsumerWidget {
  final Duration screenshotPeriod;

  const BrowserView({this.screenshotPeriod = const Duration(seconds: 10)});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BrowserViewState();
}

class _BrowserViewState extends ConsumerState<BrowserView>
    with WidgetsBindingObserver {
  Timer? _periodicScreenshotUpdate;

  //This is managed by widget state changes to resume a timer
  bool _timerPaused = false;

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
    ref.listen(
      selectedTabStateProvider.select(
        (state) => (tabId: state?.id, isLoading: state?.isLoading),
      ),
      (previous, next) {
        if (previous?.tabId != next.tabId || next.isLoading == true) {
          _periodicScreenshotUpdate?.cancel();
          _periodicScreenshotUpdate = null;
          _timerPaused = false;
        }

        if (next.isLoading == false &&
            (_periodicScreenshotUpdate?.isActive ?? false) == false) {
          _timerPaused = false;
          _periodicScreenshotUpdate =
              Timer.periodic(widget.screenshotPeriod, _timerTick);
        }
      },
    );

    return GeckoView(
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
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    //Initialize and register dependencies
    ref.listenManual(
      selectionActionServiceProvider,
      (previous, next) {},
    );

    ref.listenManual(
      webExtensionsStateProvider(WebExtensionActionType.browser),
      (previous, next) {},
    );

    ref.listenManual(
      webExtensionsStateProvider(WebExtensionActionType.page),
      (previous, next) {},
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (_periodicScreenshotUpdate?.isActive == true) {
          _periodicScreenshotUpdate?.cancel();
          _timerPaused = true;
        }
      case AppLifecycleState.resumed:
        if (_timerPaused) {
          _periodicScreenshotUpdate =
              Timer.periodic(widget.screenshotPeriod, _timerTick);
          _timerPaused = false;
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
