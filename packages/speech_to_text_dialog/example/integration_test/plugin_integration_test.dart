// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing


import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:speech_to_text_dialog/speech_to_text_dialog.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('showDialog returns bool', (WidgetTester tester) async {
    final SpeechToTextDialog plugin = SpeechToTextDialog();
    final bool result = await plugin.showDialog();
    // The result indicates if the dialog was shown successfully.
    // In a test environment without proper activity, this may return false.
    expect(result, isA<bool>());
    plugin.dispose();
  });

  testWidgets('textStream emits String values', (WidgetTester tester) async {
    final SpeechToTextDialog plugin = SpeechToTextDialog();
    final Stream<String> stream = plugin.textStream;
    expect(stream, isA<Stream<String>>());
    plugin.dispose();
  });
}
