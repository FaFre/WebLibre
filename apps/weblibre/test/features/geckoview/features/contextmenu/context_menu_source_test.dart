import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/utils/context_menu_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';

class _SelectedTab extends SelectedTab {
  @override
  String? build() => 'a';
}

final _containerB = ContainerData(
  id: 'B',
  color: const Color(0xFF000000),
  orderKey: 'b',
);

class _TabData extends TabDataRepository {
  @override
  void build() {}

  @override
  Future<ContainerData?> getTabContainerData(String tabId) async =>
      tabId == 'b' ? _containerB : null;
}

void main() {
  // The menu was opened in pane `b` while `a` is the selected tab.
  Future<WidgetRef> pumpRef(WidgetTester tester) async {
    late WidgetRef captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedTabProvider.overrideWith(_SelectedTab.new),
          tabStateProvider.overrideWith(
            (ref, tabId) => tabId == null ? null : TabState.$default(tabId),
          ),
          tabDataRepositoryProvider.overrideWith(_TabData.new),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            captured = ref;
            return const SizedBox();
          },
        ),
      ),
    );
    return captured;
  }

  testWidgets('reads the tab the menu was opened in', (tester) async {
    final ref = await pumpRef(tester);

    expect(readContextMenuSourceTab(ref, 'b')?.id, 'b');
  });

  testWidgets("a tab opened from the other pane goes to that pane's "
      'container', (tester) async {
    final ref = await pumpRef(tester);

    final fromOtherPane = await contextMenuContainerSelection(ref, 'b');
    expect(
      fromOtherPane,
      isA<PreferredContainerTabSelection>().having(
        (s) => s.container?.id,
        'container',
        'B',
      ),
    );

    // From the selected tab nothing changes: the selected container, as
    // always.
    expect(
      await contextMenuContainerSelection(ref, 'a'),
      isA<UseSelectedContainerTabSelection>(),
    );
  });
}
