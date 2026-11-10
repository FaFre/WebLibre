import 'dart:io';

import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/domain/services/generic_website.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/entities/browser_icon.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_pick_request.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view.dart';
import 'package:weblibre/features/geckoview/features/split_view/presentation/widgets/split_view_controls_sheet.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Records what the sheet asks for instead of acting.
class _FakeController extends SplitViewController {
  final calls = <String>[];

  @override
  SplitPair? build() =>
      SplitPair(pairId: 'p', firstTabId: 'a', secondTabId: 'b');

  @override
  void swap() => calls.add('swap');

  @override
  void end() => calls.add('end');

  @override
  void setFocusedOnly(bool focusedOnly) =>
      calls.add('focusedOnly:$focusedOnly');

  @override
  void setLayout(SplitLayoutPreference layout) =>
      calls.add('layout:${layout.name}');

  @override
  void equalize() => calls.add('equalize');

  @override
  Future<void> pair(
    String first,
    String second, {
    SplitPair? arrangement,
  }) async => calls.add('pair:$first,$second');
}

/// The focused page `a` is in container A; the selected container says
/// nothing about it.
class _FakeTabData extends TabDataRepository {
  @override
  void build() {}

  @override
  Future<ContainerData?> getTabContainerData(String tabId) async =>
      tabId == 'a' ? _containerA : null;
}

final _containerA = ContainerData(
  id: 'A',
  color: const Color(0xFF2196F3),
  orderKey: 'a',
);

class _FakeSelectedTab extends SelectedTab {
  @override
  String? build() => 'a';
}

class _FakeTabRepository extends TabRepository {
  final selected = <String>[];

  @override
  void build() {}

  @override
  Future<bool> selectTab(String tabId) async {
    selected.add(tabId);
    return true;
  }
}

class _NoIcons extends GenericWebsiteService {
  @override
  void build() {}

  @override
  Future<BrowserIcon?> getCachedIcon(Uri url) async => null;
}

const _titles = {
  'a': 'A page in the first pane with a title long enough to wrap',
  'b': 'Short',
  'c': 'Another open tab',
  'p': 'A private tab',
};

TabState _tab(String tabId, {TabMode tabMode = TabMode.regular}) =>
    TabState.$default(tabId).copyWith(
      title: _titles[tabId],
      url: Uri.parse('https://$tabId.example.org/path'),
      tabMode: tabMode,
    );

void main() {
  late _FakeController controller;
  late _FakeTabRepository tabs;
  late GoRouter router;
  late ProviderContainer container;

  Future<void> pumpSheet(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    double width = 800,
  }) async {
    // Most recently used first: the members, another regular tab and a
    // private one.
    final open = [
      _tab('c'),
      _tab('a'),
      _tab('p', tabMode: TabMode.private),
      _tab('b'),
    ];
    controller = _FakeController();
    tabs = _FakeTabRepository();
    router = GoRouter(
      initialLocation: '/browser',
      routes: [
        GoRoute(
          path: '/browser',
          builder: (context, state) => const Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: SplitViewControlsSheet(),
            ),
          ),
          routes: [
            GoRoute(
              path: 'search/:tabType/:searchText',
              builder: (context, state) => Text(
                'search beside ${state.uri.queryParameters['split-with-tab-id']}',
              ),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    // Tall enough that the sheet's initial 60% shows every entry.
    tester.view
      ..physicalSize = Size(width, 2000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(
      overrides: [
        splitViewControllerProvider.overrideWith(() => controller),
        splitPairShownProvider.overrideWith(
          (ref) => ref.watch(splitViewControllerProvider),
        ),
        selectedTabProvider.overrideWith(_FakeSelectedTab.new),
        tabRepositoryProvider.overrideWith(() => tabs),
        // Real titles and URLs, of different lengths so the rows differ
        // in height; the favicon lookups find nothing.
        tabStateProvider.overrideWith(
          (ref, tabId) => tabId == null ? null : _tab(tabId),
        ),
        fifoTabStatesProvider.overrideWith(
          (ref) => EquatableValue([for (final tab in open) (tab, null)]),
        ),
        watchTabContainerDataProvider.overrideWith(
          (ref, tabId) => Stream.value(null),
        ),
        sandboxSourceUriForTabProvider.overrideWith((ref, tabId) => null),
        genericWebsiteServiceProvider.overrideWith(_NoIcons.new),
        tabDataRepositoryProvider.overrideWith(_FakeTabData.new),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the focused page is the selected row, the other one '
      'focuses on tap', (tester) async {
    await pumpSheet(tester);

    bool rowSelected(String tabId) => tester
        .widgetList<Semantics>(
          find.ancestor(
            of: find.text(_titles[tabId]!),
            matching: find.byType(Semantics),
          ),
        )
        .any((semantics) => semantics.properties.selected == true);
    expect(rowSelected('a'), isTrue);
    expect(rowSelected('b'), isFalse);

    // `a` is focused, so tapping it does nothing.
    await tester.tap(find.text(_titles['a']!));
    expect(tabs.selected, isEmpty);
    await tester.tap(find.text(_titles['b']!));
    expect(tabs.selected, ['b']);
  });

  testWidgets('swap, layout, show only this page and equal sizes reach the '
      'controller', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.byTooltip('Swap sides'));
    await tester.tap(find.text('Stacked'));
    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(controller.calls, ['swap', 'layout:stacked', 'focusedOnly:true']);
    // Both ratios are 0.5 already.
    final equal = tester.widget<ListTile>(
      find.ancestor(
        of: find.text('Equal sizes'),
        matching: find.byType(ListTile),
      ),
    );
    expect(equal.enabled, isFalse);
  });

  testWidgets('End split view only ends the layout', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text('End split view'));
    await tester.pump();

    expect(controller.calls, ['end']);
    expect(find.text('Both tabs stay open'), findsOneWidget);
    expect(tabs.selected, isEmpty);
  });

  TabPickRequest openReplacementPicker() {
    final sheet = container.read(bottomSheetControllerProvider);
    expect(sheet, isA<TabPickerSheet>());
    return (sheet! as TabPickerSheet).request;
  }

  testWidgets('Replace other page opens the tab tray as a picker for the '
      'focused page', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text('Replace other page…'));
    await tester.pump();

    final request = openReplacementPicker();
    expect(request.title, 'Replace other page');
    expect(request.privateTabs, isFalse);
    expect(request.excludedTabIds, {'a', 'b'});
    // On the focused page's container, where a new page from it goes too.
    expect(request.initialContainer?.id, 'A');
  });

  testWidgets("a tab picked in the tray takes the other page's place and "
      'is focused', (tester) async {
    await pumpSheet(tester);
    await tester.tap(find.text('Replace other page…'));
    await tester.pump();

    openReplacementPicker().onPicked('c');
    await tester.pumpAndSettle();

    // The focused page keeps its side, the picked one takes the other.
    expect(controller.calls, ['pair:a,c']);
    expect(tabs.selected, ['c']);
    expect(container.read(bottomSheetControllerProvider), isNull);
  });

  testWidgets("the tray's new-tab button opens the search screen as a "
      'picker beside the focused page', (tester) async {
    await pumpSheet(tester);
    await tester.tap(find.text('Replace other page…'));
    await tester.pump();

    openReplacementPicker().onNewTab();
    await tester.pumpAndSettle();

    expect(container.read(bottomSheetControllerProvider), isNull);
    expect(find.text('search beside a'), findsOneWidget);
  });

  for (final scale in [1.0, 1.5, 2.0]) {
    testWidgets('page rows grow with the text (${scale}x) and the swap '
        'button stays on the line between them', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpSheet(tester, width: 360);

      expect(tester.takeException(), isNull);
      expect(find.text(_titles['a']!), findsOneWidget);
      // The URL breadcrumb of the shared tile.
      expect(find.text('b.example.org'), findsOneWidget);

      // Round, not a pill: as wide as it is high.
      final swapSize = tester.getSize(
        find.descendant(
          of: find.byTooltip('Swap sides'),
          matching: find.byType(InkWell),
        ),
      );
      expect(swapSize.width, swapSize.height);

      final divider = tester.getRect(find.byType(Divider));
      final swap = tester.getCenter(find.byTooltip('Swap sides'));
      expect(swap.dy, moreOrLessEquals(divider.center.dy, epsilon: 0.5));
      // The long title wraps, so the rows differ in height: the button
      // follows the divider, not the card's middle.
      final card = tester.getRect(
        find
            .ancestor(of: find.byType(Divider), matching: find.byType(Material))
            .first,
      );
      expect(divider.center.dy, isNot(moreOrLessEquals(card.center.dy)));
    });
  }

  group('at phone width with real glyph metrics', () {
    setUpAll(() async {
      final fonts =
          '${Platform.environment['FLUTTER_ROOT'] ?? _flutterRoot()}'
          '/bin/cache/artifacts/material_fonts';
      final loader = FontLoader('Roboto')
        ..addFont(_fontData('$fonts/Roboto-Regular.ttf'))
        ..addFont(_fontData('$fonts/Roboto-Medium.ttf'));
      await loader.load();
    });

    for (final locale in AppLocalizations.supportedLocales) {
      testWidgets(
        'layout labels stay on one line (${locale.toLanguageTag()})',
        (tester) async {
          await pumpSheet(tester, locale: locale, width: 360);

          final labels = find.descendant(
            of: find.byType(SegmentedButton<SplitLayoutPreference>),
            matching: find.byType(RichText),
          );
          expect(labels, findsNWidgets(3));
          for (final element in labels.evaluate()) {
            final paragraph = element.renderObject! as RenderParagraph;
            final text = paragraph.text.toPlainText();
            final lineTops = paragraph
                .getBoxesForSelection(
                  TextSelection(baseOffset: 0, extentOffset: text.length),
                )
                .map((box) => box.top)
                .toSet();
            expect(lineTops, hasLength(1), reason: '"$text" wraps');

            // Shrunk to fit, but still readable.
            final box = element
                .findAncestorRenderObjectOfType<RenderFittedBox>()!;
            expect(
              box.size.width / paragraph.size.width,
              greaterThanOrEqualTo(0.75),
              reason: '"$text" is shrunk too far',
            );
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}

/// `flutter test` sets FLUTTER_ROOT; otherwise walk up from
/// `<root>/bin/cache/artifacts/engine/<platform>/flutter_tester`.
String _flutterRoot() {
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 5; i++) {
    dir = dir.parent;
  }
  return dir.path;
}

Future<ByteData> _fontData(String path) async =>
    ByteData.sublistView(await File(path).readAsBytes());
