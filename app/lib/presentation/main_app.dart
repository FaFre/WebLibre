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
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/router.dart';
import 'package:weblibre/domain/services/app_initialization.dart';
import 'package:weblibre/features/sync/domain/entities/sync_repository_state.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class MainApp extends HookConsumerWidget {
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;
  final double uiScaleFactor;
  final bool disableAnimations;

  const MainApp({
    required this.theme,
    required this.darkTheme,
    required this.themeMode,
    required this.uiScaleFactor,
    required this.disableAnimations,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initializationResult = ref.watch(appInitializationServiceProvider);
    final router = ref.watch(routerProvider);

    return initializationResult.fold(
      (initializationState) {
        if (!initializationState.initialized) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            builder: (context, child) {
              return _AppMediaQueryOverrides(
                uiScaleFactor: uiScaleFactor,
                disableAnimations: disableAnimations,
                child: child ?? const SizedBox.shrink(),
              );
            },
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
          routerConfig: router.value,
          builder: (context, child) {
            return _AppMediaQueryOverrides(
              uiScaleFactor: uiScaleFactor,
              disableAnimations: disableAnimations,
              child: _SyncEventListener(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
      onFailure: (errorMessage) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          builder: (context, child) {
            return _AppMediaQueryOverrides(
              uiScaleFactor: uiScaleFactor,
              disableAnimations: disableAnimations,
              child: child ?? const SizedBox.shrink(),
            );
          },
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

MediaQueryData applyAppMediaQueryOverrides({
  required MediaQueryData mediaQuery,
  required double uiScaleFactor,
  required bool disableAnimations,
}) {
  final textScaler = uiScaleFactor == 1.0
      ? mediaQuery.textScaler
      : _AppTextScaler(
          baseTextScaler: mediaQuery.textScaler,
          uiScaleFactor: uiScaleFactor,
        );

  if (disableAnimations) {
    return mediaQuery.copyWith(textScaler: textScaler, disableAnimations: true);
  }

  if (uiScaleFactor == 1.0) {
    return mediaQuery;
  }

  return mediaQuery.copyWith(textScaler: textScaler);
}

class _AppMediaQueryOverrides extends StatelessWidget {
  final double uiScaleFactor;
  final bool disableAnimations;
  final Widget child;

  const _AppMediaQueryOverrides({
    required this.uiScaleFactor,
    required this.disableAnimations,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (uiScaleFactor == 1.0 && !disableAnimations) {
      return child;
    }

    final mediaQuery = MediaQuery.of(context);
    final overriddenMediaQuery = applyAppMediaQueryOverrides(
      mediaQuery: mediaQuery,
      uiScaleFactor: uiScaleFactor,
      disableAnimations: disableAnimations,
    );

    return MediaQuery(data: overriddenMediaQuery, child: child);
  }
}

class _AppTextScaler extends TextScaler {
  final TextScaler baseTextScaler;
  final double uiScaleFactor;

  const _AppTextScaler({
    required this.baseTextScaler,
    required this.uiScaleFactor,
  }) : assert(uiScaleFactor > 0);

  @override
  double scale(double fontSize) =>
      baseTextScaler.scale(fontSize) * uiScaleFactor;

  @override
  double get textScaleFactor => scale(1.0);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is _AppTextScaler &&
        baseTextScaler == other.baseTextScaler &&
        uiScaleFactor == other.uiScaleFactor;
  }

  @override
  int get hashCode => Object.hash(baseTextScaler, uiScaleFactor);
}

class _SyncEventListener extends ConsumerWidget {
  final Widget child;

  const _SyncEventListener({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(syncEventProvider, (previous, next) {
      if (next.isLoading || !next.hasValue) return;

      final event = next.value;
      if (event == null) return;

      final (syncEvent, syncError) = event;

      switch (syncEvent) {
        // case SyncEvent.completed:
        //   ui_helper.showInfoMessage(
        //     context,
        //     'Synchronization complete',
        //     duration: const Duration(seconds: 2),
        //   );
        case SyncEvent.error:
          ui_helper.showErrorMessage(
            context,
            syncError ?? 'Synchronization failed',
          );
        case SyncEvent.started:
        case SyncEvent.completed:
        case null:
          break;
      }
    });

    return child;
  }
}
