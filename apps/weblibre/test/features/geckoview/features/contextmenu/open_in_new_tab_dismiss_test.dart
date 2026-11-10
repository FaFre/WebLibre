import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/open_new_tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class _SelectedTab extends SelectedTab {
  @override
  String? build() => 'a';
}

class _Tabs extends TabRepository {
  final opened = <(Uri?, String?, TabContainerSelection)>[];

  /// The tab stays opening until this completes.
  final opening = Completer<void>();

  @override
  void build() {}

  @override
  Future<String> addTab({
    required TabMode tabMode,
    Uri? url,
    required bool selectTab,
    bool startLoading = true,
    String? parentId,
    LoadUrlFlags flags = LoadUrlFlags.NONE,
    Source source = Internal.newTab,
    HistoryMetadataKey? historyMetadata,
    Map<String, String>? additionalHeaders,
    TabContainerSelection containerSelection =
        const TabContainerSelection.useSelected(),
    bool launchedFromIntent = false,
    TabBackBehavior? onBackBehavior,
    void Function(String tabId)? onCreated,
    bool parentIsReferrer = true,
  }) async {
    opened.add((url, parentId, containerSelection));
    await opening.future;
    return 'new';
  }
}

void main() {
  testWidgets("a link from the other pane opens in that pane's page "
      'container, and the menu can go away while it opens', (tester) async {
    final tabs = _Tabs();
    final show = ValueNotifier(true);
    addTearDown(show.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedTabProvider.overrideWith(_SelectedTab.new),
          tabStateProvider.overrideWith(
            (ref, tabId) => tabId == null ? null : TabState.$default(tabId),
          ),
          tabRepositoryProvider.overrideWith(() => tabs),
          generalSettingsWithDefaultsProvider.overrideWith(
            (ref) => GeneralSettings.withDefaults(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ValueListenableBuilder(
              valueListenable: show,
              builder: (context, visible, _) => visible
                  ? OpenInNewTab(
                      hitResult: UnknownHitResult(src: 'https://example.com/'),
                      sourceTabId: 'b',
                    )
                  : const SizedBox(),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open in new tab'));
    // The menu goes away while the tab is opening.
    show.value = false;
    await tester.pump();

    tabs.opening.complete();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(tabs.opened, hasLength(1));
    final (url, parentId, selection) = tabs.opened.single;
    expect(url, Uri.parse('https://example.com/'));
    expect(parentId, 'b');
    expect(
      selection,
      isA<OpenedFromTabContainerSelection>().having(
        (s) => s.tabId,
        'tabId',
        'b',
      ),
    );
  });
}
