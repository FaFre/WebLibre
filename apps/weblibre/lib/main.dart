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
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:background_fetch/background_fetch.dart';
import 'package:country_codes/country_codes.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    show
        GeckoBrowserService,
        GeckoEngineSettingsService,
        GeckoLoggingService,
        LogLevel;
import 'package:home_widget/home_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:nullability/nullability.dart';
import 'package:privacypass_client/privacypass_client.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/error_observer.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/app_state.dart';
import 'package:weblibre/core/providers/defaults.dart';
import 'package:weblibre/core/providers/router.dart';
import 'package:weblibre/core/secure_storage/secure_storage_migration.dart';
import 'package:weblibre/domain/services/app_initialization.dart';
import 'package:weblibre/domain/services/display_mode.dart';
import 'package:weblibre/features/account/domain/services/account_callback_handler.dart';
import 'package:weblibre/features/app_widget/domain/services/home_widget.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/engine_settings_replication.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/proxy_settings_replication.dart';
import 'package:weblibre/features/geckoview/features/history/domain/services/history_exclusion_replication.dart';
import 'package:weblibre/features/geckoview/features/history/domain/services/visit_container_recorder.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_catalog_service.dart';
import 'package:weblibre/features/geckoview/features/preferences/data/repositories/preference_observer.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/local_index_pruner.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/local_index_settings_sync.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_logs.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_autostart.dart';
import 'package:weblibre/features/share_intent/domain/services/sharing_intent.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/services/profile_restart_request.dart';
import 'package:weblibre/features/web_feed/presentation/controllers/fetch_articles.dart';
import 'package:weblibre/features/web_feed/utils/fetch_entrypoint.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/presentation/hooks/on_initialization.dart';
import 'package:weblibre/presentation/main_app.dart';
import 'package:weblibre/presentation/startup_phase_host.dart';

ColorScheme _fixSurfaceContainerColors(
  ColorScheme scheme,
  TonalPalette neutralPalette,
  Brightness brightness,
) {
  if (brightness == Brightness.light) {
    return scheme.copyWith(
      surfaceContainerLowest: Color(neutralPalette.get(100)),
      surfaceContainerLow: Color(neutralPalette.get(96)),
      surfaceContainer: Color(neutralPalette.get(94)),
      surfaceContainerHigh: Color(neutralPalette.get(92)),
      surfaceContainerHighest: Color(neutralPalette.get(90)),
    );
  } else {
    return scheme.copyWith(
      surfaceContainerLowest: Color(neutralPalette.get(4)),
      surfaceContainerLow: Color(neutralPalette.get(10)),
      surfaceContainer: Color(neutralPalette.get(12)),
      surfaceContainerHigh: Color(neutralPalette.get(17)),
      surfaceContainerHighest: Color(neutralPalette.get(22)),
    );
  }
}

/// Rewrites a dark [ColorScheme] to use pure-black ("OLED"/high-contrast)
/// surfaces.
///
/// Only the *base* tones (the scaffold/page background and the lowest
/// containers) become true black for the power saving. The elevated container
/// tones keep meaningful grey steps so cards, sheets and menus stay visibly
/// separated from the black background — Material elevation shadows are
/// invisible on black, so the surface-tint step is the only separation cue and
/// it must stay perceptible. Steps below ~`#12` are imperceptible near black, so
/// the elevated tones climb in larger increments than the default dark scheme.
ColorScheme _applyPureBlackSurfaces(ColorScheme scheme) {
  return scheme.copyWith(
    surface: const Color(0xFF000000),
    surfaceDim: const Color(0xFF000000),
    surfaceContainerLowest: const Color(0xFF000000),
    surfaceContainerLow: const Color(0xFF121212),
    surfaceContainer: const Color(0xFF1B1B1B),
    surfaceContainerHigh: const Color(0xFF242424),
    surfaceContainerHighest: const Color(0xFF2E2E2E),
  );
}

bool _hasBrokenSurfaceContainerColors(ColorScheme scheme) {
  return scheme.surfaceContainerLowest == scheme.surface &&
      scheme.surfaceContainerLow == scheme.surface &&
      scheme.surfaceContainer == scheme.surface &&
      scheme.surfaceContainerHigh == scheme.surface &&
      scheme.surfaceContainerHighest == scheme.surface;
}

class _NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

const _noAnimationPageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: _NoAnimationPageTransitionsBuilder(),
    TargetPlatform.iOS: _NoAnimationPageTransitionsBuilder(),
    TargetPlatform.linux: _NoAnimationPageTransitionsBuilder(),
    TargetPlatform.macOS: _NoAnimationPageTransitionsBuilder(),
    TargetPlatform.windows: _NoAnimationPageTransitionsBuilder(),
  },
);

class _MainWidget extends HookConsumerWidget {
  const _MainWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep the sandbox capture controller alive for the lifetime of the app
    // so it can react to pigeon events even when no UI subscribes to it.
    ref.watch(sandboxCaptureControllerProvider);
    // Keep proxy/Tor log subscriptions active from app start so startup
    // messages reach the ring buffer before the browser view (or logs
    // screen) mounts and would otherwise drop them.
    ref.watch(singboxProxyLogsProvider.select((_) => null));
    // Apply the configured display refresh rate from app start and keep it in
    // sync with the setting (Flutter defaults to 60Hz otherwise).
    ref.watch(displayModeApplierProvider);

    final rootKey = ref.watch(appStateKeyProvider);

    final pauseTime = useRef<DateTime?>(null);
    useOnAppLifecycleStateChange((previous, current) async {
      switch (current) {
        case AppLifecycleState.resumed:
          if (pauseTime.value != null &&
              DateTime.now().difference(pauseTime.value!) >
                  const Duration(minutes: 30)) {
            final routerConfig = ref
                .read(routerProvider)
                .value
                ?.routerDelegate
                .currentConfiguration;

            //Rebuild widget tree after long time of inactivity
            ref.read(appStateKeyProvider.notifier).reset();

            //Wait for the new router to start
            await Future.delayed(
              const Duration(milliseconds: 250),
            ).whenComplete(() {
              routerConfig.mapNotNull(
                (routerConfig) =>
                    ref.read(routerProvider).value?.restore(routerConfig),
              );
            });

            logger.i('UI reset');
          }
          pauseTime.value = null;
        case AppLifecycleState.detached:
        case AppLifecycleState.inactive:
        case AppLifecycleState.hidden:
        case AppLifecycleState.paused:
          pauseTime.value ??= DateTime.now();
      }
    });

    final themeMode = ref.watch(
      generalSettingsWithDefaultsProvider.select((value) => value.themeMode),
    );
    final uiScaleFactor = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.uiScaleFactor,
      ),
    );
    final disableAnimations = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.disableAnimations,
      ),
    );
    final showModalBarrier = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.showModalBarrier,
      ),
    );
    final pureBlack = ref.watch(
      generalSettingsWithDefaultsProvider.select((value) => value.pureBlack),
    );

    useOnInitialization(() async {
      await CountryCodes.init();

      final engineSettings = await ref
          .read(engineSettingsRepositoryProvider.notifier)
          .fetchSettings();
      final generalSettings = await ref
          .read(generalSettingsRepositoryProvider.notifier)
          .fetchSettings();
      final startupUBlockFilterListsPref =
          engineSettings.ublockFilterListSettings.enabled
          ? jsonEncode(
              engineSettings.ublockFilterListSettings.resolveFinalList(),
            )
          : null;
      final clearStartupUBlockFilterListsPref =
          !engineSettings.ublockFilterListSettings.enabled;

      // Push the hard exclude-from-history snapshot to native BEFORE the engine
      // starts — it records visits as soon as restored tabs load, so an excluded
      // ("incognito") container could otherwise leak to Places during the
      // startup window. Best-effort: on failure the keepAlive provider still
      // pushes once the databases are readable.
      try {
        final snapshot = await readHistoryExclusionSnapshot(
          ref.read(tabDatabaseProvider),
        );

        await GeckoEngineSettingsService().setHistoryExclusions(
          excludedTabIds: snapshot.excludedTabIds,
          knownTabIds: snapshot.knownTabIds,
          excludedContextIds: snapshot.excludedContextIds,
        );
      } catch (e, s) {
        logger.w(
          'Failed initial history-exclusion push at startup',
          error: e,
          stackTrace: s,
        );
      }

      // Keep that snapshot current for the rest of the session. Activated here,
      // at app scope, and never from a screen: the setting is edited from the
      // container editor and the tab set changes from everywhere, so a
      // replication tied to the browser view would stop pushing whenever that
      // view is gone — leaking visits after the toggle is enabled, or suppressing
      // them after it is disabled. keepAlive, so this single activation holds for
      // the whole session.
      ref.listenManual(
        fireImmediately: true,
        historyExclusionReplicationProvider,
        (previous, next) {},
        onError: (error, stackTrace) {
          logger.e(
            'Error listening to historyExclusionReplicationProvider',
            error: error,
            stackTrace: stackTrace,
          );
        },
      );

      // Register the visit→container recorder BEFORE the engine starts. It only
      // installs a Dart-side GeckoHistoryEvents handler (no native dependency),
      // while native visit events can already fire as restored tabs load during
      // initialize — Pigeon FlutterApi messages aren't buffered, so a recorder
      // registered afterwards would silently drop those early visits' container
      // relations.
      ref.read(visitContainerRecorderProvider);

      // Start assembling the container routing snapshot BEFORE the engine, so
      // the push is already queued when the proxy extension comes up. The
      // extension blocks every request until it has one, so the sooner this is
      // installed the shorter the window in which protected containers cannot
      // load — and it is a barrier, never a leak, if it is late.
      ref.read(proxySettingsReplicationProvider);

      try {
        await GeckoBrowserService().initialize(
          filesystem.relativeProfilePath,
          kDebugMode ? LogLevel.debug : LogLevel.warn,
          engineSettings.contentBlocking,
          engineSettings.addonCollection,
          generalSettings.syncServerOverride,
          generalSettings.syncTokenServerOverride,
          engineSettings,
          startupUBlockFilterListsPref,
          clearStartupUBlockFilterListsPref,
        );
      } on PlatformException catch (e, s) {
        logger.e(
          'Platform exception during Gecko initialization',
          error: e,
          stackTrace: s,
        );
        rethrow;
      } catch (e, s) {
        logger.e(
          'Failed to initialize Gecko browser service',
          error: e,
          stackTrace: s,
        );
        rethrow;
      }

      // Mirror the startup uBO pref into the fixator so later pref changes are
      // still observed and enforced after native startup initialization.
      try {
        await syncUBlockFilterLists(
          ref.read(preferenceFixatorProvider.notifier),
          engineSettings,
        );
      } catch (e, s) {
        logger.w(
          'Failed to sync uBlock filter list pref at startup',
          error: e,
          stackTrace: s,
        );
      }

      await ref.read(appInitializationServiceProvider.notifier).initialize();

      Future<void> preloadUrlCleanerCatalog() async {
        if (!generalSettings.urlCleanerEnabled) {
          return;
        }

        try {
          await ref.read(urlCleanerCatalogServiceProvider.future);
        } catch (e, s) {
          logger.w(
            'Failed preloading URL cleaner catalog',
            error: e,
            stackTrace: s,
          );
        }
      }

      unawaited(preloadUrlCleanerCatalog());

      // Wire settings → local_index_setting (tab.db) so the trigger gate
      // is in sync from the moment tabs start writing.
      ref.read(localIndexSettingsSyncProvider);

      // Cold-start prune of the local search index — drops rows the engine
      // has forgotten (Places retention, user-initiated clears). Cheap and
      // background; failures are logged and ignored.
      unawaited(ref.read(localIndexPrunerProvider.notifier).prune());

      // Claim this profile's pre-qualification secure records before anything
      // reads them — the account handler below reads one of them, and until this
      // has run the legacy unqualified copy is still what is on disk.
      await migrateSecureStorageForActiveProfile(
        ref.read(singboxProxyProfilesRepositoryProvider.notifier),
      );

      // Activate account callback deep link handler
      ref.read(accountCallbackHandlerProvider);

      // Listen for "restart into the shortcut's profile" from the native
      // mismatch dialog. Only this isolate can shut the profile down cleanly.
      ref.read(profileRestartRequestHandlerProvider);

      // Every consumer of `allIntents` has to exist before the broker is drained.
      // The stream is a broadcast stream, so a replayed launch added to it with
      // nothing subscribed is dropped — and then acknowledged, which is exactly
      // the silent loss the broker exists to prevent. The account-callback and
      // restart-request consumers are alive from the two reads above; these two
      // are otherwise built by the browser widget, far too late.
      ref.read(sharingIntentStreamProvider);
      ref.read(appWidgetLaunchStreamProvider);
      await ref.read(brokeredIntentDeliveryProvider.future);

      // Bring up the proxy connections flagged for autostart. Their SOCKS
      // endpoints reach Gecko through the routing snapshot mounted above, and
      // this is left unawaited so a slow Tor bootstrap can't stall startup —
      // tabs that need one of these connections wait on the pending start
      // instead of prompting, and stay blocked until it resolves.
      unawaited(ref.read(proxyAutostartServiceProvider.notifier).run());

      if (!kDebugMode) {
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
      }
    });

    final corePaletteSnapshot = useFuture(
      useMemoized(() => DynamicColorPlugin.getCorePalette()),
    );

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          final corePalette = corePaletteSnapshot.data;

          // On Android S+ devices, use the provided dynamic color scheme.
          // (Recommended) Harmonize the dynamic color scheme' built-in semantic colors.
          final harmonizedLight = lightDynamic.harmonized();
          final harmonizedDark = darkDynamic.harmonized();

          // Workaround for https://github.com/material-foundation/flutter-packages/issues/649
          // dynamic_color package returns broken surfaceContainer* colors.
          // Fix them using the neutral tonal palette from CorePalette.
          if (corePalette != null) {
            lightColorScheme = _hasBrokenSurfaceContainerColors(harmonizedLight)
                ? _fixSurfaceContainerColors(
                    harmonizedLight,
                    corePalette.neutral,
                    Brightness.light,
                  )
                : harmonizedLight;
            darkColorScheme = _hasBrokenSurfaceContainerColors(harmonizedDark)
                ? _fixSurfaceContainerColors(
                    harmonizedDark,
                    corePalette.neutral,
                    Brightness.dark,
                  )
                : harmonizedDark;
          } else {
            lightColorScheme = harmonizedLight;
            darkColorScheme = harmonizedDark;
          }
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

        if (pureBlack) {
          darkColorScheme = _applyPureBlackSurfaces(darkColorScheme);
        }

        return MainApp(
          key: rootKey,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            pageTransitionsTheme: disableAnimations
                ? _noAnimationPageTransitionsTheme
                : null,
            dialogTheme: DialogThemeData(
              barrierColor: showModalBarrier ? null : Colors.transparent,
            ),
            bottomSheetTheme: BottomSheetThemeData(
              modalBarrierColor: showModalBarrier ? null : Colors.transparent,
            ),
            extensions: const <ThemeExtension<dynamic>>[AppColors.light],
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            pageTransitionsTheme: disableAnimations
                ? _noAnimationPageTransitionsTheme
                : null,
            dialogTheme: DialogThemeData(
              barrierColor: showModalBarrier ? null : Colors.transparent,
            ),
            bottomSheetTheme: BottomSheetThemeData(
              modalBarrierColor: showModalBarrier ? null : Colors.transparent,
            ),
            extensions: <ThemeExtension<dynamic>>[
              if (pureBlack) AppColors.darkOled else AppColors.dark,
            ],
          ),
          themeMode: themeMode,
          uiScaleFactor: uiScaleFactor,
          disableAnimations: disableAnimations,
        );
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (e) {
    logger.e(e.toString(), error: e.exception, stackTrace: e.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logger.e('Unhandled Error', error: error, stackTrace: stack);
    return true;
  };

  await RustLib.init();

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

  // The host is the root, not the app. Nothing below it may exist before the
  // native arbiter has committed a profile and `filesystem.activate()` has bound
  // it: a `ProviderScope` opens databases, and the background-fetch headless task
  // would let a second isolate open the same ones from outside the decision.
  runApp(
    StartupPhaseHost(
      onActivated: () async {
        if (!kDebugMode) {
          await BackgroundFetch.registerHeadlessTask(backgroundFetch);
        }
      },
      appBuilder: (context) => const ProviderScope(
        observers: [ErrorObserver()],
        child: _MainWidget(),
      ),
    ),
  );
}
