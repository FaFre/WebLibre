import 'package:flutter/services.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_singbox_proxy/src/singbox_proxy_api.g.dart'
    show pigeonMethodCodec;
import 'package:flutter_test/flutter_test.dart';

const _stateChannel =
    'dev.flutter.pigeon.flutter_singbox_proxy.SingboxProxyEventsApi.streamState';
const _logsChannel =
    'dev.flutter.pigeon.flutter_singbox_proxy.SingboxProxyEventsApi.streamLogs';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('profile model keeps generic sing-box config boundary', () {
    final profile = SingboxProxyProfile(
      id: 'wg-home',
      name: 'WireGuard Home',
      type: SingboxProxyProfileType.wireguard,
      configJson: '{"server":"example.test"}',
      secretJson: '{"private_key":"secret"}',
    );

    expect(profile.id, 'wg-home');
    expect(profile.type, SingboxProxyProfileType.wireguard);
    expect(profile.secretJson, contains('private_key'));
  });

  test('runtime options default to blocking unmatched traffic', () {
    final options = SingboxProxyRuntimeOptions();

    expect(options.preferredBasePort, isNull);
    expect(options.blockUnmatchedTraffic, isTrue);
  });

  group('event streams', () {
    late _NativeStream<SingboxProxyRuntimeState> states;
    late _NativeStream<SingboxProxyLogMessage> logs;

    setUp(() {
      states = _NativeStream(_stateChannel);
      logs = _NativeStream(_logsChannel);
    });

    tearDown(() {
      states.close();
      logs.close();
    });

    test('stateStream delivers the state changes native sends', () async {
      final state = SingboxProxyRuntimeState(
        status: SingboxProxyRuntimeStatus.running,
        endpoints: const [],
      );
      final received = <SingboxProxyRuntimeState>[];
      final subscription = FlutterSingboxProxy().stateStream.listen(
        received.add,
      );
      await pumpEventQueue();

      states.emit(state);
      await pumpEventQueue();

      expect(received.single.status, SingboxProxyRuntimeStatus.running);
      await subscription.cancel();
    });

    test('logStream delivers the log messages native sends', () async {
      final message = SingboxProxyLogMessage(
        level: 'info',
        message: 'started',
        timestamp: 1,
      );
      final received = <SingboxProxyLogMessage>[];
      final subscription = FlutterSingboxProxy().logStream.listen(received.add);
      await pumpEventQueue();

      logs.emit(message);
      await pumpEventQueue();

      expect(received.single.message, 'started');
      await subscription.cancel();
    });

    test('every subscriber shares one native listener', () async {
      final proxy = FlutterSingboxProxy();
      final first = proxy.stateStream.listen((_) {});
      final second = proxy.stateStream.listen((_) {});
      await pumpEventQueue();

      // A second native listen would replace the first, silently ending the
      // stream for everyone who subscribed before it.
      expect(states.listens, 1);

      await first.cancel();
      expect(states.cancels, 0);

      await second.cancel();
      await pumpEventQueue();
      expect(states.cancels, 1);
    });
  });
}
