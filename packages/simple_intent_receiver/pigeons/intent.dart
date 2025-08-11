import 'package:pigeon/pigeon.dart';

class Intent {
  final String? fromPackageName;
  final String? action;
  final String? data;
  final List<String> categories;
  final String? mimeType;
  final Map<String, Object?> extra;

  Intent({
    required this.fromPackageName,
    required this.action,
    required this.data,
    required this.categories,
    required this.mimeType,
    required this.extra,
  });
}

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/intent.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/eu/weblibre/simple_intent_receiver/pigeons/Intent.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'eu.weblibre.simple_intent_receiver.pigeons',
    ),
    dartPackageName: 'simple_intent_receiver',
  ),
)
@FlutterApi()
abstract class IntentEvents {
  void onIntentReceived(int timestamp, Intent intent);
}
