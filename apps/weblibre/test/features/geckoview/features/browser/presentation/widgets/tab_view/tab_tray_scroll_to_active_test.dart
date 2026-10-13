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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_tray_scroll_to_active.dart';

const _itemExtent = 50.0;
const _viewport = 400.0;

/// A tray list of [tabIds] with [activeTabId] kept in view.
class _Tray extends HookWidget {
  final ScrollController controller;
  final List<String> tabIds;
  final String? activeTabId;

  /// Whether the list is built, and [controller] attached to it.
  final bool attached;

  const _Tray({
    required this.controller,
    required this.tabIds,
    required this.activeTabId,
    this.attached = true,
  });

  @override
  Widget build(BuildContext context) {
    final index = activeTabId == null ? -1 : tabIds.indexOf(activeTabId!);

    useScrollToActiveTab(
      scrollController: controller,
      activeTabId: activeTabId,
      activeItemStart: index < 0 ? null : index * _itemExtent,
      itemExtent: _itemExtent,
      disableAnimations: false,
    );

    if (!attached) return const SizedBox();

    return ListView.builder(
      controller: controller,
      itemExtent: _itemExtent,
      itemCount: tabIds.length,
      itemBuilder: (context, index) => Text(tabIds[index]),
    );
  }
}

void main() {
  final tabs = [for (var i = 0; i < 40; i++) 'tab$i'];

  Future<void> pumpTray(
    WidgetTester tester,
    ScrollController controller, {
    required List<String> tabIds,
    required String? activeTabId,
    bool attached = true,
  }) {
    return tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            height: _viewport,
            child: _Tray(
              controller: controller,
              tabIds: tabIds,
              activeTabId: activeTabId,
              attached: attached,
            ),
          ),
        ),
      ),
    );
  }

  /// Where the hook centres the tab at [index].
  double centred(int index) =>
      index * _itemExtent - _viewport / 2 + _itemExtent / 2;

  testWidgets('opens centred on the active tab without scrolling to it', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await pumpTray(tester, controller, tabIds: tabs, activeTabId: 'tab20');
    // One frame: the jump lands in the post-frame callback, no animation.
    await tester.pump();

    expect(controller.offset, centred(20));
  });

  testWidgets('closing a tab leaves the list where it was', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await pumpTray(tester, controller, tabIds: tabs, activeTabId: 'tab20');
    await tester.pump();

    // The user scrolls away from the active tab and closes one there.
    controller.jumpTo(1000);
    await tester.pump();
    await pumpTray(
      tester,
      controller,
      tabIds: [...tabs]..remove('tab3'),
      activeTabId: 'tab20',
    );
    await tester.pumpAndSettle();

    expect(controller.offset, 1000);
  });

  testWidgets('a newly active tab already in view does not move the list', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await pumpTray(tester, controller, tabIds: tabs, activeTabId: 'tab20');
    await tester.pump();
    final before = controller.offset;

    await pumpTray(tester, controller, tabIds: tabs, activeTabId: 'tab22');
    await tester.pumpAndSettle();

    expect(controller.offset, before);
  });

  testWidgets('a newly active tab out of view is brought to it', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await pumpTray(tester, controller, tabIds: tabs, activeTabId: 'tab20');
    await tester.pump();

    await pumpTray(tester, controller, tabIds: tabs, activeTabId: 'tab2');
    await tester.pumpAndSettle();

    expect(controller.offset, 0);
  });

  testWidgets('waits for the active tab to be listed', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    // The rows load after the tray opens.
    await pumpTray(tester, controller, tabIds: const [], activeTabId: 'tab30');
    await tester.pump();
    await pumpTray(tester, controller, tabIds: tabs, activeTabId: 'tab30');
    await tester.pump();

    expect(controller.offset, centred(30));
  });

  testWidgets('waits for the list to be attached', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    // The view is swapped in a frame after the rows are known.
    await pumpTray(
      tester,
      controller,
      tabIds: tabs,
      activeTabId: 'tab20',
      attached: false,
    );
    await tester.pump();
    await pumpTray(tester, controller, tabIds: tabs, activeTabId: 'tab20');
    await tester.pump();

    expect(controller.offset, centred(20));
  });
}
