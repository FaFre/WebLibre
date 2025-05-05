import 'dart:async';

import 'package:lensai/core/logger.dart';
import 'package:lensai/data/models/received_intent_parameter.dart';
import 'package:mime/mime.dart' as mime;
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:uri_to_file/uri_to_file.dart' as uri_to_file;

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
            final file = await uri_to_file.toFile(data);
            final mimeType = mime.lookupMimeType(file.path);
            switch (mimeType) {
              case 'application/pdf':
                sink.add(ReceivedIntentParameter(data, null));
              default:
                logger.w('Unhandled mime type: $mimeType');
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
