import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/proxy/data/models/proxy_log_message.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_logs.dart';
import 'package:weblibre/features/proxy/presentation/screens/singbox_proxy_logs.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_diagnostics_settings.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    required List<ProxyLogMessage> logs,
    ProxyLogLevel logLevel = ProxyLogLevel.warn,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          proxyLogFeedProvider.overrideWith(() => _FakeLogFeed(logs)),
          proxyDiagnosticsSettingsWithDefaultsProvider.overrideWithValue(
            ProxyDiagnosticsSettings(logLevel: logLevel),
          ),
        ],
        child: const MaterialApp(home: SingboxProxyLogsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the level filter keeps everything at least as serious', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      logs: [
        _line(level: 'info', message: 'routine chatter'),
        _line(level: 'warn', message: 'something looks off'),
        // Spelled the way sing-box spells its worst lines. Filtering on the
        // exact string used to hide this one behind "Errors".
        _line(level: 'fatal', message: 'the tunnel died'),
      ],
    );

    expect(find.textContaining('routine chatter'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Warnings'));
    await tester.pumpAndSettle();

    expect(find.textContaining('routine chatter'), findsNothing);
    expect(find.textContaining('something looks off'), findsOneWidget);
    expect(find.textContaining('the tunnel died'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Errors'));
    await tester.pumpAndSettle();

    expect(find.textContaining('something looks off'), findsNothing);
    expect(find.textContaining('the tunnel died'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('routine chatter'),
      findsOneWidget,
      reason: 'the "All" choice has to be able to clear the filter',
    );
  });

  testWidgets('an empty filter result says which of the two it is', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      logs: [_line(level: 'info', message: 'chatter')],
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Errors'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No log lines at this level'), findsOneWidget);
  });

  testWidgets('says what the runtimes are recording, and warns when verbose', (
    tester,
  ) async {
    await pumpScreen(tester, logs: const []);
    expect(
      find.textContaining('Recording warnings and errors'),
      findsOneWidget,
    );

    await pumpScreen(tester, logs: const [], logLevel: ProxyLogLevel.trace);
    expect(find.textContaining('this slows browsing'), findsOneWidget);
  });
}

ProxyLogMessage _line({required String level, required String message}) {
  return ProxyLogMessage(
    source: ProxyLogSource.singBox,
    level: level,
    message: message,
    timestamp: 0,
  );
}

class _FakeLogFeed extends ProxyLogFeed {
  final List<ProxyLogMessage> logs;

  _FakeLogFeed(this.logs);

  @override
  List<ProxyLogMessage> build() => logs;
}
