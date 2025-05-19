import 'package:home_widget/home_widget.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/data/models/received_intent_parameter.dart';

part 'home_widget.g.dart';

@Riverpod(keepAlive: true)
FutureOr<bool> widgetPinnable(Ref ref) async {
  return await HomeWidget.isRequestPinWidgetSupported() ?? false;
}

@Riverpod()
Raw<Stream<ReceivedIntentParameter>> appWidgetLaunchStream(Ref ref) {
  // ignore: discarded_futures is used as stream
  final initialStream = HomeWidget.initiallyLaunchedFromHomeWidget().asStream();

  return ConcatStream([
    initialStream,
    HomeWidget.widgetClicked,
  ]).whereNotNull().map((uri) => ReceivedIntentParameter(null, uri.host));
}
