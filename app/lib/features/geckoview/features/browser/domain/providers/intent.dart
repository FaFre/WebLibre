import 'dart:async';

import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/data/models/received_intent_parameter.dart';
import 'package:weblibre/features/app_widget/domain/services/home_widget.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/share_intent/domain/entities/shared_content.dart';
import 'package:weblibre/features/share_intent/domain/services/sharing_intent.dart';

part 'intent.g.dart';

final _contentParserTransformer =
    StreamTransformer<ReceivedIntentParameter, SharedContent>.fromHandlers(
      handleData: (parameter, sink) {
        final parsed = parameter.content.mapNotNull(
          (content) => SharedContent.parse(content),
        );

        if (parsed != null) {
          sink.add(parsed);
        }
      },
    );

@Riverpod()
class EngineBoundIntentStream extends _$EngineBoundIntentStream {
  late StreamController<SharedContent> _streamController;

  @override
  Stream<SharedContent> build() {
    _streamController = StreamController();
    ref.onDispose(() async {
      await _streamController.close();
    });

    final engineReady = ref.watch(engineReadyStateProvider);
    if (!engineReady) {
      return const Stream.empty();
    }

    final sharingItentStream = ref.watch(sharingIntentStreamProvider);
    final appWidgetLaunchStream = ref.watch(appWidgetLaunchStreamProvider);

    return MergeStream([
      sharingItentStream.transform(_contentParserTransformer),
      appWidgetLaunchStream.transform(_contentParserTransformer),
      _streamController.stream,
    ]);
  }
}
