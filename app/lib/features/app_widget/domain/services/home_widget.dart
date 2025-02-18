import 'package:home_widget/home_widget.dart';
import 'package:lensai/data/models/received_parameter.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'home_widget.g.dart';

@Riverpod(keepAlive: true)
FutureOr<bool> widgetPinnable(Ref ref) async {
  return await HomeWidget.isRequestPinWidgetSupported() ?? false;
}

@Riverpod()
Raw<Stream<ReceivedParameter>> appWidgetLaunchStream(Ref ref) {
  // ignore: discarded_futures is used as stream
  final initialStream = HomeWidget.initiallyLaunchedFromHomeWidget().asStream();

  return ConcatStream([
    initialStream,
    HomeWidget.widgetClicked,
  ]).whereNotNull().map((uri) => ReceivedParameter(null, uri.host));
}
