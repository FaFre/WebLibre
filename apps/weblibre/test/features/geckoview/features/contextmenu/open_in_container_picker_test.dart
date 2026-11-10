import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/candidates/open_in_container.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/animated_tab_type_switcher.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/gecko_inference.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class _Tabs extends TabRepository {
  final opened = <(TabMode, TabContainerSelection)>[];

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
    opened.add((tabMode, containerSelection));
    return 'new';
  }
}

final _work = ContainerDataWithCount(
  id: 'W',
  name: 'Work',
  color: const Color(0xFF2196F3),
  orderKey: 'w',
  tabCount: 0,
);

Future<_Tabs> _pumpMenu(WidgetTester tester, TabMode pageMode) async {
  final tabs = _Tabs();
  final router = GoRouter(
    initialLocation: '/menu',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(),
        routes: [
          GoRoute(
            path: 'menu',
            builder: (context, state) => Scaffold(
              body: OpenInContainer(
                hitResult: UnknownHitResult(src: 'https://example.com/'),
                sourceTabId: 'page',
              ),
            ),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tabStateProvider.overrideWith(
          (ref, tabId) => tabId == null
              ? null
              : TabState.$default(tabId).copyWith(tabMode: pageMode),
        ),
        tabRepositoryProvider.overrideWith(() => tabs),
        generalSettingsWithDefaultsProvider.overrideWith(
          (ref) => GeneralSettings.withDefaults(),
        ),
        watchContainersWithCountProvider.overrideWith(
          (ref) => Stream.value([_work]),
        ),
        // The loading placeholders read their tabs to name and count them.
        containerTopicProvider.overrideWith(
          (ref, containerId) => Future.value(),
        ),
        containerTabCountProvider.overrideWith(
          (ref, filter) => Future.value(0),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );

  await tester.tap(find.text('Open in container'));
  await tester.pumpAndSettle();
  return tabs;
}

bool _isSelected(WidgetTester tester, TabType type) =>
    tester
        .widget<AnimatedTabTypeSwitcher>(find.byType(AnimatedTabTypeSwitcher))
        .selected ==
    type;

void main() {
  testWidgets('the sheet starts on the page kind of tab and opens the kind '
      'switched to', (tester) async {
    final tabs = await _pumpMenu(tester, TabMode.regular);

    expect(_isSelected(tester, TabType.regular), isTrue);

    await tester.tap(find.byIcon(MdiIcons.dominoMask));
    await tester.pumpAndSettle();
    expect(_isSelected(tester, TabType.private), isTrue);

    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();

    final (mode, selection) = tabs.opened.single;
    expect(mode, isA<PrivateTabMode>());
    expect(
      selection,
      isA<SpecificContainerTabSelection>().having(
        (s) => s.container.id,
        'container',
        'W',
      ),
    );
  });

  testWidgets("an isolated page's own kind keeps its isolation group", (
    tester,
  ) async {
    final pageMode = TabMode.newIsolated();
    final tabs = await _pumpMenu(tester, pageMode);

    expect(_isSelected(tester, TabType.isolated), isTrue);

    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();

    final (mode, _) = tabs.opened.single;
    expect(mode, pageMode);
  });
}
