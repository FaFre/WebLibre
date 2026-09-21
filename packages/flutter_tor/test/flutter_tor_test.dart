import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tor/src/flutter_tor.dart';
import 'package:flutter_tor/src/tor_api.g.dart';

const _statusChannel =
    'dev.flutter.pigeon.flutter_tor.TorEventsApi.streamStatus';
const _logsChannel = 'dev.flutter.pigeon.flutter_tor.TorEventsApi.streamLogs';

/// Stands in for the native side of one event channel.
class _NativeStream<T> {
  _NativeStream(String name)
    : _channel = EventChannel(name, pigeonMethodCodec) {
    _messenger.setMockStreamHandler(
      _channel,
      MockStreamHandler.inline(
        onListen: (arguments, events) {
          listens++;
          _sink = events;
        },
        onCancel: (arguments) {
          cancels++;
          _sink = null;
        },
      ),
    );
  }

  final EventChannel _channel;
  MockStreamHandlerEventSink? _sink;
  int listens = 0;
  int cancels = 0;

  static TestDefaultBinaryMessenger get _messenger =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void emit(T event) => _sink!.success(event);

  void close() => _messenger.setMockStreamHandler(_channel, null);
}

TorStatus _status(int progress) =>
    TorStatus(isRunning: true, socksPort: 9050, bootstrapProgress: progress);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _NativeStream<TorStatus> status;
  late _NativeStream<TorLogMessage> logs;

  setUp(() {
    status = _NativeStream(_statusChannel);
    logs = _NativeStream(_logsChannel);
  });

  tearDown(() {
    status.close();
    logs.close();
  });

  test('statusStream delivers the status changes native sends', () async {
    final received = <TorStatus>[];
    final subscription = FlutterTor().statusStream.listen(received.add);
    await pumpEventQueue();

    status.emit(_status(10));
    await pumpEventQueue();

    expect(received, [_status(10)]);
    await subscription.cancel();
  });

  test('logStream delivers the log messages native sends', () async {
    final message = TorLogMessage(
      severity: 'NOTICE',
      message: 'Bootstrapped 5%',
      timestamp: 1,
    );
    final received = <TorLogMessage>[];
    final subscription = FlutterTor().logStream.listen(received.add);
    await pumpEventQueue();

    logs.emit(message);
    await pumpEventQueue();

    expect(received, [message]);
    await subscription.cancel();
  });

  test('every subscriber shares one native listener', () async {
    final tor = FlutterTor();
    final first = tor.statusStream.listen((_) {});
    final second = tor.statusStream.listen((_) {});
    final progress = tor.bootstrapProgressStream.listen((_) {});
    await pumpEventQueue();

    // A second native listen would replace the first, silently ending the
    // stream for everyone who subscribed before it.
    expect(status.listens, 1);

    await first.cancel();
    await second.cancel();
    expect(status.cancels, 0);

    await progress.cancel();
    await pumpEventQueue();
    expect(status.cancels, 1);
  });

  test('bootstrapProgressStream reports each progress value once', () async {
    final progress = <int>[];
    final subscription = FlutterTor().bootstrapProgressStream.listen(
      progress.add,
    );
    await pumpEventQueue();

    // Status also changes for reasons other than progress.
    for (final value in [10, 10, 50, 50, 100]) {
      status.emit(_status(value));
    }
    await pumpEventQueue();

    expect(progress, [10, 50, 100]);
    await subscription.cancel();
  });
}
