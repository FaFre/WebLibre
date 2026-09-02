import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/proxy/data/models/proxy_log_message.dart';

void main() {
  group('ProxyLogSeverity', () {
    test('reads both runtimes spellings of the same level', () {
      expect(ProxyLogSeverity.parse('warn'), ProxyLogSeverity.warn);
      expect(ProxyLogSeverity.parse('warning'), ProxyLogSeverity.warn);
      expect(ProxyLogSeverity.parse('WARN'), ProxyLogSeverity.warn);
      expect(ProxyLogSeverity.parse('err'), ProxyLogSeverity.error);
      expect(ProxyLogSeverity.parse('ERROR'), ProxyLogSeverity.error);
      expect(ProxyLogSeverity.parse('notice'), ProxyLogSeverity.info);
    });

    test('a fatal line is an error, not a level of its own', () {
      expect(
        ProxyLogSeverity.parse('fatal'),
        ProxyLogSeverity.error,
        reason:
            'filtering on the exact string hid the worst lines in the buffer',
      );
      expect(ProxyLogSeverity.parse('panic'), ProxyLogSeverity.error);
    });

    test('an unknown level is kept rather than dropped', () {
      expect(ProxyLogSeverity.parse('something-else'), ProxyLogSeverity.info);
    });

    test('filtering keeps everything at least as serious', () {
      expect(ProxyLogSeverity.error.isAtLeast(ProxyLogSeverity.warn), isTrue);
      expect(ProxyLogSeverity.warn.isAtLeast(ProxyLogSeverity.warn), isTrue);
      expect(ProxyLogSeverity.info.isAtLeast(ProxyLogSeverity.warn), isFalse);
      expect(ProxyLogSeverity.trace.isAtLeast(ProxyLogSeverity.trace), isTrue);
    });

    test('a message ranks itself from its raw level', () {
      final message = ProxyLogMessage(
        source: ProxyLogSource.tor,
        level: 'fatal',
        message: 'boom',
        timestamp: 0,
      );

      expect(message.severity, ProxyLogSeverity.error);
      expect(message.severity.isAtLeastWarn, isTrue);
    });
  });
}
