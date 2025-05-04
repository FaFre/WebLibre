import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_intent_receiver/simple_intent_receiver_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelSimpleIntentReceiver platform = MethodChannelSimpleIntentReceiver();
  const MethodChannel channel = MethodChannel('simple_intent_receiver');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
