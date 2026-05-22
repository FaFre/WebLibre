import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/proxy/domain/services/dns_config_resolver.dart';

/// The Dart and Kotlin sides of the sing-box config builder must produce the
/// same `out-`/`in-` tags. These cases mirror `SingboxTagFormatTest.kt` —
/// both must update together if this format ever changes.
void main() {
  group('singbox tag format', () {
    test('outboundTag is prefixed and sanitized', () {
      expect(singboxOutboundTag('singbox:foo-bar'), 'out-singbox_foo-bar');
    });

    test('inboundTag is prefixed and sanitized', () {
      expect(singboxInboundTag('singbox:foo-bar'), 'in-singbox_foo-bar');
    });

    test('sanitizeTag preserves alphanumeric, dots, dashes, underscores', () {
      expect(singboxSanitizeTag('Abc_123.x-Y'), 'Abc_123.x-Y');
    });

    test('sanitizeTag replaces spaces, slashes, colons', () {
      expect(singboxSanitizeTag('a:b c/d\\e'), 'a_b_c_d_e');
    });
  });
}
