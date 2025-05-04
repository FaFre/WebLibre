import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'simple_intent_receiver_platform_interface.dart';

/// An implementation of [SimpleIntentReceiverPlatform] that uses method channels.
class MethodChannelSimpleIntentReceiver extends SimpleIntentReceiverPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('simple_intent_receiver');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
