import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_list_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_view_filter_options.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

/// A tree in the unassigned container:
///
///   a          (root)
///   b          (root)
///   └─ b1      (child of b)
///   c          (root)
///
/// `order_key` runs a < b < b1 < c, so oldest-first renders them in that order.
final _rows = [
  _row(id: 'a', orderKey: 'a', rootId: 'a'),
  _row(id: 'b', orderKey: 'b', rootId: 'b'),
  _row(id: 'b1', orderKey: 'c', rootId: 'b', parentId: 'b', depth: 1),
  _row(id: 'c', orderKey: 'd', rootId: 'c'),
];

TabsWithRootAndDepthResult _row({
  required String id,
  required String orderKey,
  required String rootId,
  String? parentId,
  int depth = 0,
}) => TabsWithRootAndDepthResult(
  id: id,
  parentId: parentId,
  orderKey: orderKey,
  rootId: rootId,
  depth: depth,
);

TabSortKeys _sortKeys(String title, {TabMode mode = const RegularTabMode()}) =>
    TabSortKeys(
      tabMode: mode,
      titleOrAuthority: title,
      url: 'https://$title.example',
    );

void main() {
  ProviderContainer makeContainer({
    TabViewFilterOptions? filterOptions,
    Set<String> collapsed = const {},
    Set<String> pinned = const {},
    Map<String, TabSortKeys>? sortKeys,
    TabDirection tabListDirection = TabDirection.oldestFirst,
    TabDirection tabBarDirection = TabDirection.oldestFirst,
    List<TabsWithRootAndDepthResult>? rows,
  }) {
    final container = ProviderContainer(
      overrides: [
        watchTabsWithRootAndDepthProvider(
          null,
        ).overrideWith((ref) => Stream.value(rows ?? _rows)),
        tabListProvider.overrideWith(
          () => _FakeTabList((rows ?? _rows).map((row) => row.id).toList()),
        ),
        tabSortKeysProvider.overrideWith(
          (ref) => EquatableValue(
            sortKeys ??
                {
                  'a': _sortKeys('alpha'),
                  'b': _sortKeys('bravo'),
                  'b1': _sortKeys('bravo-child'),
                  'c': _sortKeys('charlie'),
                },
          ),
        ),
        watchPinnedTabIdsProvider.overrideWith((ref) => Stream.value(pinned)),
        watchTabTimestampsProvider.overrideWith(
          (ref) => Stream.value(const <String, DateTime>{}),
        ),
        generalSettingsWithDefaultsProvider.overrideWith(
          (ref) => GeneralSettings.withDefaults(
            tabListDirection: tabListDirection,
            tabBarDirection: tabBarDirection,
            sequentialTabNavigationCrossContainers: false,
          ),
        ),
        tabViewFilterControllerProvider.overrideWith(
          () => _FakeFilterController(
            filterOptions ?? TabViewFilterOptions.withDefaults(),
          ),
        ),
        collapsedGroupsProvider.overrideWith(
          () => _FakeCollapsedGroups(collapsed),
        ),
        selectedContainerProvider.overrideWith(() => _FakeSelectedContainer()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Reads an order once its underlying streams have delivered.
  Future<List<String>> readOrder(
    ProviderContainer container,
    TabListScope scope,
  ) async {
    final provider = visibleTabListItemsProvider(
      containerId: null,
      scope: scope,
    );
    container.listen(provider, (_, _) {}, fireImmediately: true);
    await Future<void>.delayed(Duration.zero);
    return container.read(provider).value.map((item) => item.tabId).toList();
  }

  Future<List<String>?> readNavigationOrder(ProviderContainer container) async {
    container.listen(
      sequentialTabNavigationOrderProvider,
      (_, _) {},
      fireImmediately: true,
    );
    await Future<void>.delayed(Duration.zero);
    return container.read(sequentialTabNavigationOrderProvider).value;
  }

  group('presentation scope ignores tray-only state', () {
    test('the baseline order groups children under their parent', () async {
      final container = makeContainer();

      expect(await readOrder(container, TabListScope.presentation), [
        'a',
        'b',
        'b1',
        'c',
      ]);
    });

    test(
      'a tab-type filter hides rows in the tray but not outside it',
      () async {
        final container = makeContainer(
          filterOptions: TabViewFilterOptions.withDefaults().copyWith
              .tabTypeFilter(TabTypeFilter.privateOnly),
          sortKeys: {
            'a': _sortKeys('alpha'),
            'b': _sortKeys('bravo', mode: const PrivateTabMode()),
            'b1': _sortKeys('bravo-child'),
            'c': _sortKeys('charlie'),
          },
        );

        expect(await readOrder(container, TabListScope.tray), ['b']);
        expect(await readOrder(container, TabListScope.presentation), [
          'a',
          'b',
          'b1',
          'c',
        ]);
      },
    );

    test('a collapsed group folds rows away in the tray only', () async {
      final container = makeContainer(collapsed: {'b'});

      expect(await readOrder(container, TabListScope.tray), ['a', 'b', 'c']);
      expect(await readOrder(container, TabListScope.presentation), [
        'a',
        'b',
        'b1',
        'c',
      ]);
    });

    test('the tray sort reorders the tray only', () async {
      final container = makeContainer(
        filterOptions: TabViewFilterOptions.withDefaults().copyWith.sortType(
          TabSortType.titleDesc,
        ),
      );

      expect(await readOrder(container, TabListScope.tray), [
        'c',
        'b',
        'b1',
        'a',
      ]);
      expect(await readOrder(container, TabListScope.presentation), [
        'a',
        'b',
        'b1',
        'c',
      ]);
    });
  });

  group('direction', () {
    test('each scope follows its own direction setting', () async {
      final container = makeContainer(
        tabListDirection: TabDirection.oldestFirst,
        tabBarDirection: TabDirection.newestFirst,
      );

      expect(await readOrder(container, TabListScope.tray), [
        'a',
        'b',
        'b1',
        'c',
      ]);
      // Root groups reverse; a parent still precedes its own child.
      expect(await readOrder(container, TabListScope.presentation), [
        'c',
        'b',
        'b1',
        'a',
      ]);
    });
  });

  group('pinned handling', () {
    test(
      'a pinned child leads the presentation order but stays grouped in the tray',
      () async {
        // The stock configuration: hierarchy on, pinned-first on. This is the
        // pair that disagreed in issue #603 — the bar hoisted the pinned child
        // while navigation kept walking it inside its group.
        final container = makeContainer(pinned: {'b1'});

        expect(await readOrder(container, TabListScope.tray), [
          'a',
          'b',
          'b1',
          'c',
        ]);
        expect(await readOrder(container, TabListScope.presentation), [
          'b1',
          'a',
          'b',
          'c',
        ]);
      },
    );
  });

  group('sequentialTabNavigationOrder', () {
    test('matches the presentation order the switcher renders', () async {
      final container = makeContainer(
        filterOptions: TabViewFilterOptions.withDefaults().copyWith.sortType(
          TabSortType.titleDesc,
        ),
        collapsed: {'b'},
        pinned: {'b1'},
      );

      final rendered = await readOrder(container, TabListScope.presentation);
      final navigation = await readNavigationOrder(container);

      expect(navigation, rendered);
      // ...and specifically not the tray's, which all three tray controls moved.
      expect(navigation, isNot(await readOrder(container, TabListScope.tray)));
    });

    test('reaches every tab, so no swipe can skip one', () async {
      final container = makeContainer(collapsed: {'b'}, pinned: {'b1'});

      expect(
        (await readNavigationOrder(container))?.toSet(),
        _rows.map((row) => row.id).toSet(),
      );
    });
  });
}

class _FakeTabList extends TabList {
  _FakeTabList(this.ids);

  final List<String> ids;

  @override
  EquatableValue<List<String>> build() => EquatableValue(ids);
}

class _FakeFilterController extends TabViewFilterController {
  _FakeFilterController(this.options);

  final TabViewFilterOptions options;

  @override
  TabViewFilterOptions build() => options;
}

class _FakeCollapsedGroups extends CollapsedGroups {
  _FakeCollapsedGroups(this.collapsed);

  final Set<String> collapsed;

  @override
  Set<String> build() => collapsed;
}

class _FakeSelectedContainer extends SelectedContainer {
  @override
  String? build() => null;
}
