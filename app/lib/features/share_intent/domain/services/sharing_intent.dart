import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:lensai/core/logger.dart';
import 'package:lensai/data/models/received_intent_parameter.dart';
import 'package:mime/mime.dart' as mime;
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uri_to_file/uri_to_file.dart' as uri_to_file;

part 'sharing_intent.g.dart';

final _sharingIntentTransformer =
    StreamTransformer<List<SharedFile>, ReceivedIntentParameter>.fromHandlers(
      handleData: (files, sink) async {
        //For now only one file is supported to share with the app
        final data = files.firstOrNull;

        if (data != null && data.value != null) {
          switch (data.type) {
            case SharedMediaType.TEXT:
            case SharedMediaType.URL:
              if (uri_to_file.isUriSupported(data.value!)) {
                final file = await uri_to_file.toFile(data.value!);
                final mimeType = mime.lookupMimeType(file.path);
                switch (mimeType) {
                  case 'application/pdf':
                    sink.add(ReceivedIntentParameter(data.value, null));
                  default:
                    logger.w('Unhandled mime type: $mimeType');
                }
              } else {
                sink.add(ReceivedIntentParameter(data.value, null));
              }
            default:
              logger.w('Unhandled media type: $data');
          }
        }
      },
    );

@Riverpod()
Raw<Stream<ReceivedIntentParameter>> sharingIntentStream(Ref ref) {
  final initialStream =
      FlutterSharingIntent.instance
          // ignore: discarded_futures is used as stream
          .getInitialSharing()
          // ignore: discarded_futures is used as stream
          .then((event) {
            FlutterSharingIntent.instance.reset();
            return event;
          })
          .asStream();

  return ConcatStream([
    initialStream,
    FlutterSharingIntent.instance.getMediaStream(),
  ]).transform(_sharingIntentTransformer);
}
