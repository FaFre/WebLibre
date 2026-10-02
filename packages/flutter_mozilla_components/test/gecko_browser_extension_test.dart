/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart'
    show GeckoBrowserExtensionApi;
import 'package:flutter_test/flutter_test.dart';

const _getMarkdown =
    'dev.flutter.pigeon.flutter_mozilla_components.GeckoBrowserExtensionApi.getMarkdown';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'a document the extension could not convert comes back as null',
    () async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const codec = GeckoBrowserExtensionApi.pigeonChannelCodec;

      // The reply turndown.js gives for a batch where the second document threw.
      messenger.setMockMessageHandler(
        _getMarkdown,
        (_) async => codec.encodeMessage(<Object?>[
          <Object?>[
            <Object?, Object?>{
              'fullContentMarkdown': '# Title',
              'fullContentPlain': 'Title',
            },
            <Object?, Object?>{'error': 'TypeError: node is null'},
          ],
        ]),
      );
      addTearDown(() => messenger.setMockMessageHandler(_getMarkdown, null));

      final results = await GeckoBrowserExtensionService.turndownHtml([
        '<h1>Title</h1>',
        '<p>broken',
      ]);

      expect(results, hasLength(2));
      expect(results[0]?.markdown, '# Title');
      expect(results[0]?.plain, 'Title');
      expect(results[1], isNull);
    },
  );
}
