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
import 'package:search_protocol/search_protocol.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/web_search/domain/controllers/search_controller.dart';
import 'package:weblibre/features/web_search/presentation/open_in_new_tab.dart';
import 'package:weblibre/features/web_search/presentation/screens/page_preview.dart';

import '../../test_harness.dart';

const _testOpenTarget = WebSearchOpenTarget(
  tabMode: RegularTabMode(),
  containerSelection: TabContainerSelection.unassigned(),
);

void main() {
  testWidgets('renders markdown for a fetched document', (tester) async {
    const url = 'https://example.com/article';
    final opener = _FakeWebSearchTabOpener();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...webSearchTestOverrides(),
          metaSearchControllerProvider.overrideWithValue(
            MetaSearchState(
              status: WebSearchStatus.ready,
              query: 'lensai',
              results: [
                CompactSearchResult(
                  title: 'LensAI article',
                  url: Uri.parse(url),
                ),
              ],
              documentsByUrl: {
                Uri.parse(url): FetchedDocument(
                  url: Uri.parse(url),
                  content: '# Heading\n\nBody copy',
                  metadata: PageMetadata(
                    title: 'LensAI article',
                    author: 'Fabian',
                  ),
                ),
              },
            ),
          ),
          webSearchTabOpenerProvider.overrideWithValue(opener),
          watchCachedIconBytesProvider.overrideWith((ref, origin) {
            return Stream.value(null);
          }),
        ],
        child: MaterialApp(
          home: PagePreviewScreen(
            uri: Uri.parse(url),
            resolveOpenTarget: () => _testOpenTarget,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Heading'), findsOneWidget);
    expect(find.text('Body copy'), findsOneWidget);
    expect(find.text('Fabian'), findsOneWidget);

    await tester.tap(find.byTooltip('Open in browser'));
    await tester.pump();

    expect(opener.openedUris, [Uri.parse(url)]);
  });
}

class _FakeWebSearchTabOpener implements WebSearchTabOpener {
  final List<Uri> openedUris = <Uri>[];
  final List<String> openedCaptureIds = <String>[];

  @override
  Future<void> open(
    BuildContext context,
    WidgetRef ref,
    Uri uri, {
    required WebSearchOpenTarget target,
  }) async {
    openedUris.add(uri);
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
    openedCaptureIds.add(captureId);
  }
}
