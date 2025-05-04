import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'simple_intent_receiver_method_channel.dart';

abstract class SimpleIntentReceiverPlatform extends PlatformInterface {
  /// Constructs a SimpleIntentReceiverPlatform.
  SimpleIntentReceiverPlatform() : super(token: _token);

  static final Object _token = Object();

  static SimpleIntentReceiverPlatform _instance = MethodChannelSimpleIntentReceiver();

  /// The default instance of [SimpleIntentReceiverPlatform] to use.
  ///
  /// Defaults to [MethodChannelSimpleIntentReceiver].
  static SimpleIntentReceiverPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SimpleIntentReceiverPlatform] when
  /// they register themselves.
  static set instance(SimpleIntentReceiverPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
