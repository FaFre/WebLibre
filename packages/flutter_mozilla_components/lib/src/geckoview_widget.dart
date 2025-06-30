/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/domain/services/gecko_browser.dart';

class GeckoView extends StatefulWidget {
  final Future<void> Function()? preInitializationStep;
  final Future<void> Function()? postInitializationStep;

  const GeckoView({
    super.key,
    this.preInitializationStep,
    this.postInitializationStep,
  });

  @override
  State<GeckoView> createState() => _GeckoViewState();
}

class _GeckoViewState extends State<GeckoView> {
  static const platform = MethodChannel(
    'eu.weblibre.flutter_mozilla_components/trim_memory',
  );

  final browserService = GeckoBrowserService();
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _setupMethodCallHandler();
    _listener = AppLifecycleListener(
      onResume: () async {
        //Make sure fragment visible after rsuming the app in case native resources have been disposed
        await _showNativeFragment();
      },
    );
  }

  void _setupMethodCallHandler() {
    platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onTrimMemory') {
        await browserService.onTrimMemory(call.arguments as int);
      }
    });
  }

  Future<bool> _showNativeFragment({
    int maxRetries = 100,

    /// Default ist about one frame
    Duration retryDelay = const Duration(milliseconds: 1000 ~/ 60),
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      final result = await browserService.showNativeFragment();

      if (result) {
        debugPrint('Fragment ATTACHED after $attempt tries');
        return true;
      }

      if (attempt < maxRetries - 1) {
        await Future.delayed(retryDelay);
      }
    }

    debugPrint('Fragment FAILED after $maxRetries tries');
    return false;
  }

  @override
  void dispose() {
    platform.setMethodCallHandler(null);
    _listener.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformViewLink(
      viewType: 'eu.weblibre/gecko',
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return PlatformViewsService.initExpensiveAndroidView(
            id: params.id,
            viewType: 'eu.weblibre/gecko',
            layoutDirection: TextDirection.ltr,
            creationParams: {},
            creationParamsCodec: const StandardMessageCodec(),
          )
          ..addOnPlatformViewCreatedListener((value) {
            params.onPlatformViewCreated(value);

            SchedulerBinding.instance.addPostFrameCallback((_) async {
              await widget.preInitializationStep?.call();

              await _showNativeFragment();
              await widget.postInitializationStep?.call();
            });
          })
          // ignore: discarded_futures that hos it is done in docs
          ..create();
      },
    );
  }
}
