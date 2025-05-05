import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:simple_intent_receiver/simple_intent_receiver.dart';

late final IntentReceiver receiver;

final logger = Logger();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  receiver = IntentReceiver.setUp();

  receiver.events.listen((data) {
    logger.d(data.action);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}
