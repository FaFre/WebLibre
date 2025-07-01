import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/router.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
GeckoSelectionActionService selectionActionService(Ref ref) {
  final service = GeckoSelectionActionService.setUp();

  unawaited(
    service.setActions([
      SearchAction((text) async {
        final router = await ref.read(routerProvider.future);
        final route = SearchRoute(
          tabType: ref.read(selectedTabTypeProvider) ?? TabType.regular,
          searchText: text,
        );

        await router.push(route.location);
      }),
      DefaultSearchAction((text) async {
        final defaultSearchBang = await ref.read(
          defaultSearchBangDataProvider.future,
        );

        if (defaultSearchBang != null) {
          final currentTab = ref.read(selectedTabStateProvider);

          await ref
              .read(tabRepositoryProvider.notifier)
              .addTab(
                url: defaultSearchBang.getTemplateUrl(text),
                parentId: currentTab?.id,
                private: currentTab?.isPrivate ?? false,
              );
        } else {
          logger.e('No default search bang found');
        }
      }),
      FindInPageAction((text) async {
        final tabId = ref.read(selectedTabProvider);
        if (tabId != null) {
          await ref
              .read(findInPageControllerProvider(tabId).notifier)
              .findAll(text: text);
        }
      }),
      ShareAction((text) async {
        await SharePlus.instance.share(ShareParams(text: text));
      }),
      CallAction((text) async {
        final uri = Uri.tryParse('tel:${text.replaceAll(' ', '')}');

        if (uri != null) {
          final canLaunch = await canLaunchUrl(uri);
          if (canLaunch) {
            await launchUrl(uri);
          }
        }
      }),
      EmailAction((text) async {
        final uri = Uri.tryParse('mailto:$text');

        if (uri != null) {
          final canLaunch = await canLaunchUrl(uri);
          if (canLaunch) {
            await launchUrl(uri);
          }
        }
      }),
    ]),
  );

  return service;
}

@Riverpod(keepAlive: true)
GeckoEventService eventService(Ref ref) {
  final service = GeckoEventService.setUp();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

@Riverpod(keepAlive: true)
GeckoAddonService addonService(Ref ref) {
  final service = GeckoAddonService.setUp();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

@Riverpod(keepAlive: true)
GeckoTabContentService tabContentService(Ref ref) {
  final service = GeckoTabContentService.setUp();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

@Riverpod(keepAlive: true)
GeckoSuggestionsService engineSuggestionsService(Ref ref) {
  final service = GeckoSuggestionsService.setUp();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

@Riverpod(keepAlive: true)
class EngineReadyState extends _$EngineReadyState {
  @override
  bool build() {
    final eventService = ref.watch(eventServiceProvider);

    final currentState =
        eventService.engineReadyStateEvents.valueOrNull ?? false;

    if (!currentState) {
      unawaited(
        eventService.engineReadyStateEvents
            .firstWhere((value) => value == true)
            .timeout(
              const Duration(seconds: 3),
              onTimeout: () {
                logger.w('Waiting for engine ready state timed out');
                return true;
              },
            )
            .whenComplete(() => state = true),
      );
    }

    final sub = eventService.engineReadyStateEvents.listen((value) {
      state = value;
    });

    ref.onDispose(() async {
      await sub.cancel();
    });

    return currentState;
  }
}
