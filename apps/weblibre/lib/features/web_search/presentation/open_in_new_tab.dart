import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/features/web_search/domain/services/capture_server.dart';

/// Parameters describing where a web-search-opened tab should land.
///
/// The search screen owns the user-visible selectors (tab type, container,
/// parent for child tabs) and threads them through here so the result-card
/// open path honours them — historically this path inherited the *currently
/// selected* tab's mode/container instead, ignoring the search UI.
class WebSearchOpenTarget {
  final TabMode tabMode;
  final TabContainerSelection containerSelection;
  final String? parentId;

  const WebSearchOpenTarget({
    required this.tabMode,
    required this.containerSelection,
    this.parentId,
  });
}

abstract interface class WebSearchTabOpener {
  Future<void> open(
    BuildContext context,
    WidgetRef ref,
    Uri uri, {
    required WebSearchOpenTarget target,
  });

  Future<void> openCapture(
    BuildContext context,
    WidgetRef ref, {
    required String captureId,
    required Uri sourceUrl,
    required WebSearchOpenTarget target,
    String? contentType,
    String? method,
    String? variant,
  });
}

final webSearchTabOpenerProvider = Provider<WebSearchTabOpener>(
  (ref) => const _DefaultWebSearchTabOpener(),
);

final class _DefaultWebSearchTabOpener implements WebSearchTabOpener {
  const _DefaultWebSearchTabOpener();

  @override
  Future<void> open(
    BuildContext context,
    WidgetRef ref,
    Uri uri, {
    required WebSearchOpenTarget target,
  }) async {
    await ref
        .read(tabRepositoryProvider.notifier)
        .addTab(
          url: uri,
          tabMode: target.tabMode,
          parentId: target.parentId,
          promptOnBackBehavior: ReturnToSearchTabBackPromptBehavior(
            tabType: target.tabMode.toTabType(),
          ),
          selectTab: true,
          containerSelection: target.containerSelection,
        );

    // Push (not go/replace) so the SearchRoute stays underneath. Pressing
    // back from the freshly opened tab pops back to the search results
    // instead of closing the tab. metaSearchControllerProvider is
    // keepAlive, so results survive the navigation either way.
    if (context.mounted) {
      const BrowserRoute().go(context);
    }
  }

  @override
  Future<void> openCapture(
    BuildContext context,
    WidgetRef ref, {
    required String captureId,
    required Uri sourceUrl,
    required WebSearchOpenTarget target,
    String? contentType,
    String? method,
    String? variant,
  }) async {
    // Never navigate to the real sourceUrl — Gecko's app-link resolution
    // (e.g. github.com triggers the "Open in GitHub app?" dialog) fires
    // before our interceptor can redirect, and a cancel falls back to
    // loading the live site. Load the loopback capture URL directly.
    final captureUrl = await ref.read(captureServerProvider).publish(captureId);

    final tabId = await ref
        .read(tabRepositoryProvider.notifier)
        .addTab(
          url: captureUrl,
          tabMode: target.tabMode,
          parentId: target.parentId,
          containerSelection: target.containerSelection,
          promptOnBackBehavior: ReturnToSearchTabBackPromptBehavior(
            tabType: target.tabMode.toTabType(),
          ),
          selectTab: true,
          startLoading: false,
        );

    // Always register the capture root — even for PDF / PNG. The capture_tab
    // DAO row is what (a) tells Kotlin's middleware to treat this tab as a
    // sandbox tab so out-of-origin link navigations get intercepted, and
    // (b) backs the address bar's source-URL display so the loopback URL
    // doesn't leak. PDF and PNG viewers don't follow links in practice, so
    // the extra interception is harmless.
    await ref
        .read(sandboxCaptureControllerProvider.notifier)
        .registerRootCapture(
          tabId: tabId,
          receipt: CapturedPageReceiptLike(
            captureId: captureId,
            sourceUrl: sourceUrl,
          ),
          method: method,
          variant: variant,
        );

    await ref
        .read(tabSessionProvider(tabId: tabId).notifier)
        .loadUrl(url: captureUrl);

    if (context.mounted) {
      const BrowserRoute().go(context);
    }
  }
}
