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
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:search_protocol/search_protocol.dart';
import 'package:weblibre/features/search_credits/data/models/web_search_settings.dart';
import 'package:weblibre/features/search_credits/domain/repositories/web_search_settings.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/web_search/domain/controllers/search_controller.dart';
import 'package:weblibre/features/web_search/presentation/widgets/search_result_card.dart';

import '../../test_harness.dart';

void main() {
  testWidgets('tapping a result uses the open callback', (tester) async {
    final openedUris = <Uri>[];
    const url = 'https://example.com/result';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...webSearchTestOverrides(),
          watchCachedIconBytesProvider.overrideWith((ref, origin) {
            return Stream.value(null);
          }),
          metaSearchControllerProvider.overrideWithValue(
            const MetaSearchState(status: WebSearchStatus.ready),
          ),
          webSearchSettingsControllerProvider.overrideWithValue(
            WebSearchSettings.withDefaults(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: WebSearchResultCard(
              result: CompactSearchResult(
                title: 'LensAI result',
                url: Uri.parse(url),
                content: 'Result summary',
              ),
              onOpen: (uri) async {
                openedUris.add(uri);
              },
              onFetch: (_) async {},
              onPreview: (_) async {},
              onOpenCapture: (_) async {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('LensAI result'));
    await tester.pump();

    expect(openedUris, [Uri.parse(url)]);
  });

  testWidgets(
    'renders thumbnail image when imgSrc is empty but thumbnail bytes exist',
    (tester) async {
      const thumbnailUrl = 'https://example.com/thumb.png';
      final pngBytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...webSearchTestOverrides(),
            watchCachedIconBytesProvider.overrideWith((ref, origin) {
              return Stream.value(null);
            }),
            metaSearchControllerProvider.overrideWithValue(
              MetaSearchState(
                status: WebSearchStatus.ready,
                imagesByUrl: {thumbnailUrl: Uint8List.fromList(pngBytes)},
              ),
            ),
            webSearchSettingsControllerProvider.overrideWithValue(
              WebSearchSettings.withDefaults(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: WebSearchResultCard(
                result: CompactSearchResult(
                  title: 'LensAI result',
                  url: Uri.parse('https://example.com/result'),
                  content: 'Result summary',
                  imgSrc: '',
                  thumbnail: thumbnailUrl,
                ),
                onOpen: (_) async {},
                onFetch: (_) async {},
                onPreview: (_) async {},
                onOpenCapture: (_) async {},
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Image), findsOneWidget);
    },
  );
}
