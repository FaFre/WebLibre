
import 'simple_intent_receiver_platform_interface.dart';

class SimpleIntentReceiver {
  Future<String?> getPlatformVersion() {
    return SimpleIntentReceiverPlatform.instance.getPlatformVersion();
  }
}
