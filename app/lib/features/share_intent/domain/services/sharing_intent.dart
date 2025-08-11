/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'dart:async';

import 'package:mime/mime.dart' as mime;
import 'package:nullability/nullability.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:uri_to_file/uri_to_file.dart' as uri_to_file;
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/data/models/received_intent_parameter.dart';

part 'sharing_intent.g.dart';

final _sharingIntentTransformer =
    StreamTransformer<Intent, ReceivedIntentParameter>.fromHandlers(
      handleData: (intent, sink) async {
        final data = switch (intent.action) {
          'android.intent.action.WEB_SEARCH' =>
            intent.extra['query'] as String?,
          'android.intent.action.VIEW' => intent.data,
          'android.intent.action.SEND' =>
            intent.extra['android.intent.extra.STREAM'] as String? ??
                intent.extra['android.intent.extra.TEXT'] as String?,
          _ => null,
        };

        if (data != null) {
          if (uri_to_file.isUriSupported(data)) {
            var path = data;
            if (p.extension(data).whenNotEmpty == null) {
              if (intent.mimeType.whenNotEmpty != null) {
                final ext = mime.extensionFromMime(intent.mimeType!);
                if (ext != null) {
                  path = p.setExtension(path, '.$ext');
                } else {
                  logger.w(
                    'Could not determine file extension for: ${intent.mimeType}',
                  );
                }
              } else {
                logger.w(
                  'Received intent without extension and mime type $path',
                );
              }
            }

            try {
              final file = await uri_to_file.toFile(path);
              final mimeType = mime.lookupMimeType(file.path);
              switch (mimeType) {
                case 'application/pdf':
                  sink.add(ReceivedIntentParameter(path, null));
                default:
                  logger.w('Unhandled mime type: $mimeType');
              }
            } catch (e) {
              logger.e('Failed to convert URI to file: $e');
              // Fallback: pass the original URI
              sink.add(ReceivedIntentParameter(data, null));
            }
          } else {
            sink.add(ReceivedIntentParameter(data, null));
          }
        }
      },
    );

@Riverpod(keepAlive: true)
Raw<Stream<ReceivedIntentParameter>> sharingIntentStream(Ref ref) {
  final receiver = IntentReceiver.setUp();

  return receiver.events.transform(_sharingIntentTransformer);
}
