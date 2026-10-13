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
import 'package:weblibre/features/geckoview/features/history/domain/repositories/container_history.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/hidden_history_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/history_suggestion_menu.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

const _url = 'https://www.example.com/page';

/// Records deletions instead of reaching Places.
class _FakeContainerHistoryRepository extends ContainerHistoryRepository {
  _FakeContainerHistoryRepository(this.deleted);

  final List<String> deleted;

  @override
  Future<void> deleteUrl(String url) async => deleted.add(url);
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<(List<String>, ProviderContainer)> pumpRow(WidgetTester tester) async {
    final deleted = <String>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          containerHistoryRepositoryProvider.overrideWith(
            () => _FakeContainerHistoryRepository(deleted),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                final hidden = ref.watch(hiddenHistorySuggestionsProvider);
                if (hidden.contains(historySuggestionKey(_url))) {
                  return const SizedBox.shrink();
                }
                return HistorySuggestionMenu(
                  url: _url,
                  builder: (onLongPress) => ListTile(
                    title: const Text('Example'),
                    onTap: () {},
                    onLongPress: onLongPress,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    return (
      deleted,
      ProviderScope.containerOf(tester.element(find.byType(Scaffold))),
    );
  }

  Future<void> deleteRow(WidgetTester tester) async {
    await tester.longPress(find.text('Example'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.search_actionDeleteFromHistory));
    await tester.pumpAndSettle();
  }

  testWidgets('the row leaves at once, the visits only with the Undo', (
    tester,
  ) async {
    final (deleted, _) = await pumpRow(tester);

    await deleteRow(tester);

    expect(find.text('Example'), findsNothing);
    expect(find.text(l10n.search_deletedFromHistory('example.com')), findsOne);
    expect(deleted, isEmpty);

    // The snackbar times out.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(deleted, [_url]);
    expect(find.text('Example'), findsNothing);
  });

  testWidgets('Undo brings the row back and deletes nothing', (tester) async {
    final (deleted, container) = await pumpRow(tester);

    await deleteRow(tester);
    await tester.tap(find.text(l10n.common_undo));
    await tester.pumpAndSettle();

    expect(find.text('Example'), findsOne);
    expect(container.read(hiddenHistorySuggestionsProvider), isEmpty);

    await tester.pump(const Duration(seconds: 5));
    expect(deleted, isEmpty);
  });

  test('a page is hidden by its canonical address', () {
    expect(
      historySuggestionKey('https://www.example.com/page'),
      historySuggestionKey('https://www.example.com/page#section'),
    );
  });
}
