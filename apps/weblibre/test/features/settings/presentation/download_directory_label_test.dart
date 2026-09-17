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
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/settings/presentation/screens/general_settings.dart';

void main() {
  group('normalizeDownloadTreeUri', () {
    // The picker returns DocumentFile.fromTreeUri(...).uri, which is the folder
    // in its document form; the grant — and Mozilla's writer — only ever match
    // the tree URI it was built from.
    test('strips the document form the picker returns', () {
      expect(
        normalizeDownloadTreeUri(
          'content://com.android.externalstorage.documents/tree/'
          'primary%3ABooks/document/primary%3ABooks',
        ),
        'content://com.android.externalstorage.documents/tree/primary%3ABooks',
      );
    });

    test('leaves a tree URI alone', () {
      const uri =
          'content://com.android.externalstorage.documents/tree/primary%3ABooks';

      expect(normalizeDownloadTreeUri(uri), uri);
    });

    test('leaves a single-document URI alone', () {
      // No tree to fall back to, so trimming at /document/ would leave a bare
      // authority that addresses nothing.
      const uri = 'content://com.example.provider/document/42';

      expect(normalizeDownloadTreeUri(uri), uri);
    });

    test('keeps a nested folder id', () {
      expect(
        normalizeDownloadTreeUri(
          'content://com.android.externalstorage.documents/tree/'
          'primary%3ADownload%2FBooks/document/primary%3ADownload%2FBooks',
        ),
        'content://com.android.externalstorage.documents/tree/'
        'primary%3ADownload%2FBooks',
      );
    });
  });

  group('describeDownloadTreeUri', () {
    test('names the folder inside its volume', () {
      expect(
        describeDownloadTreeUri(
          'content://com.android.externalstorage.documents/tree/primary%3ABooks',
        ),
        'Books',
      );
    });

    test('keeps a nested path', () {
      expect(
        describeDownloadTreeUri(
          'content://com.android.externalstorage.documents/tree/'
          'primary%3ADownload%2FBooks',
        ),
        'Download/Books',
      );
    });

    test('shows the whole id when it carries no volume', () {
      // Another provider's document id is its own business — showing it whole
      // beats trimming it at a separator it does not have.
      expect(
        describeDownloadTreeUri(
          'content://com.example.provider/tree/somewhere',
        ),
        'somewhere',
      );
    });

    test('shows the volume when the path is empty', () {
      expect(
        describeDownloadTreeUri(
          'content://com.android.externalstorage.documents/tree/primary%3A',
        ),
        'primary:',
      );
    });
  });
}
