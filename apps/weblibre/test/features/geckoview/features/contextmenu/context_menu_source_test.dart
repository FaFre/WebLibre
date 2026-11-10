import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/presentation/utils/context_menu_source.dart';

void main() {
  testWidgets('reads the tab the menu was opened in', (tester) async {
    late WidgetRef ref;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tabStateProvider.overrideWith(
            (ref, tabId) => tabId == null ? null : TabState.$default(tabId),
          ),
        ],
        child: Consumer(
          builder: (context, captured, _) {
            ref = captured;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(readContextMenuSourceTab(ref, 'b')?.id, 'b');
  });
}
