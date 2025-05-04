import 'package:flutter_test/flutter_test.dart';
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:simple_intent_receiver/simple_intent_receiver_platform_interface.dart';
import 'package:simple_intent_receiver/simple_intent_receiver_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSimpleIntentReceiverPlatform
    with MockPlatformInterfaceMixin
    implements SimpleIntentReceiverPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SimpleIntentReceiverPlatform initialPlatform = SimpleIntentReceiverPlatform.instance;

  test('$MethodChannelSimpleIntentReceiver is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSimpleIntentReceiver>());
  });

  test('getPlatformVersion', () async {
    SimpleIntentReceiver simpleIntentReceiverPlugin = SimpleIntentReceiver();
    MockSimpleIntentReceiverPlatform fakePlatform = MockSimpleIntentReceiverPlatform();
    SimpleIntentReceiverPlatform.instance = fakePlatform;

    expect(await simpleIntentReceiverPlugin.getPlatformVersion(), '42');
  });
}
