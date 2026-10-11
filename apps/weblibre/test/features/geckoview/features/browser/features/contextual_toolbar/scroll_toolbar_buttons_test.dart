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
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_id.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_spec.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/models/contextual_toolbar_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/toolbar_button_registry.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

const _tabId = 'tab';

/// [TabSession] without Gecko, recording the scrolls it is asked for.
class _RecordingTabSession extends TabSession {
  _RecordingTabSession(this.scrolls);

  final List<String> scrolls;

  @override
  void build({required String? tabId}) {}

  @override
  Future<void> scrollToTop() async => scrolls.add('top');

  @override
  Future<void> scrollToBottom() async => scrolls.add('bottom');
}

/// Pumps the toolbar button [id] for a page in [_tabId], recording the
/// scrolls it asks that page's session for into [scrolls].
Future<void> _pumpButton(
  WidgetTester tester,
  ToolbarButtonId id,
  List<String> scrolls,
) {
  final definition = toolbarButtonRegistryById[id.name]!;
  final scope = ContextualToolbarScope(
    selectedTabId: _tabId,
    displayedSheet: null,
    tabState: null,
    isPreview: false,
  );

  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        tabSessionProvider(
          tabId: _tabId,
        ).overrideWith(() => _RecordingTabSession(scrolls)),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: Consumer(
              builder: (context, ref, _) =>
                  definition.builder(scope, context, ref),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  test('every toolbar button has a spec and a definition', () {
    expect(
      toolbarButtonSpecs.map((spec) => spec.id),
      unorderedEquals(ToolbarButtonId.values),
    );
    expect(
      toolbarButtonRegistry.map((definition) => definition.spec.id),
      unorderedEquals(ToolbarButtonId.values),
    );
  });

  test('scroll to top and bottom start hidden and fill no gaps', () {
    for (final spec in [
      scrollTopToolbarButtonSpec,
      scrollBottomToolbarButtonSpec,
    ]) {
      expect(spec.defaultVisible, isFalse);
      expect(spec.canBeFallbackTarget, isFalse);
    }
  });

  testWidgets('Scroll to Top jumps to the top of the page', (tester) async {
    final scrolls = <String>[];
    await _pumpButton(tester, ToolbarButtonId.scrollTop, scrolls);

    expect(find.byTooltip('Scroll to Top'), findsOne);
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(scrolls, ['top']);
  });

  testWidgets('Scroll to Bottom jumps to the bottom of the page', (
    tester,
  ) async {
    final scrolls = <String>[];
    await _pumpButton(tester, ToolbarButtonId.scrollBottom, scrolls);

    expect(find.byTooltip('Scroll to Bottom'), findsOne);
    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(scrolls, ['bottom']);
  });
}
